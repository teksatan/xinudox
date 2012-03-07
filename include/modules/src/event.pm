#!/usr/bin/perl 

package event;

use strict;
use warnings;

our $version = '1.0 glitch & wired';
our %event;
commands->add('channel', 'owner', '!eventlist', 'event->list($channel, $nickname, shift(@data), join(" ", @data))');

# event types are. join, part, kick, ban, mode, raw, oper, channtc, chanmsg, userntc, usermsg, chanaction, useraction,
# topic, netsplit, bans, help, connect, disconnect, shutdown, die

our $types = 'join part kick ban mode raw oper channtc chanmsg userntc usermsg chanaction useraction topic netsplit bans help connect disconnect shutdown die';

sub add {
  my ($channel, $nickname, $type, $target, $regex, $action) = ($_[1], $_[2], $_[3], $_[4], $_[5], $_[6]);
  if (!defined $action) {
    commands->msg($channel, "Syntax: !event add <type> <target> <regex> <action>") if $channel ne '*';
    return 0;
  }
  if ($types !~ /$type/) {
    commands->msg($channel, "Incorrect \"TYPE\", Must be one of: $types") if $channel ne '*';
    return 0;
  }
  else {
   $event{$type}->{'target'} = $target;
   $event{$type}->{'regex'} = $regex;
   $event{$type}->{'action'} = $action;
    return $regex;
  }
}

sub list {
  my ($channel, $nickname, $type, $regex) = ($_[1], $_[2], $_[3], $_[4] || return '(.*?)');
  if ($types !~ /$type/) {
    commands->msg($channel, "Incorrect \"TYPE\", Must be one of: $types") if $channel ne '*';
    return 0;
  }
  for my $key (sort keys %{$event{$type}}) {
     if ($event{$type}->{'regex'} =~ m/$regex/i) {
       commands->msg($channel, $key."\-\>".$event{$type}->{$key})
     }
   }
}



1;