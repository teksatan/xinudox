#!/usr/bin/perl
# drug dealing/hustler irc game
# for xinudox
# @authors wired & glitch
#wired changing package names


package kingpin;

use strict;
use warnings;
#use diagnostics;
#use threads;
use Switch;
use IO::Socket::INET;
our $version = "1.0 by glitch & wired";

BEGIN {
  commands->add('channel', 'normal', '!kingpin', 'kingpin->start($nickname, $channel, $parameters);');
  commands->add('channel', 'normal', '!buy', 'kingpin->buy($nickname, $channel, $parameters);');
  commands->add('channel', 'normal', '!sell', 'kingpin->sell($nickname, $channel, $parameters);');
  commands->add('channel', 'normal', '!city', 'kingpin->city($nickname, $channel, $parameters);');
}

our @drugs = qw(marijuana heroin cocaine crack acid meth pills xtc);
our @guns = qw(Baretta .45 38special Ruger Shotgun AK MP5);
our @cities = qw(Boston NY Chicago Detroit LA Vegas);
our @property = ('strip club', 'bar', 'corner store', 'casino', 'laundrymat', 'pizza shop', 'record dealer');
our @whips = ('benz', 'beamer', 'corvette', 'jaguar', 'lambo', 'skyline');
our @ranks = ('Bum', 'Thief', 'Struggler', 'Petty Hustler', 'Nine Fiver', 'Hustler', 'Baller', 'Kingpin');

sub rcity { return $cities[int rand scalar @cities]; }


sub rpass {
	my $pass;
	my $rand;
	my $length = 10;
	my @chars = split(" ", "a b c d e f g h i j k l m n o p q r s t u v w x y z - _ % ! # | 0 1 2 3 4 5 6 7 8 9");
	srand;
	for (my $i=0; $i <= $length; $i++) {
		$rand = int(rand 41);
		$pass .= $chars[$rand];
	}
	return $pass;
}	

sub start {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));
	      
	kingsql->conn();
	kingsql->ucheck($nickname);
#	kingsql->incity($nickname);
	kingsql->close();
	
}	


sub city {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));
	
	if($data[0]) {	
		kingsql->conn();
		kingsql->incity($nickname, $data[0]);
		kingsql->close();

		switch($data[0]) {
			case "Boston" {
				commands->send("NOTICE $nickname :You catch a plane to $data[0] enjoy your stay in bean town and hustle hard.\r\n");
			}
			case "NY" {
				commands->send("NOTICE $nickname :You fly to $data[0] get your dough up in the big apple.\r\n");
			}
			case "Chicago" {
				commands->send("NOTICE $nickname :You land in $data[0] lets see what you got in the windy city welcome to chi town bruh.\r\n");
			}
			case "Detroit" {
				commands->send("NOTICE $nickname :You soar to $data[0] you see a sign \x02Welcome to Rock City\x02 try and establish your hustle playa.\r\n");
			}
			case "LA" {
				commands->send("NOTICE $nickname :Jetblue takes you to $data[0] welcome to cali mang, try to avoid the mexican mafia.\r\n");
			}
			case "Vegas" {
				commands->send("NOTICE $nickname :You have arrived in $data[0] what happens in Vegas stays in Vegas go all out for this money mang.\r\n");
			}
		}
	} else {
		kingsql->conn();
		kingsql->outcity($nickname);
		kingsql->close();
		commands->send("NOTICE $nickname :Cities: @cities\r\n");
	}	
}

sub buy {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));
	
		# range values
		my $potrange = int(rand(1000));
		my $hrange = int(rand(17000));
		my $cokerange = int(rand(28000));
		my $crackrange = int(rand(10000));
		my $cidrange = int(rand(5000));
		my $methrange = int(rand(8000));
		my $pillrange = int(rand(800));
		my $xtcrange = int(rand(1000));
		my $grange = int(rand(5000));
		my $bitchrange = int(rand(3000));
		my $proprange = int(rand(100000));
		my $reprange = int(rand(1000));
		
		switch($data[0]) {
			case 'drugs' {
				if(!$data[1]) {
					commands->send("NOTICE $nickname :\x02\x033Drugs for sale\x02\x033 | $potrange $drugs[0] | $hrange $drugs[1] | $cokerange $drugs[2] | $cidrange $drugs[3] | $methrange $drugs[4] | $pillrange $drugs[5] | $xtcrange $drugs[6]\r\n");
	#				kingsql->conn();
	#				kingsql->dranges($nickname, $potrange, $hrange, $cokerange, $cidrange, $methrange, $crackrange, $pillrange, $xtcrange);
	#				kingsql->close();
					switch($data[1]) {
						case 'marijuana' {
							kingsql->conn();
							kingsql->indrug($nickname, $data[1], $potrange, $data[2]);
							kingsql->close();
							commands->notice($nickname, 'You purchase 1 unit of marijuana for $potrange');
						}
					}														
				} 
			}
		}
					
		if(!$data[0]) {
			commands->send("NOTICE $nickname :Usage: !buy <merchandise> <type> <amount> | merchandise: drugs, whips, property, guns, bitches | types: \x02drugs\x02->$drugs[0], $drugs[1], $drugs[2], $drugs[3], $drugs[4], $drugs[5], $drugs[6], $drugs[7] \x02whips\x02->$whips[0], $whips[1], $whips[2], $whips[3], $whips[4], $whips[5] \x02properties\x02->$property[0], $property[1], $property[2], $property[3], $property[4], $property[5], $property[6] \x02guns\x02->$guns[0], $guns[1], $guns[2], $guns[3], $guns[4], $guns[5], $guns[6]\r\n");
		}
}


#			commands->send("NOTICE $nickname :Yo $nickname you have $moneydat funds.\r\n");
#			commands->send("NOTICE $nickname :You have $potdat Marijuana $hdat heroin $yaydat cocaine $crackdat crack $ciddat acid $methdat meth $pilldat pills $xtcdat XTC in your stash, for guns, $bitchdat for bitches, $stripdat strip clubs $bardat bars for property and $repdat reputation.\r\n");
#			commands->send("NOTICE $nickname :!buy drugs <drugname> | !buy guns <gunname> | !buy bitch | !buy property <propname>\r\n");
#				commands->send("NOTICE $nickname :\x02\x033Drugs for sale\x02\x033 | $potrange $drugs[0] | $hrange $drugs[1] | $cokerange $drugs[2] | $cidrange $drugs[3] | $methrange $drugs[4] | $pillrange $drugs[5] | $xtcrange $drugs[6]\r\n");
	#	commands->send("NOTICE $nickname :\x02\x034Guns for sale\x02\x033 | @gunrange $guns[0] | @gunrange $guns[1] | @gunrange $guns[2] | @gunrange $guns[3] | @gunrange $guns[4] | @gunrange $guns[5] | @gunrange $guns[6]\r\n");
	#	commands->send("NOTICE $nickname :Want to buy a bitch? | @bitchrange for a bitch.\r\n");
	#	commands->send("NOTICE $nickname :Properties on the market | @proprange $prop[0] | @proprange $prop[1] | @proprange $prop[2] | @proprange $prop[3] | @proprange $prop[4] | @potrange $prop[5] | @potrange $prop[6]\r\n");


our %col = (
  0 => "0",
  1 => "1",
  2 => "2",
  3 => "3",
  4 => "4",
  5 => "5",
  6 => "6",
  7 => "7",
  8 => "8",
  9 => "9",
  10 => "10",
  11 => "11",
  12 => "12",
  13 => "13",
  14 => "14",
  15 => "15",
  x => "");
  
#sub rcity { return $cities[int rand scalar @cities]; }
sub msg {
  my ($target, $msg) = ($_[1], $_[2]);
  return 0 if !defined $msg;
  commands->send("PRIVMSG $target :kingpin-> $msg");
}

sub ntc {
  my ($target, $msg) = ($_[1], $_[2]);
  return 0 if !defined $msg;
  commands->send("NOTICE $target :".$col{12}."kingpin".$col{x}."-> $msg");
}


1;
