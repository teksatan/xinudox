#!/usr/bin/perl
# xinudox CORE
# @author glitch
# CORE version 2.3 for xinudox perl bot

package core;

use strict;
use warnings;
use IO::Socket;
use IO::Select;
#use threads;
use sigtrap;

our $socket;
our $select = IO::Select->new();
require 'include/src/error.pm';
require 'include/src/commands.pm';
require 'include/src/modules.pm';
sub start {
  my $tries = 0;
  my ($tmpserver, $tmpport) = split("\:", $config::server);
  while ($tries < 10) {
    $socket = new IO::Socket::INET(
      PeerAddr => $tmpserver,
      PeerPort => $tmpport,
      Proto    => 'tcp',
      Timeout  => 5,
    ) or warn "Cant Create socket: $!\n";
   $tries++;
   last if $socket->connected();
  }
  $select->add($socket);
  commands->send("NICK $config::nickname");
  commands->send("USER $config::ident 8 $config::localhost :$config::realname");
  sleep 3;
  commands->send("JOIN $config::channelName");
  commands->daemonize();
  while (my $data = $socket->getline) {
    chomp $data;
    last if !$data;
    next if $data eq '';
    commands->send("PONG $1") if $data =~ /^PING (.*)$/i;
    # im gunna call next; after each input to speed up xinudox some. no sense in continueing the search if we already found our target
    if ($data =~ m/^\:(.*?)\!(.*?)\@(.*?) PRIVMSG (.*?) \:(.*?)$/i) {
      handle->PRIVMSG($1, $2, $3, $4, $5);
      next;
    }
    elsif ($data =~ m/^\:(.*?)\!(.*?)\@(.*?) NOTICE (.*?) \:(.*?)$/i) {
      handle->NOTICE($1, $2, $3, $4, $5);
      next;
    }
    elsif ($data =~ m/^\:(.*?) NOTICE (.*?) \:\*\*\* (.*?)$/i) {
      handle->SNOTICE($1, $2, $3);
      next;
    }
    elsif ($data =~ m/^\:(.*?)\!(.*?)\@(.*?) PART (.*?) \:(.*?)$/i) {
      handle->PART($1, $2, $3, $4, $5);
      next;
    }
    elsif ($data =~ m/^\:(.*?)\!(.*?)\@(.*?) JOIN \:(.*?)$/i) {
      handle->JOIN($1, $2, $3, $4);
      next;
    }
    elsif ($data =~ m/^\:(.*?)\!(.*?)\@(.*?) MODE (.*?) (.*?)$/i) {
      handle->MODE($1, $2, $3, $4, $5);
      next;
    }
    elsif ($data =~ m/^\:(.*?)\!(.*?)\@(.*?) KICK (.*?) (.*?) (.*?)$/i) {
      handle->KICK($1, $2, $3, $4, $5, $6);
      next;
    }
    elsif ($data =~ m/^\:(.*?) (.*?) $config::nickname (.*?)$/i) {
      handle->RAW($1, $2, $3);
      next;
    }
    elsif ($data =~ m/^\:(.*?)\!(.*?)\@(.*?) QUIT \:(.*?)$/i) {
      handle->QUIT($1, $2, $3, $4);
      next;
    }
  }
  core->configsave();
  users->save();
  $socket->shutdown(2);
}

sub evaluate {
  my ($channel, $parameters) = ($_[1], $_[2]);
  eval($parameters);
  if (defined $@ && $@ ne '') {
    commands->msg($channel, "Error-> $@\r\n");
  }
  return 0;
}

sub exec {
  my ($channel, $parameters) = ($_[1], $_[2]);
  my @return = `$parameters`;
  for my $line (@return) {
    commands->msg($channel, "$line\r\n");
  }
  return 0;
}

sub configsave {
  sql->conn();
  my $nickname = sql->quote($config::nickname);
  my $server = sql->quote($config::server);
  my $channels = sql->quote(join(" ", @config::channels));
  sql->do("UPDATE config SET inuse = 1"); # should we load this db @ start over our config.pl?
  sql->do("UPDATE config SET nickname = $nickname;");
  sql->do("UPDATE config SET server = $server;");
  sql->do("UPDATE config SET opered = $config::operup;");
  sql->do("UPDATE config SET daemonize = $config::daemonize;");
  sql->do("UPDATE config SET logging = $config::logging;");
  sql->close();
}

sub configget {
    sql->conn();
    sql->prepare("SELECT * FROM config");
    $sql::sth->execute();
    while (my $ref = $sql::sth->fetchrow_hashref()) {
      if ($ref->{'inuse'} == 0) {
        $sql::sth->finish();
        sql->close;
        return 0;
      }
      $config::nickname = $ref->{'nickname'};
      $config::server = $ref->{'server'};
      $config::defmodes = $ref->{'modes'};
      $config::operup = $ref->{'opered'};
      $config::daemonize = $ref->{'daemonize'};
      $config::logging = $ref->{'logging'};
    }
    sql->do("UPDATE config SET inuse = 0");
    $sql::sth->finish();
    sql->close();
}
1;
