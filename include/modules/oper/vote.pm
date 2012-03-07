#!/usr/bin/perl
# oper vote system
# @author wired
#####################
package vote;

use strict;
use warnings;

our $version = "1.0 by wired";

BEGIN {
	commands->add('channel', 'normal', '!vcheck', 'vote->check($channel, $nickname, $parameters);');
	commands->add('channel', 'normal', '!vadd', 'vote->add($channel, $nickname, $parameters);');
	commands->add('channel', 'normal', '!vote', 'vote->voters($channel, $nickname, $parameters);');
	commands->add('channel', 'normal', '!vlist', 'vote->list($channel, $nickname, $parameters);');
}
    
sub check {
	my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
	
	if($channel eq "#oper") {
		open(my $votein, "<db/vote/last.vote");
		my $vdat = <$votein>;
		close($votein);
		
		commands->msg($channel, 'Current vote: '.$vdat.'');
	}
}

sub add {
	my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
	
	if($channel eq "#oper") {
		open(my $voteout, ">db/vote/last.vote");
		print $voteout "@data added by $nickname";
		close($voteout);
		my $rm = "cp db/vote/voters.vote db/vote/voters.old ; rm db/vote/voters.vote";
		system($rm);
		commands->msg($channel, 'Vote added.');
	}
}

sub voters {
	my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
	
	if($channel eq "#oper") {
		if($data[0] == 1) {
			open(my $check, "<db/vote/voters.vote");
			my @cvoter = <$check>;
			my $grep = grep(/$nickname/, @cvoter);
			close($check);
			
			if($grep) {
				commands->notice($nickname, 'Username already exists in voters database.');
			}
			
			open(my $voters, ">>db/vote/voters.vote");
			print $voters "$nickname\r\n";
			close($voters);
		
			commands->msg($channel, 'Added '.$nickname.' to the vote list.');
		}
		
		if(!$data[0]) {
			commands->msg($channel, 'To add yourself to the voters list for the current vote simply execute !vote 1, else do not vote.');
		}	
	}
}

sub list {
	my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
	
	if($channel eq "#oper") {
		open(my $voterin, "<db/vote/voters.vote");
		my @voters = <$voterin>;
				
		commands->msg($channel, 'Current voter list: (the following users vote yes to the current vote)');
		
		foreach my $voter (@voters) {
			commands->send("PRIVMSG $channel :$voter\r\n"); 
		}
		close($voterin);
	}
}

1;
