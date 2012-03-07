#!/usr/bin/perl

package rpg;

use strict;
use warnings;
#use threads;
our $version = "1.1 glitch";

our %rpg;

BEGIN {
 #commands->add('channel', 'normal', '!rpg', 'rpg::system::rpg($nickname, $ident, $vhost, $channel, $parameters)');
 commands->add('channel', 'owner', '!listshit', 'rpg->listshit()');
 commands->add('channel', 'normal', '!glitch', 'commands->msg($channel, "glitch <3 kerrie")');
}


#do config vars here kthnx. glitch
our $starttime = localtime();
our $ticks = 0;
our $id = 0;
our $server = 'Anondox RPG';
our @admin = qw(wired glitch);
our $start_map = "anondox"; #weird but meh

#rpg::map->load($start_map."map");

#mmhmm


