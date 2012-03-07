#!/usr/bin/perl

package query;

use strict;
use warnings;
use Switch;
#use threads;
use File::stat;
use POSIX;
use Digest::MD5;

our %cmd;

sub parse {
  my ($access, $nickname, $ident, $vhost, @message) = ($_[1], $_[2], $_[3], $_[4], split (" ", $_[5]));
  my ($command, $parameters) = (shift(@message), join(" ", @message));
  #parse CTCP requests here
  if ($command eq "VERSION") {
    commands->send("NOTICE $nickname :VERSION ". $config::versionreply[int rand scalar @config::versionreply] . "");
  }
  if ($command eq "PING") {
    commands->send("NOTICE $nickname go get phucked $nickname");
  }
  if ($command eq "TIME") {
    commands->send("NOTICE $nickname :TIME ". localtime() . " bitch");
  }
  
  #parse query commands here!
  if ($access eq 'owner') { # bot owner
    if (defined $cmd{'owner'}->{$command}) {
      eval($cmd{'owner'}->{$command});
    }
  }
  if ($access eq 'owner' || $access eq 'admin') { #bot admin
    if (defined $cmd{'admin'}->{$command}) {
      eval($cmd{'admin'}->{$command});
    }
  }
  if ($access eq 'owner' || $access eq 'admin' || $access eq 'ops') { #bot ops
    if (defined $cmd{'ops'}->{$command}) {
      eval($cmd{'ops'}->{$command});
    }
  }
  if ($access eq 'owner' || $access eq 'admin' || $access eq 'ops' || $access eq 'normal') { #normal users
    if ($command eq '!register') {
      return 0 if !$message[0];
      if (defined $users::users{$nickname}->{'password'}) {
        commands->send("PRIVMSG $nickname :the user $nickname is already registered in the bot");
        return 0;
      }
      else {
        my $password = Digest::MD5::md5_hex(crypt($message[0],$config::salt));
        users->register($nickname, $ident, $vhost, $password);
        commands->send("PRIVMSG $nickname :Nickname $nickname registered with password $message[0]\. Don't forget it!");
        users->save();
      }
    }
    if ($command eq '!login') {
      return 0 if !$message[0];
      my $hashpass = Digest::MD5::md5_hex(crypt($message[0],$config::salt));
      if (!defined $users::users{$nickname}->{'password'}) {
        commands->send("PRIVMSG $nickname :You aren't registered! please type !register <yourpassword> note not to actually use the < and > in the password");
        return 0;
      }
      if ($users::users{$nickname}->{'loggedin'} == 1) {
        commands->send("PRIVMSG $nickname :Your already logged in from ".$users::users{$nickname}->{'mask'});
        return 0;
      }
      if ($users::users{$nickname}->{'password'} eq $hashpass) {
        
        $users::users{$nickname}->{'loggedin'} = 1;
        $users::users{$nickname}->{'mask'} = "$nickname\!$ident\@$vhost";
        commands->send("PRIVMSG $nickname :Logged in under $nickname \(". $users::users{$nickname}->{'mask'} ."\)");
        return 1;
      }
      else {
        commands->send("PRIVMSG $nickname :login failed.(logged)");
        return 0; 
      }
    }
    if ($command eq '!logout') {
      if (!$message[0]) {
        users->logout($nickname);
        commands->send("PRIVMSG $nickname :Logged out from $nickname");
        return 1;
      }
      elsif (defined $message[0] && $message[0] ne 'all' && $access eq 'owner') {
        users->logout($message[0]);
        commands->send("PRIVMSG $nickname :Forced $message[0] to log out");
        return 1;
      }
      elsif (defined $message[0] && $message[0] eq 'all' && $access eq 'owner') {
        users->logout('all');
        commands->send("PRIVMSG $nickname :Forced all users to log out");
        return 1;
      }
    }
    if ($command eq '!lemmein') {
      commands->send("INVITE $nickname #abuse");
    }
    if ($command eq '!kick' && $message[0] ne $config::nickname) {
      commands->send("KICK #abuse $parameters");
    }
    if ($command eq '!kb' && $message[0] ne $config::nickname) {
      commands->send("MODE #abuse +b $message[0]\!\*\@\*\r\nKICK #abuse $parameters");
    }
    if ($command eq '!passwd') {
      if (!defined $users::users{$nickname}->{'password'}) {
        commands->send("PRIVMSG $nickname :You aren't registered! please type !register <yourpassword> note not to actually use the < and > in the password");
        return 0;
      }
      if (!$message[1]) {
        commands->send("PRIVMSG $nickname :Syntax !passwd <oldpassword> <newpassword>");
        return 0;
      }
      if ($users::users{$nickname}->{'password'} ne Digest::MD5::md5_hex(crypt($message[0],$config::salt))) {
        commands->send("PRIVMSG $nickname :Incorrect password(logged)");
        return 0;
      }
      sql->conn();
      my $newpass = Digest::MD5::md5_hex(crypt($message[1],$config::salt));
      sql->do("UPDATE users SET password = ".sql->quote($newpass)." WHERE nickname = ".sql->quote($nickname));
      $users::users{$nickname}->{'password'} = $newpass;
      sql->close();
      commands->send("PRIVMSG $nickname :Password changed to-\>$message[1]");
      return 1;
    }
    elsif (defined $cmd{'normal'}->{$command}) {
      eval($cmd{'normal'}->{$command});
    }
  }
}
1;
