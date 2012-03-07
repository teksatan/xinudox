#!/usr/bin/perl

package games;

use strict;
use warnings;
#use threads;
use IO::Socket::INET;
use Switch;

our (%main, %users, %game);
our $version = "1.0 by glitch & wired";

BEGIN {
	commands->add('channel', 'normal', '!games', 'games->parse($nickname, $channel, $parameters);');
}

sub parse {
  my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));
  my $levtype = $data[0];
  my $levnum = $data[1];
  
  switch($levtype) {
  	case '' {
   	commands->send("NOTICE $nickname Usage: !games <levtype> <levnum> Example: !games noob 1 Current level types: noob - skiddie\r\n");
   }
   case 'noob' {
   	games->noob($channel, $levnum, $nickname);
   }
   case 'skiddie' {
   	games->skiddie($channel, $levnum, $nickname);
  	}
  }
}

#my @gmods = <./include/games/*.pm>;
#for my $mod (@gmods) {
#  require $mod;
#}

sub noob {
  my ($channel, $levnum, $nickname) = ($_[1], $_[2], $_[3]);
  	if(!$levnum) {
  		$core::socket->send("NOTICE $nickname Usage: !games <levtype> <levnum> Example: !games noob 1 Current level types: noob - skiddie\r\n");
	}
	if($levnum == 1) {
		$core::socket->send("NOTICE $nickname Welcome to noob level 1 \x02$nickname\x02 find me and voice yourself in the secretz chan for the first challenge.\r\n");
	}
	if($levnum == 2) {
		$core::socket->send("NOTICE $nickname Welcome to noob level 2 \x02$nickname\x02 same thing as last time just move up in access levels whats after voice?\r\n");
	}
	if($levnum == 3) {
		$core::socket->send("NOTICE $nickname Welcome to noob level 3 \x02$nickname\x02 we shall continue this again, move up one final time.\r\n");
	}
	if($levnum == 4) {
		$core::socket->send("NOTICE $nickname Welcome to noob level 4 \x02$nickname\x02 now that you've gained channel operator status, add yourself to the access list using the bot of course\r\n");
	}
	if($levnum == 5) {
		$core::socket->send("NOTICE $nickname Welcome to noob level 5 \x02$nickname\x02 well, we've established certain access levels and you've added yourself to the aop list now, things might get a little deeper dealing with irc modes and channel options, remember the key here is to teach you how to use irc properly. Right now your current goal will be to join and register your own channel and get the bot to join.\r\n");
	}
	if($levnum == 6) {
		$core::socket->send("NOTICE $nickname Welcome to noob level 6 \x02$nickname\x02 now that you have your own channel registered and everything get the bot to handle your requests in your channel, thus meaning you must somehow add your channel to the bots channels list in order to recognize your commands within your channel. Hint! Use .recognize\r\n");
	}
	if($levnum == 7) {
		$core::socket->send("NOTICE $nickname Welcome to noob level 7 \x02$nickname\x02 ok, your channel is recognized now, hang on to that channel because we'll be using it in the future, for now, we'll continue learning a bit more. We've covered channel modes, we're going to be working with something a little more fun in future challenges, but for now, we're covering basics so sorry to the guru's you'll fly through this, level 7 will require topic management, add your name to the topic through the bot, but its not that easy, add yourself to the bots topic handler database, hint .topic & .handlers. GOOD LUCK!\r\n");
	}
}

sub skiddie {
  my ($channel, $levnum, $nickname) = ($_[1], $_[2], $_[3]);
	if($levnum == 1) {
		$core::socket->send("NOTICE $nickname Not done yet..\r\n");
	}
}

sub noobchal {
	my $channel = '#noob_hiding';
	my ($command, $nickname, @sais) = ($_[1], $_[2], $_[3]);

	if($command eq ".voice") {
   	$core::socket->send("MODE $channel +v $nickname\r\n");
     	open(LEVEL,">>logs/games/noob/noob1.log");
      print LEVEL "$nickname\r";
	   close(LEVEL);
	   open(LAST,">logs/games/users/$nickname.log");
	   print LAST "noob 1\r";
		close(LAST);
	}
		
	if($command eq ".halfop") {
	   open(CHECK,"<logs/games/noob/noob1.log");
      my @dat = <CHECK>;
      if(grep(/$nickname/, @dat)) {
      	$core::socket->send("MODE $channel +h $nickname\r\n");
		   open(LEVEL,">>logs/games/noob/noob2.log");
		   print LEVEL "$nickname\r";
		   close(LEVEL);
		   close(CHECK);
		   open(LAST,">logs/games/users/$nickname.log");
		   print LAST "noob 2\r";
		   close(LAST);
		} else {
		     	$core::socket->send("NOTICE $nickname You must complete noob level 1 first noob!\r\n");
		}
	}	                         
	
	if($command eq ".op") {
	   open(CHECK,"<logs/games/noob/noob2.log");
	   my @dat = <CHECK>;
	   if(grep(/$nickname/, @dat)) {
	 	  $core::socket->send("MODE $channel +o $nickname\r\n");
		  open(LEVEL,">>logs/games/noob/noob3.log");
		  print LEVEL "$nickname\r";
		  close(LEVEL);
		  close(CHECK);
		  open(LAST,">logs/games/users/$nickname.log");
		  print LAST "noob 3\r";
		  close(LAST);
		} else {
			$core::socket->send("NOTICE $nickname You must complete noob level 2 first noob!\r\n");
		}
	}                                                                                         
	
	if($command eq ".aop") {
		if($sais[0] eq "add" && $sais[1] == $nickname) {
	 		open(CHECK,"<logs/games/noob/noob3.log");
			my @dat = <CHECK>;
			if(grep(/$nickname/, @dat)) {
				$core::socket->send("PRIVMSG ChanServ :AOP #noob_hiding add $nickname\r\n");
			   open(LEVEL,">>logs/games/noob/noob4.log");
			   print LEVEL "$nickname\r";
			   close(LEVEL);
			   close(CHECK);
			   open(LAST,">logs/games/users/$nickname.log");
			   print LAST "noob 4\r";
			   close(LAST);
			} else {
				$core::socket->send("NOTICE $nickname You must complete noob level 3 first noob!\r\n");
			}
		} else {
			$core::socket->send("NOTICE $nickname Think a little harder, there are two options/arguments here and one must be your nickname.\r\n");
		}
	}
		
	if($command eq ".join") {
	   open(CHECK,"<logs/games/noob/noob4.log");
	   my @dat = <CHECK>;
	   if(grep(/$nickname/, @dat)) {
	  		my $userchan = $sais[0];
	      $core::socket->send("JOIN $userchan\r\n");
	      open(LEVEL, ">>logs/games/noob/noob5.log");
	      print LEVEL "$nickname\r";
	      close(LEVEL);
	      close(CHECK);
	      open(LAST,">logs/games/users/$nickname.log");
	      print LAST "noob 5\r";
	      close(LAST);
	   } else {
	   	$core::socket->send("NOTICE $nickname You must complete noob level 4 first noob!\r\n");
	   }
	}
	
	if($command eq ".recognize") {	   
	   open(CHECK,"<logs/games/noob/noob5.log");
	   my @dat = <CHECK>;
	   if(grep(/$nickname/, @dat)) {
	   	my $userchan = $sais[0];
	      open(RECK,">>logs/recognize.log");
	      print RECK "$userchan $nickname\r";
	      $core::socket->send("NOTICE $nickname channel recognized\r\n");
	      open(LEVEL,">>logs/noob/noob6.log");
	      print LEVEL "$nickname\r";
	      close(LEVEL);
	      close(RECK);
	      close(CHECK);
	      open(LAST,">logs/games/users/$nickname.log");
	      print LAST "noob 6\r";
	      close(LAST);
	   } else {
	   	$core::socket->send("NOTICE $nickname You must complete noob level 5 first noob!\r\n");
	   }
	}
	
	if($command eq ".handlers") {
		my $add = $sais[0];
		if($add != $nickname) {
			$core::socket->send("NOTICE $nickname you're not that person idiot.\r\n");
		} else {	
			open(CHECK,"<logs/games/noob/noob6.log");
			my @dat = <CHECK>;
			if(grep(/$nickname/, @dat)) {
				open(HAND,">>logs/handlers.log");
				print HAND "$add\r";
				close(HAND);
				$core::socket->send("NOTICE $nickname You've been added to the handlers list good job. Now change the topic..\r\n");
				close(CHECK);
			} else {
				$core::socket->send("NOTICE $nickname You must complete noob level 6 first noob!\r\n");
			}		
		}				
	}

	if($command eq ".topic") {
		open(HAND,"<logs/handlers.log");
		my @dat = <HAND>;
		
		if(grep(/$nickname/, @dat)) {
			$core::socket->send("TOPIC #noob_hiding @sais\r\n");
			open(LEVEL,">>logs/noob/noob7.log");
			print LEVEL "$nickname\r";
			close(LEVEL);
			open(LAST,">logs/games/users/$nickname.log");
			print LAST "noob 7\r";
			close(LAST);
			close(HAND);
		} else {
			$core::socket->send("NOTICE $nickname You're not in the handlers list, theres two parts to this challenge figure it out.\r\n");
		}
	}
}

sub status {
	my ($nickname, $channel, @param) = ($_[1], $_[2], split(" ", $_[3]));
	open(my $LEVEL,"<logs/games/users/$nickname.log");
	my $status = <$LEVEL>;
	
	commands->send("PRIVMSG $channel Status for \x02$nickname\x02 is $status\r\n");
	close($LEVEL);
}

1;
