#!/usr/bin/perl
# learn ai module
# @author wired

package learn;

use strict;
use warnings;
#use threads;
use IO::Socket::INET;

our $version = "1.0 by glitch & wired";

BEGIN {
  commands->add('channel', 'normal', '!learn', 'learn->isa($nickname, $channel, $parameters);');
}

sub isa {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));

	open(my $isain, ">>db/ai/isa.db");	
	
	if($data[1] ne "is" && $data[2] ne "a") {
		commands->send("NOTICE $nickname :Incorrect syntax try !learn username is a <comment/insult here>\r\n");
	} else {
		print $isain "@data\n";
		commands->send("NOTICE $nickname :Your comment/insult has been added to the database.\r\n");
		close($isain);
	}
}

sub whatis {
	my ($nickname, $channel, @data) = ($_[1], $_[2], split(" ", $_[3]));
	if($data[0] eq "is") {
		open(my $isaout, "<db/ai/isa.db");
		my @insult = <$isaout>;
		my @grep = grep(/^$data[1]/, @insult);
		my $string = $grep[int rand scalar @grep];
		close($isaout);
		if(!$string) {
			commands->send("PRIVMSG $channel :User \x02$data[1]\x02 does not exist in the database faggot.");
			return 0;
		} else {
			commands->send("PRIVMSG $channel \:$string");
			return 1;
		}
	}
}

#sub randout {
#	my ($nickname, $channel, @data = ($_[1], $_[2], split(" ", $_[3]));
#	
#	open(my $randout, "<db/ai/randout.db");
#	my @out = <$randout>;
#	my @ogrep =	grep(//,);


1;
