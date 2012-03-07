#!/usr/bin/perl
# xinudox
# basic oper functions
# @author wired & glitch
#######################
package oper;

use strict;
use warnings;
our $version = "1.0 by glitch & wired";

BEGIN {
  commands->add('channel', 'owner', '!sajoin', 'oper->sajoin($nickname, $parameters);');
  commands->add('channel', 'owner', '!kill', 'oper->kill($nickname, $parameters);');
}

sub kill {
	my ($nickname, @data) = ($_[1], split(" ", $_[2]));
	my $username = $data[0];
	$data[0] = '';
	if(!$username) {
		commands->notice($nickname, 'A username is required for a kill.');
		commands->notice($nickname, 'Usage: !kill <username> <reason>');
	} else {
		commands->send("KILL $username @data\r\n");
	}
}

sub sajoin {
	my ($nickname, @data) = ($_[1], split(" ", $_[2]));
	my ($username, $channel, $numeric) = ($data[0], $data[1], $data[3]);
	if(!$username) {
		commands->notice($nickname, 'You are requierd to supply a username.');
		commands->notice($nickname, 'Usage: !sajoin <username> <channel> <numeric>');
	} else {
		if(!$channel) {
			commands->notice($nickname, 'You are required to supply a channel.');
			commands->notice($nickname, 'Usage: !sajoin <username> <channel> <numeric>');
		} else {
			if(!$numeric) {
				commands->notice($nickname, 'A numeric or amount range is a required argument.');
				commands->notice($nickname, 'Usage: !sajoin <username> <channel> <numeric>');
			} else {
				commands->send("SAJOIN $username $channel\r\n");
			}
		}
	}		
}
# adding way more eventually ~wired


1;
