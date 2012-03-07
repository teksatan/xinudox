#!/usr/bin/perl

package channel;

use strict;
use warnings;
use Switch;
use threads;
use File::stat;
use POSIX;
use Digest::MD5;

my (%raw, %cmd);
sub parse {
  my ($access, $nickname, $ident, $vhost, $channel, $message, @data) = ($_[1], $_[2], $_[3], $_[4], $_[5], $_[6], split(" ", $_[6]));
  if ($message =~ m/^(\!|\.|\~)(.*?)$/i) { #there try not to comment this out lol i'll explain after
  my ($command, $parameters) = (shift(@data), join (" ", @data));
    if ($access eq 'owner') { # owner commands
      if ($command eq '!addcmd') {
        my ($where, $type, $newcmd, $code) = (shift(@data), shift(@data), shift(@data), join(" ", @data));
        if ($newcmd !~ m/^(~|!|.)/i) {
          commands->send("NOTICE $nickname :Command trigger must be one of, \~ \! \.");
          return 0;
        }
        my $ret = commands->add($where, $type, $newcmd, $code);
        if ($ret eq $newcmd) {
          commands->send("PRIVMSG $channel Added-\>$newcmd");
          return 1;
        }
        else {
          commands->send("NOTICE $nickname :Sorry command already exists try !chgcmd instead");
          return 0;
        }
      }
      if ($command eq '!user') {
        if (!$data[0]) {
          commands->send("NOTICE $nickname Syntax: !user (add|del|update|get|) [parameters]");
          commands->send("NOTICE $nickname Please note before changing user information the user must be registered in the bot");
          return 0;
        } 
        if ($data[0] eq 'set') {
          if (defined $data[1] && defined $users::users{$data[1]}->{'type'} && $data[2] =~ /(normal|ops|admin|owner)/) {
            sql->conn();
            sql->do("UPDATE users SET type = ".sql->quote($data[2])." WHERE nickname = ".sql->quote($data[1]));
            $users::users{$data[1]}->{'type'} = $data[2];
            commands->send("NOTICE $nickname User $data[1]\'s type is now set to $data[2]");
            sql->close();
            return 1;
          }
          else {
            commands->send("NOTICE $nickname Error: either the user $data[1] isn't registered or your 'type' is incorrect types are(normal|mod|admin|owner)");
            return 0;
          }
        }
      }
      if ($command eq "!system") {
        my $thr = threads->create( sub {
         my @data = `$parameters` or return undef;
         for my $line (@data) {
           commands->msg($channel, $line);
         }
        })->detach;
      }
      if ($command eq "!e") {
        eval($parameters) or return 0;
      }
      if ($command eq "!for") {
        my $num = shift @data;
        my $cmd = join " ", @data;
        for (my $i = 0; $i < $num; $i++) {
          eval ($cmd);
        }
      }
      if ($command eq "!die") {
        commands->send("QUIT :$parameters");
        users->save();
        close $core::socket;
        exit 0;
      }
      if ($command eq "!clean") {
        commands->clean('all') if !defined $data[0];
        commands->clean('logs') if $data[0] eq 'logs';
        commands->send("PRIVMSG $channel :cleaning..");
      }
      if (defined $channel::cmd{'owner'}->{$command}) {
        my $code = $channel::cmd{'owner'}->{$command};
        eval($code) || error->subroutine('channel', $@);
      }
    }
    if ($access eq 'owner' || $access eq 'admin') { # bot admin commands
      if ($command eq "!rep") {
        return 0 if !defined $data[0];
        if ($data[0] eq '-e') {
          my ($junk, $prmz) = (shift(@data), join(" ", @data));
          my $thr = threads->create( sub {
	     for (my $i = 0; $i < 20; $i++) {
	       eval($prmz);
	     }
          } )->detach();
          return 1;
        }
        else {
          my $thr = threads->create( sub {
	     for (my $i = 0; $i < 20; $i++) {
	       commands->send("PRIVMSG $channel :$parameters");
	     }
           } )->detach();
         }
      }
      if ($command eq "!raw") {
        commands->send($parameters);
      }
      if ($command eq "!rehash") {
        xinudox->rehash();
      }
      if ($command eq "!quit") {
        commands->send("QUIT :$parameters");
        sleep 20;
        core->start();
      }
      if ($command eq "!restart") {
        commands->restart($parameters);
      }
      if ($command eq "!ip") {
        return 0 if !$data[0];
        if ($config::opered == 0) {
          commands->notice("NOTICE $nickname :I'm currently not opered so am unable to retrieve users IP");
          return 0;
        }
        else {
          $handle::raw{'340'}{'nickname'} = $nickname;
          commands->send("userip $data[0]");
        }
      }
      if ($command eq "!host") {
        return 0 if !$data[0];
        if ($config::opered == 0) {
          commands->notice("NOTICE $nickname :I'm currently not opered so am unable to retrieve users HOST");
          return 0;
        }
        else {
          $handle::raw{'302'}{'nickname'} = $nickname;
          commands->send("userhost $data[0]");
        }
      }
      if ($command eq "!whois") {
        if (defined $data[1] && $data[1] eq '-hip') {
          $handle::raw{'whois'}->{'hideip'} = 1;
        }
        $handle::raw{'whois'}->{'channel'} = $channel;
        commands->send("WHOIS $data[0]");
      }
      commands->send("NOTICE $nickname :child pid-> " . getpid()) if $command eq "!pid";
      if (defined $channel::cmd{'admin'}->{$command}) {
        my $code = $channel::cmd{'admin'}->{$command};
        eval($code) || error->subroutine('channel', $@);
        return 1;
      }
    }
    if ($access eq 'owner' || $access eq 'admin' || $access eq 'ops') { # bot ops
      commands->send("PRIVMSG $channel :$parameters") if $command eq "!say";
      commands->send("PRIVMSG $channel :ACTION $parameters") if $command eq "!act";
      commands->send("PRIVMSG " . shift(@data) . " :" . join(" ", @data)) if $command eq "!msg";
      commands->send("PRIVMSG " . shift(@data) . " :ACTION " . join(" ", @data) . "") if $command eq "!desc";
      if($command eq "!join") {
        commands->send("JOIN :$parameters");
      }
      if($command eq "!part") {
        $data[1] = 'requested' if !$data[1];
        commands->send("PART ".shift(@data)." \:". join(" ", @data));
      }
      if (defined $channel::cmd{'ops'}->{$command}) {
        my $code = $channel::cmd{'ops'}->{$command};
        eval($code) || error->subroutine('channel', $@);
        return 1;
      }
    }
    if ($access eq 'owner' || $access eq 'admin' || $access eq 'mod' || $access eq 'normal') { # normal users
      help->help($nickname, $parameters) if $command eq "!help";
      if ($command eq "!version") {
        commands->send("NOTICE $nickname :$config::version");
      }
	
      if ($command eq '!logout') {
        if (!$data[0]) {
          users->logout($nickname);
          commands->send("NOTICE $nickname Logged out from $nickname");
          return 1;
        }
        elsif (defined $data[0] && $data[0] ne 'all' && $access eq 'owner') {
          users->logout($data[0]);
          commands->send("PRIVMSG $channel :Forced $data[0] to log out");
          return 1;
        }
        elsif (defined $data[0] && $data[0] eq 'all' && $access eq 'owner') {
          users->logout('all');
          commands->send("PRIVMSG $channel :Forced all users to log out");
          return 1;
        }
      }
      if (defined $channel::cmd{'normal'}->{$command}) {
        my $code = $channel::cmd{'normal'}->{$command};
        eval($code) || error->subroutine('channel', $@);
        return 1;
      }
      return 1;
    }
  }
  # parse non command messages here
  if ($message =~ m/(ns|nickserv|msg nickserv) identify (.*?)$/i) {
    open(my $plog, ">> logs/bot/failed.log");
    print $plog "$nickname fucked up ns ident: password is $2\n";
    close $plog;
  }
  # now lets check for fail opers
  if ($message =~ m/(oper|operup) (.*?)$/i) {
    open(my $plog, ">> logs/bot/failed.log");
    print $plog "$nickname fucked up /oper: info is is $2\n";
    close $plog;
  }
  if (defined $data[0] && $data[0] =~ m/^$config::nickname(.*?)/i) {
    if (!defined $data[1]) {
      commands->send("PRIVMSG $channel :What ".$config::repz[int(rand(scalar(@config::repz)))]);
      return 1;
    }
  }
  
#  if (defined $data[0] && $data[0] =~ m/^what(.*?)/i) {
#    my $junk = shift(@data);
#  	learn->whatis($nickname, $channel, join (" ", @data));
#  }
  #if(defined $data[0] && $data[0] =~ m/^$config::triggers(.*?)/i) {
  #	learn->whatis($nickname, $channel, join (" ", @data));
  #}
}

1;

