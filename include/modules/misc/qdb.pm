#!/usr/bin/perl

package qdb;

use strict;
use warnings;
#use threads;
use IO::Socket::INET;

our $version = "1.0 by glitch & wired";
BEGIN {
  commands->add('channel', 'normal', '!qadd', 'qdb->qadd($nickname, $channel, $parameters);');
  commands->add('channel', 'normal', '!qgrep', 'qdb->qprint($channel, $parameters);');
}
sub qadd {
	my ($nickname, $channel, $quote) = ($_[1], $_[2], $_[3]);
	if($quote !~ /<(.*)>/) {
		commands->msg($channel, 'Not a quote bruh. try using <nickname> text form.'); # lol wired i did it for testing you can change to h/e you want
		return 0;
	} else {
		open(my $QDBIN,">>db/qdb.db");
		print $QDBIN "$quote\n";
		close($QDBIN);
		commands->send("PRIVMSG $channel Quote has been added to database.\r\n");
	}
}

sub qprint {
	my ($channel, $grep) = ($_[1], $_[2]);
       # don't let the bot crash if wildcards are inserted
	$grep =~ s/\*/\\\*/;
       $grep =~ s/\?/\\\?/;
       $grep =~ s/\+/\\\+/;
	open(my $QDBOUT,"<db/qdb.db");
	my @dat = <$QDBOUT>;
	my @grab = grep(/$grep/, @dat);
       for my $line (@grab) {
         commands->send("PRIVMSG $channel \:$line\r\n");
       }
	close($QDBOUT);
}

sub qrandom {
	my ($channel) = ($_[1], $_[2]);
	open(my $QDBOUT,"<db/qdb.db");
	my @dat = <$QDBOUT>;
}	

1;
