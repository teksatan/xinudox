#!/usr/bin/perl
# anondox.com todo list module
# @author wired
#####################
package todo;

use strict;
use warnings;

our $version = "1.0 by wired";

BEGIN {
	commands->add('channel', 'normal', '!todo', 'todo->main($channel, $nickname, $parameters);');
}

sub main {
	my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
	
	if(!$data[0]) {
		commands->msg($channel, 'Usage: !todo add <category> details | !todo list');
	}
	
	if($data[0] eq "add") {
		$data[0] = '';
		my $category = $data[1];		
		$data[1] = '';
		open(my $tout, ">>db/todo.db");
		print $tout "#"x50;
		print "\n";
		print $tout "# ".$category." | ".@data." | Added by ".$nickname."\n";
	   print $tout "#"x50;
	   print "\n";
    	close($tout);
    	commands->msg($channel, 'Added '.@data.' to the todo list.');
    }
    
    if($data[0] eq "list") {
    	open(my $tin, "<db/todo.db");
    	my @tlist = <$tin>;
    	
    	foreach my $item (@tlist) {
    		commands->msg($channel, $item);
    	}
    	close($tin);
    }
}

1;
