#!/usr/bin/perl

#help module by glitch.. and hopefully wired too cuz this is a bitch to code for just one person XD

package help;

use strict;
use warnings;
use Switch;

our $version = "1.0 by glitch & wired";

sub help {
  my ($nickname, @data) = ($_[1], split(" ",$_[2]));
  if (!$data[0]) {
    commands->send("NOTICE $nickname :type !help <subject>, subjects are as follows");
    commands->send("NOTICE $nickname :commands");
    commands->send("NOTICE $nickname :function");
    commands->send("NOTICE $nickname :games");
    commands->send("NOTICE $nickname :admin");
    commands->send("NOTICE $nickname :IRC");
    commands->send("NOTICE $nickname :services");
    commands->send("NOTICE $nickname :Please note that commands are case sensitive.");
    return 1;
  }
  elsif ($data[0] eq 'commands') {
    if (!$data[1]) {
      commands->send("NOTICE $nickname :Type !help commands <command>");
      commands->send("NOTICE $nickname :Bot Owners:");
      commands->send("NOTICE $nickname :\~ !system !e !die !for !user !clean !sql");
      commands->send("NOTICE $nickname :Bot Admin:");
      commands->send("NOTICE $nickname :\~ !raw !rehash !quit !restart !ip !host !whois !pid");
      commands->send("NOTICE $nickname :Bot Moderators:");
      commands->send("NOTICE $nickname :\~ !mode !topic !kick !ban !kb !op !deop !halfop !dehalfop");
      commands->send("NOTICE $nickname :\~ !say !msg !act !desc !join !part !jewadmin");
      commands->send("NOTICE $nickname :Normal Users:");
      commands->send("NOTICE $nickname :\~ !links !sraw !eggdrop !version !games !status !gamble");
      commands->send("NOTICE $nickname :\~ !jewgolds !jewkill !jewkick !qadd !qgrep");
      commands->send("NOTICE $nickname :\~ !vhost !google");
      commands->send("NOTICE $nickname :\~ Query commands:!register !login !logout !passwd");
      commands->send("NOTICE $nickname :\- Please note that this is an unfinished list.");
      return 1;
    }
    elsif ($data[1] eq '!register') {
      commands->send("NOTICE $nickname :Syntax: !register <password> - registers under your current nickname with <password>(passwords are secure and hashed)");
      return 1;
    }
    elsif ($data[1] eq '!login') {
      commands->send("NOTICE $nickname :Syntax: !login <password> - logs in udner your current nickname with <password>");
      return 1;
    }
    elsif ($data[1] eq '!logout') {
      commands->send("NOTICE $nickname :Syntax: !logout - logs you out of your current nickname");
      return 1;
    }
    elsif ($data[1] eq '!passwd') {
      commands->send("NOTICE $nickname :Syntax: !passwd <oldpass> <newpass> - changes the current password under your current nickname");
      return 1;
    }
    elsif ($data[1] eq '!user') {
      commands->send("NOTICE $nickname :Syntax: !user (add|del|update|get|set) [parameters] - updates user information(vague description)");
      return 1;
    }
    elsif ($data[1] eq '!clean') {
      commands->send("NOTICE $nickname :Syntax: !clean (all|users|config|logs) - cleans up corrosponding dir of dirtyness");
      return 1;
    }
    elsif ($data[1] eq '!sql') {
      commands->send("NOTICE $nickname :Syntax: !sql <query> - runs <query> in sql");
      return 1;
    }
    elsif ($data[1] eq '!whois') {
      commands->send("NOTICE $nickname :Syntax: !whois <user> - gets /WHOIS information for <user>");
      return 1;
    }
    elsif ($data[1] eq '!jewadmin') {
      commands->send("NOTICE $nickname :Syntax: !jewadmin (add|del|set) <what> <user> - does exactly what you think it does");
      return 1;
    }
    elsif ($data[1] eq '!links') {
      commands->send("NOTICE $nickname :Syntax: !links - lists links saved in the bot");
      return 1;
    }
    elsif ($data[1] eq '!sraw') {
      commands->send("NOTICE $nickname :Syntax: !sraw <search query> - returns corrosponding RAW numerical information");
      return 1;
    }
    elsif ($data[1] eq '!gamble') {
      commands->send("NOTICE $nickname :Syntax: !gamble - gamble your jewgolds");
      return 1;
    }
    elsif ($data[1] eq '!jewgolds') {
      commands->send("NOTICE $nickname :Syntax: !jewgolds - lists your current jewgold ammount");
      return 1;
    }
    elsif ($data[1] eq '!jewkill') {
      commands->send("NOTICE $nickname :Syntax: !jewkill <user> [reason] - kills <user> with <reason> assuming you have enough jewgolds");
      return 1;
    }
    elsif ($data[1] eq '!jewkick') {
      commands->send("NOTICE $nickname :Syntax: !jewkick <user> [reason] - kicks <user> with <reason> assuming you have enough jewgolds");
      return 1;
    }
    elsif ($data[1] eq '!qadd') {
      commands->send("NOTICE $nickname :Syntax: !qadd '<user>' <text> - adds quote on <user>(note to include the < >) with <text>(do nto include <> in text)");
      return 1;
    }
    elsif ($data[1] eq '!qgrep') {
      commands->send("NOTICE $nickname :Syntax: !qgrep <string> - lists quotes matching <string>");
      return 1;
    }
    elsif ($data[1] eq '!vhost') {
      commands->send("NOTICE $nickname :Syntax: !vhost (set|tmp) <vhost> [user] - sets a static or temp vhost on either yourself or [user]([user] only if your a hostsetter)");
      return 1;
    }
    elsif ($data[1] eq '!system') {
      commands->send("NOTICE $nickname :Syntax: !system <command> - runs a command in linux");
      return 1;
    }
    elsif ($data[1] eq '!pid') {
      commands->send("NOTICE $nickname :Syntax: !pid - returns child pid for the bot");
      return 1;
    }
    elsif ($data[1] eq '!ip') {
      commands->send("NOTICE $nickname :Syntax: !ip <nickname> - returns the realip of <nickname> \(only if nickname is online\))");
      return 1;
    }
    elsif ($data[1] eq '!host') {
      commands->send("NOTICE $nickname :Syntax: !host <nickname> - returns the realhost of <nickname> \(only if nickname is online\)");
      return 1;
    }
    elsif ($data[1] eq '!e') {
      commands->send("NOTICE $nickname :Syntax: !e <code> - evaluates perl code inside the bot(modular)");
      return 1;
    }
    elsif ($data[1] eq '!raw') {
      commands->send("NOTICE $nickname :Syntax: !raw <command> - sends a raw command to the IRC server");
      return 1;
    }
    elsif ($data[1] eq '!quit') {
      commands->send("NOTICE $nickname :Syntax: !quit [reason] - forces the bot to quit then reconnect in 20 minutes(can solve lag issues)");
      return 1;
    }
    elsif ($data[1] eq '!die') {
      commands->send("NOTICE $nickname :Syntax: !die [reason] - force the bot to shutdown");
      return 1;
    }
    elsif ($data[1] eq '!restart') {
      commands->send("NOTICE $nickname :Syntax: !restart [switches] - restart the bot with possible switches:");
      commands->send("NOTICE $nickname :(-l|--log) logging,(-d|--debug) debugging, (-f|--fork) daemonize, -n <nickname> specify nickname, -s <server> specify server.");
      commands->send("NOTICE $nickname :eg. !restart -l -f -d -s irc.anondox.org -n xinutest");
      return 1;
    }
    elsif ($data[1] eq '!for') {
      commands->send("NOTICE $nickname :Syntax: !for <number> <perl command> - execute perl command inside the bot <number> ammount of times");
      return 1;
    }
    elsif ($data[1] eq '!mode') {
      commands->send("NOTICE $nickname :Syntax: !mode [channel] <modes> - set <modes> in either current channel or [channel]");
      return 1;
    }
    elsif ($data[1] eq '!topic') {
      commands->send("NOTICE $nickname :Syntax: !topic [channel] <topic> - set <topic> in either current channel or [channel]");
      return 1;
    }
    elsif ($data[1] eq '!kick') {
      commands->send("NOTICE $nickname :Syntax: !kick [channel] <nick> [reason] - kick <nick> from either current channel or [channel] with a possible [reason]");
      return 1;
    }
    elsif ($data[1] eq '!ban') {
      commands->send("NOTICE $nickname :Syntax: !ban [channel] <mask> - set +b on <mask> in either current channel or [channel]");
      return 1;
    }
    elsif ($data[1] eq '!kb') {
      commands->send("NOTICE $nickname :Syntax: !kb [channel] <nick|mask> [reason] - kickban <nick> or users matching <mask> from either current channel or [channel] with possible [reason]");
      return 1;
    }
    elsif ($data[1] eq '!op') {
      commands->send("NOTICE $nickname :Syntax: !op [nickname] - set mode +o on either yourself or possible [nickname]");
      return 1;
    }
    elsif ($data[1] eq '!deop') {
      commands->send("NOTICE $nickname :Syntax: !deop [nickname] - set mode -o on either yourself or possible [nickname]");
      return 1;
    }
    elsif ($data[1] eq '!halfop') {
      commands->send("NOTICE $nickname :Syntax: !halfop [nickname] - set mode +h on either yourself or possible [nickname]");
      return 1;
    }
    elsif ($data[1] eq '!dehalfop') {
      commands->send("NOTICE $nickname :Syntax: !dehalfop [nickname] - set mode -h on either yourself or possible [nickname]");
      return 1;
    }
    elsif ($data[1] eq '!say') {
      commands->send("NOTICE $nickname :Syntax: !say <text> - make the bot say <text> in current channel");
      return 1;
    }
    elsif ($data[1] eq '!msg') {
      commands->send("NOTICE $nickname :Syntax: !msg <target> <text> - send <text> directly to <target>(can be channel or user)");
      return 1;
    }
    elsif ($data[1] eq '!act') {
      commands->send("NOTICE $nickname :Syntax: !act <text> - make the bot send <text> as a /me to current channel");
      return 1;
    }
    elsif ($data[1] eq '!desc') {
      commands->send("NOTICE $nickname :Syntax: !desc <target> <text> - send <text> to <target> as a /me");
      return 1;
    }
    elsif ($data[1] eq '!info') {
      commands->send("NOTICE $nickname :Syntax: !info [nickname] - get a list of users with information or get a specific [nickname]'s information");
      return 1;
    }
    elsif ($data[1] eq '!status') {
      commands->send("NOTICE $nickname :Syntax: !status [type] - get a list of status types or check the status of specific [type]");
      return 1;
    }
    elsif ($data[1] eq '!google') {
      commands->send("NOTICE $nickname :Syntax: !google [-number] <search> - search google for <search> possibly using -anumber to specify how many results to return");
      return 1;
    }
    elsif ($data[1] eq '!check') {
      commands->send("NOTICE $nickname :Syntax: !check - check for any upcoming anondox/xinudox events");
      return 1;
    }
    elsif ($data[1] eq '!xdcc') {
      commands->send("NOTICE $nickname :Sorry this currently hasn't been implemented yet");
      return 1;
    }
    elsif ($data[1] eq '!eggdrop') {
      commands->send("NOTICE $nickname :Syntax: !eggy or !eggdrop - list information about eggdrops (only works in #eggdrop)");
      return 1;
    }
    else {
      commands->send("NOTICE $nickname :Unknown command help option $data[1] please type !help commands for a list");
      return 0;
    }
  }
  elsif ($data[0] eq 'function') {
    commands->send("NOTICE $nickname :$config::nickname\'s current functions are:");
    commands->send("NOTICE $nickname :Channel moderator");
    commands->send("NOTICE $nickname :Game bot");
    commands->send("NOTICE $nickname :Challenge bot");
    commands->send("NOTICE $nickname :Info bot");
    commands->send("NOTICE $nickname :Google bot");
    commands->send("NOTICE $nickname :and Oper bot");
    return 1;
  }
  elsif ($data[0] eq 'games') { # wired you'll have to fill this one in
    commands->send("NOTICE $nickname :g");
    commands->send("NOTICE $nickname :g");
    commands->send("NOTICE $nickname :g");
    commands->send("NOTICE $nickname :g");
    commands->send("NOTICE $nickname :g");
    commands->send("NOTICE $nickname :g");
    commands->send("NOTICE $nickname :g");
    return 1;
  }
  elsif ($data[0] eq 'admin') {
    if (!$data[1]) {
      commands->send("NOTICE $nickname :Current types of admin to list are:");
      commands->send("NOTICE $nickname :bot");
      commands->send("NOTICE $nickname :IRC");
      commands->send("NOTICE $nickname :website");
      commands->send("NOTICE $nickname :forums");
      commands->send("NOTICE $nickname :#anondox");
      commands->send("NOTICE $nickname :Please note that commands are case sensitive.");
      return 1;
    }
    elsif ($data[1] eq 'bot') {
      my $access = 'normal';
      commands->send("NOTICE $nickname :Current $config::nickname botadmin are:");
      for my $admin (keys %users::users) {
        if (defined $users::users{$admin}->{'mask'}) {
          next if $users::users{$admin}->{'type'} eq 'normal';
          $access = 'owner' if $users::users{$admin}->{'type'} eq 'owner';
          $access = 'admin' if $users::users{$admin}->{'type'} eq 'admin';
          $access = 'op' if $users::users{$admin}->{'type'} eq 'ops';
          commands->send("NOTICE $nickname :$admin \- $access");
        }
      }
      return 1;
    }
    elsif ($data[1] eq 'IRC') {
      commands->send("NOTICE $nickname :Current anondox opers are:");
      commands->send("NOTICE $nickname :wired glitch crazor kiyoura Romnous tak .. theres more but i cba to type them all lol");
      return 1;
    }
    elsif ($data[1] eq 'website') {
      commands->send("NOTICE $nickname :Current anondox website admin are:");
      commands->send("NOTICE $nickname :wired kiyoura glitch");
      return 1;
    }
    elsif ($data[1] eq 'forums') {
      commands->send("NOTICE $nickname :Current anondox forum admin are:");
      commands->send("NOTICE $nickname :wired kiyoura glitch Xe0n");
      return 1;
    }
    elsif ($data[1] eq '#anondox') {
      commands->send("NOTICE $nickname :Please refer to !help admin IRC for a list.");
      return 1;
    }
    else {
      commands->send("NOTICE $nickname :Unknown admin option \'$data[1]\' type !help admin for a list");
      return 0;
    }
  }
  elsif ($data[0] eq 'services') {
    if (!$data[1]) {
      commands->send("NOTICE $nickname :Type !help services <type> current types are:");
      commands->send("NOTICE $nickname :nickserv");
      commands->send("NOTICE $nickname :chanserv");
      commands->send("NOTICE $nickname :botserv");
      commands->send("NOTICE $nickname :hostserv");
      commands->send("NOTICE $nickname :operserv");
      commands->send("NOTICE $nickname :If you spot any errors please inform glitch or wired");
      return 1;
    }
    elsif ($data[1] eq 'nickserv') {
      if (!$data[2]) {
      commands->send("NOTICE $nickname :Type !help services nickserv <type> current types are:");
      commands->send("NOTICE $nickname :register");
      commands->send("NOTICE $nickname :identify");
      commands->send("NOTICE $nickname :group");
      commands->send("NOTICE $nickname :set");
      commands->send("NOTICE $nickname :drop");
      return 1;
      }
      elsif ($data[2] eq 'register') {
        commands->send("NOTICE $nickname :Syntax: /msg nickserv <register> <yourpassword>");
        commands->send("NOTICE $nickname :Make sure the nickname your trying to register isn't already taken");
        return 1;
      }
      elsif ($data[2] eq 'identify') {
        commands->send("NOTICE $nickname :Syntax: /msg nickserv <identify> <yourpassword>");
        return 1;
      }
      elsif ($data[2] eq 'group') {
        commands->send("NOTICE $nickname :Syntax: /msg nickserv group <nickname> <thatnickspassword>");
        return 1;
      }
      elsif ($data[2] eq 'set') {
        commands->send("NOTICE $nickname :Syntax: /msg nickserv set <option> <parameters>");
        commands->send("NOTICE $nickname :Type /msg nickserv help set for a list of available setable options.");
        return 1;
      }
      elsif ($data[2] eq 'drop') {
        commands->send("NOTICE $nickname :Syntax: /msg nickserv drop");
        commands->send("NOTICE $nickname :Make sure your identified to your nick before droping it");
        return 1;
      }
      else {
        commands->send("NOTICE $nickname :Unkown nickserv help option $data[2] type !help services nickserv for a list");
        return 0;
      }
    }
    else {
        commands->send("NOTICE $nickname :Unkown services help option $data[1] type !help services for a list");
        return 0;
    }
  }
  elsif ($data[0] eq 'secret') {
	open(my $FID, "< include/handle/channel.cmd"); 
	my @lines = <$FID>; 
	close $FID; 
	for my $line (@lines) { 
		if ($line =~ m/eq \"\!(.*?)\"/i) { 
			my $cmd = $1; 
			commands->send("NOTICE $nickname \!$cmd"); 
		} 
	}
  }
  elsif ($data[0] eq 'IRC') {
    commands->send("NOTICE $nickname :NOT DONE YET NIGGA!");
    commands->send("NOTICE $nickname :This is gunna house basic IRC command usage");
    commands->send("NOTICE $nickname :g");
    commands->send("NOTICE $nickname :g");
    commands->send("NOTICE $nickname :g");
    commands->send("NOTICE $nickname :g");
    commands->send("NOTICE $nickname :g");
    return 1;
  }
  else {
    commands->send("NOTICE $nickname :Unknown help option $data[0] please type !help for a list");
    return 0;
  }
}

1;
