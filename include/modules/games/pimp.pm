#!/usr/bin/perl
# lol pimp game module mang
# @author wired
#############################
package pimp;

use strict;
use warnings;
use Switch;

our $version = "1.0 by wired";

our @nobitch = ("wired", "glitch");

BEGIN {
	commands->add('channel', 'normal', '!pimp', 'pimp->pimps($nickname, $channel, $parameters);');
	commands->add('channel', 'normal', '!addbitch', 'pimp->addbitch($nickname, $channel, $parameters);');
	commands->add('channel', 'normal', '!addpimp', 'pimp->addpimp($nickname, $channel, $parameters);');
	commands->add('channel', 'normal', '!bitch', 'pimp->bitches($nickname, $channel, $parameters);');
	commands->add('channel', 'normal', '!buyho', 'pimp->buyho($nickname, $channel, $parameters);');
	commands->add('channel', 'normal', '!collect', 'pimp->collect($nickname, $channel, $parameters);');
	commands->add('channel', 'normal', '!pimpslap', 'pimp->slap($nickname, $channel, $parameters);');
}
        
sub bitches {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));

	if($data[0] eq "list") {	
		open(my $bitchout, "<db/pimp/bitches.db");
		my @bitches = <$bitchout>;
		close($bitchout);
		commands->send("NOTICE $nickname :Current bitches:\r\n");
		foreach my $bitch (@bitches) {
			commands->send("NOTICE $nickname :$bitch\r\n");
		}
	}
	if($data[0] eq "money") {
		open(my $bmoney, "<db/pimp/money/bitches/$nickname.money");
		my $money = <$bmoney>;
		close($bmoney);
		
		if(!$money) {
			commands->msg($channel, 'You aint a bitch '.$nickname.'');
		}
		if($money < 0) {
			commands->msg($channel, 'Yo '.$nickname.' you are a broke ass bitch, get your money right ho, you have '.$money.'');
		} 
		if($money > 0) {
			commands->msg($channel, 'Yo '.$nickname.' get your slut on bitch, you have '.$money.'');
		}
	}
}

sub pimps {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));
	
	if($data[0] eq "list") {
		open(my $pimpout, "<db/pimp/pimps.db");
		my @pimps = <$pimpout>;
		close($pimpout);
		commands->send("NOTICE $nickname :Current pimps:\r\n");
		foreach my $pimp (@pimps) {
			commands->send("NOTICE $nickname :$pimp\r\n");
		}
	}
  
   if($data[0] eq "money") {
	   open(my $pmoney, "<db/pimp/money/$nickname.money");
      my $money = <$pmoney>;
      close($pmoney);
	       
	   if(!$money) {
	   	commands->msg($channel, 'You aint a pimp '.$nickname.'');
	   }              
      if($money < 0) {
		   commands->msg($channel, 'Yo '.$nickname.' you are a broke ass pimp, get your money right, you have '.$money.'');
	   }
	   
	   if($money > 0) {
	   	commands->msg($channel, 'Yo '.$nickname.' get your pimpin on money, you have '.$money.'');
	   }
	}
}

sub addbitch {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));
	
	open(my $pimplist, "<db/pimp/pimps.db");
	my @pimps = <$pimplist>;
	my $pgrep = grep(/$nickname/, @pimps);
	close($pimplist);

	if($pgrep) {
		open(my $bitchout, "<db/pimp/bitches.db");
		my @bitches = <$bitchout>;
		my $grep = grep(/$data[0]/, @bitches);
	
		if($data[0] eq $nobitch[0]) {
			commands->send("KILL $nickname :DON'T BE KILLIN THE PIMP LORDS PLAYA.\r\n");
		}
		if($data[0] eq $nobitch[1]) {
			commands->send("KILL $nickname :DON'T BE KILLIN THE PIMP LORDS PLAYA.\r\n");
		}

		if($grep) {
			commands->msg($channel, 'Bitch already exists playa.');
		}

		if(!$grep) {
			open(my $bitchin, ">>db/pimp/bitches.db");
			print $bitchin "\n$data[0]\r";
			close($bitchin);
			commands->msg($channel, 'Added '.$data[0].' to bitch list.');
		}
	}
	
	if(!$pgrep) {
		commands->msg($channel, 'You not a pimp bitch, you aint got love for the gwap.');
	}
}

sub addpimp {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));
	
	open(my $pimplist, "<db/pimp/pimps.db");
	my @pimps = <$pimplist>;
	my $pgrep = grep(/$nickname/, @pimps);
	close($pimplist);
	
	if($pgrep) {
		my $check = grep(/$data[0]/, @pimps);
		
		if($check) {
			commands->msg($channel, 'Pimp exists bitch. Been pimpin since been pimpin since been pimpin playa.');
		}
		if(!$check) {
			open(my $pimpout, ">>db/pimp/pimps.db");
			print $pimpout "$data[0]\r\n";
			close($pimpout);
			open(my $pmoneyout, ">db/pimp/money/$data[0].money");
			print $pmoneyout "1";
			close($pmoneyout);

			commands->msg($channel, 'Pimp added playa. Keep doin yo thang.');
		}
	}
	
	if(!$pgrep) {
		commands->msg($channel, 'You not a pimp bitch, you aint got love for the gwap.');
	}
}

sub buyho {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));
 
   if (!defined $users::users{$nickname}->{'loggedin'}) {
   	commands->send("NOTICE $nickname : Register with the bot before using !jewgolds. /msg xinudox !register yourpassword");
	   return 0;
	}
	elsif ($users::users{$nickname}->{'loggedin'} == 0) {
		commands->send("NOTICE $nickname :Login to the bot first! /msg xinudox !login yourpassword");
	   return 0;
	}
	
	open(my $pimplist, "<db/pimp/pimps.db");
	my @pimps = <$pimplist>;
	my $pgrep = grep(/$nickname/, @pimps);
	close($pimplist);
	
	if($pgrep) {
		my @sexacts = (
			'sucks you off until you are dry.',
			'gives you a cleveland steamer.',
			'takes your dick in her anal all night long.',
			'swallows your entire load and begs for more.'
		);

		my $range = 50;
		my $rand = int(rand($range));
		open(my $moneyin, "<db/pimp/money/$nickname.money");
		my $money = <$moneyin>;
		
		open(my $bitchin, "<db/pimp/bitches.db");
		my @bitches = <$bitchin>;
		my $brand = rand(@bitches);
		close($bitchin);
		open(my $bpaperin, "<db/pimp/money/bitches/$data[0].money");
		my $bmoney = <$bpaperin>;
		close($bpaperin);
	
		if($rand > 15) {
			commands->msg($channel, 'Yea playa, you bought that ho '.$data[0].' for $'.$rand.' and she '.$sexacts[int rand scalar @sexacts].'');
			open(my $moneyout, ">db/pimp/money/$nickname.money");
			my $newpaper = $money - $rand;
			print $moneyout "$newpaper";
			close($moneyout);
			open(my $bpaper, ">db/pimp/money/bitches/$data[0].money");
			my $newbpaper = $bmoney + $rand;
			print $bpaper "$newbpaper";
			close($bpaper);
		}
	}
	
	if(!$pgrep) {
		commands->msg($channel, 'You dont be pimpin playa fuck yoself and yo tranny hos.');
	}
}

sub collect {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));

   if (!defined $users::users{$nickname}->{'loggedin'}) {
	   commands->send("NOTICE $nickname : Register with the bot before using !jewgolds. /msg xinudox !register yourpassword");
	   return 0;
	}
	elsif ($users::users{$nickname}->{'loggedin'} == 0) {
		commands->send("NOTICE $nickname :Login to the bot first! /msg xinudox !login yourpassword");
	   return 0;
	}	                                                                

	open(my $pimplist, "<db/pimp/pimps.db");
	my @pimps = <$pimplist>;
	my $pgrep = grep(/$nickname/, @pimps);
	close($pimplist);
	
	
	if($pgrep) {
		my $range = 50;
		my $rand = int(rand($range));
		open(my $moneyin, "<db/pimp/money/$nickname.money");
		my $money = <$moneyin>;
		
		if($rand > 15) {
			commands->msg($channel, 'Playa '.$nickname.' you track down your hos and collect your papers you earned $'.$rand.', get that money pimpin.');
			open(my $moneyout, ">db/pimp/money/$nickname.money");
			my $newpaper = $money + $rand;
			print $moneyout "$newpaper";
			close($moneyout);
		}
		
		if($rand < 15) {
			commands->msg($channel, 'Playa '.$nickname.' you were out pimpin and some crack heads fucked you up you lost $'.$rand.', sucks to be you pimpin.');
			open(my $moneyout, ">db/pimp/money/$nickname.money");
			my $newpaper = $money - $rand;
			print $moneyout "$newpaper";
			close($moneyout);
		}
		
		close($moneyin);
	}
	
	if(!$pgrep) {
		commands->msg($channel, 'You aint pimpin playa, ask a real pimp to add you.');
	}
}

sub slap {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));
	
	if($data[0]) {
		commands->msg($channel, ''.$nickname.' lays down the pimp hand on '.$data[0].'');
		commands->send("KICK $channel $data[0] :How does it feel to be a bitch playa?"); 
	}
}

1;

