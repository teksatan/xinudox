#!/usr/bin/perl

package telnet;
use strict;
use warnings;
use IO::Socket;
use threads;

my ($thread, %client);

my %telnet = (
  port => '5678',
  name => 'Anondox',
  prefix => '>',
  welcomemsg => 'Welcome to %name %nick\!\r\nThe current date is %time\r\n",
  maxconnections => '10';
);

sub start {
 $telnet{'thread'} = threads->create( sub { telnet->server(); } )->detach;
 commands->wlog('telnet', "successfully threaded server..");
}

sub server {
 $telnet{'socket'} = IO::Socket::INET->new(
                       LocalPort => $telnet{'port'},
                       Protocol  => 'tcp',
                       Listen     => $telnet{'maxconnections'};,
                       Reuse     => 1,
                    ) or die "Can't create server $!\n";
  while (1) {
    my $tmp = int rand 5000;
    my $tmp_addr;
    ($client{$tmp}->{'socket'}, $tmp_addr) = $telnet{'socket'}->accept();
    $client{$tmp}->{'socket'}->send("Hi!\r\nNickname: ");
    threads->new( sub { telnet->clients_handle($tmp, $tmp_addr); } )->detach();
  }
}


sub clients_handle {
  my ($name, $addr, $reason) = ($_[1], $_[2], "Quit");
  while (my $data = $client{$name}->{'socket'}->getline) {
  chomp($data);
  $data =~ s/\r//;
  next if $data eq '';
  if (!defined $client{$name}->{'state'}) {
    my $newuser = $data;
    if (-f "data/$newuser") {
      open(my $fid, "< data/$newuser");
      $client{$newuser}->{'password'} = crypt(<$fid>, $config::salt) or return undef;
      close $fid;
      $client{$newuser}->{'socket'} = $client{$name}->{'socket'};
      $client{$newuser}->{'addrinfo'} = clients->configure($newuser, $addr);
      $client{$newuser}->{'state'} = 1;
      $client{$newuser}->{'tries'} = 0;
      $client{$name}->{'socket'}->send("\nPassword: ");
      clients->handle($newuser, $addr);
      delete $client{$name};
      last;
    }
    else {
      $client{$name}->{'socket'}->send("Unknown user \"$newuser\" Try typing !tnet in an IRC channel im in\r\n");
      sleep 2;
      last;
    }
  }
  elsif ($client{$name}->{'state'} == 1) {
    my $password = crypt($data, $config::salt);
    unlink("data/$name");
    if (defined $client{$name}->{'password'} && $client{$name}->{'password'} eq $password) {
      $client{$name}->{'state'} = 2;
      $client{$name}->{'prefix'} = $telnet{'prefix'};
      $client{$name}->{'prefix'} =~ s/\%n/$name/;
      my $time = localtime();
      print "\n";
      open (my $fid, "< data/welcome.txt");
      my @lines = <$fid>;
      for my $line (@lines) {
        next if $line eq '';
        $line =~ s/\%n/$name/;
        $line =~ s/\%hs/$client{$name}->{'addrinfo'}/;
        $line =~ s/\%d/$time/;
        $client{$name}->{'socket'}->send("$line\r\n");
      }
      $client{$name}->{'socket'}->send("\r\n".$client{$name}->{'prefix'}." ");
    }
    else {
      if ($client{$name}->{'tries'} == 5) {
      $client{$name}->{'socket'}->send("\nIncorrect password\r\n");
      $reason = "Client Killed To many invalid passwords from $name \(".$client{$name}->{'addrinfo'}."\)";
      commands->log($name, $reason);
      last;
    }
    $client{$name}->{'socket'}->send("\nIncorrect password\r\n");
    $client{$name}->{'socket'}->send("\nPassword: ");
    $client{$name}->{'tries'}++;
    next;
  }
  elsif ($data eq 'exit') {
    $client{$name}->{'socket'}->send("Bye!\r\n");
    last;
  }
  else {
    my $ret = clients->parse($name, $data);
    last;
  }
  next;
}
}
if (defined $client{$name}->{'socket'}) {
print "Client $name ".$client{$name}->{'addrinfo'}." disconnected: \($reason\)\n";
commands->wlog('telnet', "Client $name ".$client{$name}->{'addrinfo'}." disconnected: \($reason\)");
commands->wlog($name, "Session ended.");
$client{$name}->{'socket'}->shutdown(2);
$select->remove($client{$name}->{'socket'});
delete $client{$name};
}
}

1;
