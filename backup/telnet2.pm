#!/usr/bin/perl

package telnet;
use strict;
use warnings;
use IO::Socket;
use threads;
use Digest::MD5;

our $version = "2.0 glitch";

my ($thread, %client);

my %telnet = (
  port => '5678',
  name => 'Anondox',
  prefix => '>',
  welcomemsg => "Welcome to %name %nick\!\r\nThe current date is %time\r\n",
  maxconnections => '10',
);

sub start {
 $telnet{'thread'} = threads->create( sub { telnet->server(); } )->detach;
 commands->writelog('telnet', "successfully threaded server..");
}

sub server {
 $telnet{'socket'} = IO::Socket::INET->new(
                       LocalPort => $telnet{'port'},
                       Protocol  => 'tcp',
                       Listen     => $telnet{'maxconnections'},
                       Reuse     => 1,
                    ) or die "Can't create server $!\n";
  while (1) {
    my $tmp = int rand 5000;
    my $tmp_addr;
    ($client{$tmp}->{'socket'}, $tmp_addr) = $telnet{'socket'}->accept();
    $client{$tmp}->{'socket'}->send("Hi!\r\nNickname: ");
    $client{$tmp}->{'addrinfo'} = telnet->clients_configure($tmp, $tmp_addr);
    threads->new( sub { telnet->clients_handle($tmp); } )->detach();
  }
}

sub clients_configure {
  my ($user, $addr) = ($_[1], $_[2]);
  my ($client_port, $client_ip) = sockaddr_in($addr);
  my $client_ipnum =  inet_ntoa($client_ip);
  my $time = localtime();
  commands->writelog('telnet', "Client $user connected from $client_ipnum\:$client_port");
  print "Client $user connected from $client_ipnum\:$client_port\n";
  return "$client_ipnum $client_port";
}

sub clients_handle {
  my ($name, $reason) = ($_[1], "Quit");
  while (my $data = $client{$name}->{'socket'}->getline) {
    chomp($data);
    $data =~ s/\r//;
    next if $data eq '';
    if (!defined $client{$name}->{'state'}) {
      my $newuser = $data;
      if (defined $users::users{$newuser}->{'password'}) {
        if ($users::users{$newuser}->{'type'} eq 'normal') {
          $client{$name}->{'socket'}->send("A user with your level of access \"normal\" has no bizz being in here so gtfo\r\n");
          last;
        }
        $client{$newuser}->{'socket'} = $client{$name}->{'socket'};
        $client{$newuser}->{'socket'}->autoflush(1);
        $client{$newuser}->{'type'} = $users::users{$newuser}->{'type'};
        $client{$newuser}->{'password'} = $users::users{$newuser}->{'password'};
        $client{$newuser}->{'addrinfo'} = $client{$name}->{'addrinfo'};
        $client{$newuser}->{'state'} = 1;
        $client{$newuser}->{'tries'} = 0;
        $client{$name}->{'socket'}->send("\nPassword: ");
        telnet->clients_handle($newuser);
        delete $client{$name};
        last;
      }
      else {
        $client{$name}->{'socket'}->send("Unknown user \"$newuser\" Try Registering with me in IRC by typing \'/msg xinudox !register yourpassword\'\r\n");
        sleep 2;
        last;
      }
    }
    elsif ($client{$name}->{'state'} == 1) {
      my $password = Digest::MD5::md5_hex(crypt($data,$config::salt));
      if (defined $client{$name}->{'password'} && $client{$name}->{'password'} eq $password) {
        $client{$name}->{'state'} = 2;
        my $time = localtime();
        my $message = $telnet{'welcomemsg'};
        print "Client $name logged in from \(".$client{$name}->{'addrinfo'}."\)\n";
        commands->writelog('telnet', "Client $name logged in from \(".$client{$name}->{'addrinfo'}."\)");
        $message =~ s/\%name/$telnet{name}/;
        $message =~ s/\%nick/$name/;
        $message =~ s/\%time/$time/;
        $client{$name}->{'socket'}->send("$message");
        $client{$name}->{'socket'}->send("\r\n".$telnet{'prefix'}." ");
      }
      else {
        if ($client{$name}->{'tries'} == 5) {
          $client{$name}->{'socket'}->send("\nIncorrect password\r\n");
          $reason = "Client Killed To many invalid passwords from $name \(".$client{$name}->{'addrinfo'}."\)";
          commands->writelog('telnet', $reason);
          last;
        }
        $client{$name}->{'socket'}->send("\nIncorrect password\r\n");
        $client{$name}->{'socket'}->send("\nPassword: ");
        $client{$name}->{'tries'}++;
        next;
      }
    }
    elsif ($data eq 'exit') {
      $client{$name}->{'socket'}->send("Bye!\r\n");
      last;
    }
    else {
      my $ret = telnet->clients_parse($name, $data);
      if ($ret == -1) {
        last;
      }
      next;
    }
  }
  if (defined $client{$name}->{'socket'}) {
    print "Client $name ".$client{$name}->{'addrinfo'}." disconnected: \($reason\)\n";
    commands->writelog('telnet', "Client $name ".$client{$name}->{'addrinfo'}." disconnected: \($reason\)");
    $client{$name}->{'socket'}->shutdown(2);
    delete $client{$name};
  }
}

sub clients_parse {
  my ($user, @data) = ($_[1], split (" ", $_[2]));
  my ($command, $parameters) = (shift(@data), join (" ", @data));
  $parameters =~ s/\r// if defined $parameters;
  commands->writelog('telnet', "$user\-\>$_[2]");
  if ($command eq 'help') {
    $client{$user}->{'socket'}->send("Get Fucked..\r\n");
    return 1;
  }
  else {
    my @msk = split("@", $users::users{$user}->{'mask'});
    telnet::cmds->parse($client{$user}->{'type'}, $user, $command, $parameters);
  }
}

sub shutdown {
  my $errmsg = $_[1];
  for my $user (sort keys %telnet::client) {
    next if !defined $client{$user}->{'socket'};
    $client{$user}->{'socket'}->send("Error: $errmsg\r\n");
    $client{$user}->{'socket'}->shutdown(2);
  }
  $telnet{'socket'}->shutdown(2) if defined $telnet{'socket'};
  return 0;
}

1;
