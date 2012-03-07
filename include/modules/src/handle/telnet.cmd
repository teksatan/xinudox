#!/usr/bin/perl

package telnet::cmds;
use strict;
use warnings;

sub parse {
  my ($access, $nickname, $command, $parameters) = ($_[1], $_[2], $_[3], $_[4]);
  my @data = split(" ", $parameters);
  if ($access eq 'owner') {
    if ($command eq "e") {
      eval($parameters) or return 0;
    }
    if ($command eq "system") {
      my $thr = threads->create( sub {
        open my $TERM, "$parameters |" ;
        while (<$TERM>) {
          $telnet::client{$nickname}->{'socket'}->send("$_\r\n");
        }
        close $TERM;
      })->detach;
    }
    if ($command eq "for") {
      my $num = shift @data;
      my $cmd = join " ", @data;
      for (my $i = 0; $i < $num; $i++) {
        eval ($cmd);
      }
    }
    if ($command eq "die") {
      commands->send("QUIT :$parameters");
      users->save();
      close $core::socket;
      exit 0;
    }
    if($command eq "sajoin") {
      sajoin->sajoin($nickname, $parameters);
    }
    if($command eq "kill") {
      oper->kill($nickname, $parameters);
    }
  }
  if ($access eq 'owner' || $access eq 'admin') {
    if ($command eq "rep") {
      return 0 if !defined $data[0];
      my $thr = threads->create( sub {
        for (my $i = 0; $i < 20; $i++) {
	   commands->send("PRIVMSG $data[0] :$data[1]");
	 }
      } )->detach();
    }
    if ($command eq "raw") {
      commands->send($parameters);
    }
    if ($command eq "quit") {
      commands->send("QUIT :$parameters");
      sleep 20;
      core->start();
    }
    if ($command eq "restart") {
      commands->restart($parameters);
    }
  }
}

1;
