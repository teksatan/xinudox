#!/usr/bin/perl
# jewgolds module
# fun little game based off trapdoors +internets
# @author wired

package jewgolds;

use strict;
use warnings;
#use threads;
use IO::Socket::INET;
our $version = "1.0 by glitch & wired";

BEGIN {
  commands->add('channel', 'admin', '!jewgolds', 'jewgolds->amount($nickname, $channel);');
  commands->add('channel', 'admin', '!jewadmin', 'jewgolds->jewadmin($nickname, $channel, $parameters);');
  commands->add('channel', 'admin', '!jewkick', 'jewgolds->jewkick($nickname, $channel, $parameters);');
  # commands->add('channel', 'normal', '!jewkill', 'jewgolds->jewkill($nickname, $channel, $parameters);');
  #commands->add('channel', 'normal', '!jewjoin', 'jewgolds->jewjoin($nickname, $channel, $parameters);');
  commands->add('channel', 'admin', '!gamble', ' jewgolds->gamble($nickname, $channel);');
}

sub register {
	my ($nickname, $pass) = ($_[1], $_[2]);
	my $salt = "$$";
	my $enc = crypt($pass, $salt);
	
	open(my $PASS,">db/passwd/$nickname.pass");
	my @pwd = <$PASS>;

	if(@pwd) {
		commands->send("NOTICE $nickname You are already registered $nickname if you forgot your password use !reset\r\n");
	} else {
		print $PASS "$enc";
		close($PASS);
		commands->send("NOTICE $nickname You have registered for jewgolds with the password $pass remember this for later use.\r\n");
	}
}

sub gamble {
	my ($nickname, $channel) = ($_[1], $_[2]);
       if (!defined $users::users{$nickname}->{'loggedin'}) {
         commands->send("NOTICE $nickname : Register with the bot before using !jewgolds. /msg xinudox !register yourpassword");
         return 0;
       }
       elsif ($users::users{$nickname}->{'loggedin'} == 0) {
         commands->send("NOTICE $nickname :Login to the bot first! /msg xinudox !login yourpassword");
         return 0;
       }
	open(my $GOLDIN,"<db/golds/$nickname.gold");
	my $golds = <$GOLDIN>;	
	my $range = 50;
	my $rand = int(rand($range));

	if($rand > 10) {
		commands->send("PRIVMSG $channel Greedy jew \x02$nickname\x02 has gambled and won \x02$rand\x02 jewgolds.\r\n");
		open(my $GOLDOUT,">db/golds/$nickname.gold");
		my $newgold = $golds + $rand;
		print $GOLDOUT "$newgold";
		close($GOLDOUT);
	} 
	if($rand < 10) {
		commands->send("PRIVMSG $channel Greedy jew \x02$nickname\x02 has gambled and lost \x02$rand\x02 jewgolds.\r\n");
		open(my $GOLDOUT,">db/golds/$nickname.gold");
		my $newgold = $golds - $rand;
		print $GOLDOUT "$newgold";
		close($GOLDOUT);
	}
	close($GOLDIN);
}

sub amount {
	my ($nickname, $channel) = ($_[1], $_[2]);
       if (!defined $users::users{$nickname}->{'loggedin'}) {
         commands->send("NOTICE $nickname : Register with the bot before using !jewgolds. /msg xinudox !register yourpassword");
         return 0;
       }
       elsif ($users::users{$nickname}->{'loggedin'} == 0) {
         commands->send("NOTICE $nickname :Login to the bot first! /msg xinudox !login yourpassword");
         return 0;
       }
	open(my $GOLD,"<db/golds/$nickname.gold");
	my $golds = <$GOLD>;

        commands->send("PRIVMSG $channel \x02$nickname\x02 has $golds jewgolds\r\n");
	close($GOLD);
}

sub jewkick {
	my ($nickname, $channel, @reason) = ($_[1], $_[2], split(" ", $_[3]));
       if (!defined $users::users{$nickname}->{'loggedin'}) {
         commands->send("NOTICE $nickname : Register with the bot before using !jewgolds. /msg xinudox !register yourpassword");
         return 0;
       }
       elsif ($users::users{$nickname}->{'loggedin'} == 0) {
         commands->send("NOTICE $nickname :Login to the bot first! /msg xinudox !login yourpassword");
         return 0;
       }
	open(my $GOLD, "<db/golds/$nickname.gold");
	my $gold = <$GOLD>;
	close($GOLD);
	my $amount = 500;
	my $kickuser = shift(@reason);
       my $kickreason = join(" ", @reason);
	$kickuser = $nickname if $kickuser eq $config::nickname;
	if($gold >= $amount) {
		commands->send("PRIVMSG $channel Scummy jewbag \x02$nickname\x02 has enough jewgolds and has issued a kick for \x02$kickuser\x02 deducting $amount jewgolds from \x02$nickname\x02\r\n");
		commands->send("KICK $channel $kickuser Gassed. $kickreason\r\n");
		open(my $GOLDIN,">db/golds/$nickname.gold");
		my $newgold = $gold - $amount;
		print $GOLDIN $newgold;
		close($GOLDIN);
	} else {
		commands->send("PRIVMSG $channel Scummy jewbag \x02$nickname\x02 stop trying to cut corners, get some jewgolds from artwctp to do this.\r\n");
	}
}

sub jewkill {
	my ($nickname, $channel, @reason) = ($_[1], $_[2], split(" ", $_[3]));
       if (!defined $users::users{$nickname}->{'loggedin'}) {
         commands->send("NOTICE $nickname : Register with the bot before using !jewgolds. /msg xinudox !register yourpassword");
         return 0;
       }
       elsif ($users::users{$nickname}->{'loggedin'} == 0) {
         commands->send("NOTICE $nickname :Login to the bot first! /msg xinudox !login yourpassword");
         return 0;
       }
	open(my $GOLD,"<db/golds/$nickname.gold");
	my $gold = <$GOLD>;
	my $amount = 5000;
	my $killuser = shift(@reason);
	$killuser = $nickname if $killuser eq $config::nickname;
	if($gold >= $amount) {
		commands->send("PRIVMSG $channel Dirty jew \x02$nickname\x02 has enough jewgolds and has issued a kill for \x02$killuser\x02 deducting $amount jewgolds from \x02$nickname\x02."); 
		commands->send("KILL $killuser \:Ovened. ". join(" ", @reason));
		open(my $GOLDIN,">db/golds/$nickname.gold");
		my $newgold = $gold - $amount;
		print $GOLDIN "$newgold";
		close($GOLDIN);
	} else {
		commands->send("PRIVMSG $channel Dirty jew \x02$nickname\x02 you do not have enough jewgolds, try and get some from pacifico.");
	}
	close($GOLD);
}

sub jewjoin {
	my ($nickname, $channel, @reason) = ($_[1], $_[2], split(" ", $_[3]));
       if (!defined $users::users{$nickname}->{'loggedin'}) {
         commands->send("NOTICE $nickname : Register with the bot before using !jewgolds. /msg xinudox !register yourpassword");
         return 0;
       }
       elsif ($users::users{$nickname}->{'loggedin'} == 0) {
         commands->send("NOTICE $nickname :Login to the bot first! /msg xinudox !login yourpassword");
         return 0;
       }
	open(my $GOLD,"<db/golds/$nickname.gold");
	my $gold = <$GOLD>;
	my $amount = 1000;
       my $joinuser = $reason[0];
       my $joinchan = $reason[1]; 
       $joinuser = $nickname if $joinuser eq $config::nickname;
	if($gold >= $amount) {
		commands->send("PRIVMSG $channel Dirty jew \x02$nickname\x02 has enough jewgolds and has issued a sajoin for \x02$joinuser\x02 deducting $amount jewgolds from \x02$nickname\x02."); 
		commands->send("SAJOIN $joinuser \:$joinchan");
		open(my $GOLDIN,">db/golds/$nickname.gold");
		my $newgold = $gold - $amount;
		print $GOLDIN "$newgold";
		close($GOLDIN);
	} else {
		commands->send("PRIVMSG $channel Dirty jew \x02$nickname\x02 you do not have enough jewgolds, try and get some from pacifico.");
	}
	close($GOLD);
}

sub jewadmin {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));
       if (!defined $users::users{$nickname}->{'loggedin'}) {
         commands->send("NOTICE $nickname : Register with the bot before using !jewgolds. /msg xinudox !register yourpassword");
         return 0;
       }
       elsif ($users::users{$nickname}->{'loggedin'} == 0) {
         commands->send("NOTICE $nickname :Login to the bot first! /msg xinudox !login yourpassword");
         return 0;
       }
	open(my $GOLD,"<db/golds/$data[2].gold") or my $gold = 0;
	$gold = <$GOLD> if !defined $gold;	
	close($GOLD);
	if($data[0] eq "add") {
		open(my $GOLDIN,">db/golds/$data[2].gold");
		my $newgolds = $gold + $data[1];
		print $GOLDIN "$newgolds";
		commands->send("PRIVMSG $channel Jewadmin \x02$nickname\x02 has given \x02$data[1]\x02 jewgolds to \x02$data[2]\x02");
		close($GOLDIN);
	}
	if($data[0] eq "del") {
		open(my $GOLDIN,">db/golds/$data[2].gold");
		my $newgolds = $gold - $data[1];
		print $GOLDIN "$newgolds";
		commands->send("PRIVMSG $channel Jewadmin \x02$nickname\x02 has deducted \x02$data[1]\x02 jewgolds from \x02$data[2]\x02");
		close($GOLDIN);
	}
}

1;
