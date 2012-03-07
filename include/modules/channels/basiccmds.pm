#!/usr/bin/perl

package basiccmds;

use strict;
use warnings;


our $version = "1.0 glitch & wired";

BEGIN {
  commands->add('channel', 'ops', '!voice', 'basiccmds->voice($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!devoice', 'basiccmds->devoice($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!op', 'basiccmds->op($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!deop', 'basiccmds->deop($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!halfop', 'basiccmds->halfop($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!dehalfop', 'basiccmds->dehalfop($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!protect', 'basiccmds->protect($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!deprotect', 'basiccmds->deprotect($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!owner', 'basiccmds->owner($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!deowner', 'basiccmds->deowner($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!mode', 'basiccmds->mode($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!k', 'basiccmds->kick($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!kb', 'basiccmds->kickban($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!+b', 'basiccmds->ban($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!-b', 'basiccmds->unban($parameters)');
  commands->add('channel', 'ops', '!kick', 'basiccmds->kick($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!kickban', 'basiccmds->kickban($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!ban', 'basiccmds->ban($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!unban', 'basiccmds->unban($parameters)');
  commands->add('channel', 'ops', '!topic', 'basiccmds->topic($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!msg', 'basiccmds->msg($channel, $nickname, $parameters)');
  commands->add('channel', 'normal', '!say', 'basiccmds->say($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!notice', 'basiccmds->notice($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!act', 'basiccmds->act($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!describe', 'basiccmds->describe($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!cycle', 'basiccmds->cycle($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!cs', 'basiccmds->chanserv($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!ns', 'basiccmds->nickserv($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!hs', 'basiccmds->hostserv($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!ms', 'basiccmds->memoserv($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!lock', 'basiccmds->lock($channel, $nickname, $parameters)');
  commands->add('channel', 'ops', '!unlock', 'basiccmds->unlock($channel, $nickname, $parameters)');
}

sub voice {
  my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
  if (defined $data[0] && $data[0] !~ /^\#(.*?)$/ && !defined $data[1]) {
    $nickname = $data[0];
  }
  elsif (defined $data[1] && $data[0] =~ /^\#(.*?)$/) {
    ($channel, $nickname) = ($data[0], $data[1]);
  }
  commands->send("MODE $channel +v $nickname");
}

sub devoice {
  my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
  if (defined $data[0] && $data[0] !~ /^\#(.*?)$/ && !defined $data[1]) {
    $nickname = $data[0];
  }
  elsif (defined $data[1] && $data[0] =~ /^\#(.*?)$/) {
    ($channel, $nickname) = ($data[0], $data[1]);
  }
  commands->send("MODE $channel -v $nickname");
}

sub op {
  my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
  if (defined $data[0] && $data[0] !~ /^\#(.*?)$/ && !defined $data[1]) {
    $nickname = $data[0];
  }
  elsif (defined $data[1] && $data[0] =~ /^\#(.*?)$/) {
    ($channel, $nickname) = ($data[0], $data[1]);
  }
  commands->send("MODE $channel +o $nickname");
}

sub deop {
  my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
  if (defined $data[0] && $data[0] !~ /^\#(.*?)$/ && !defined $data[1]) {
    $nickname = $data[0];
  }
  elsif (defined $data[1] && $data[0] =~ /^\#(.*?)$/) {
    ($channel, $nickname) = ($data[0], $data[1]);
  }
  commands->send("MODE $channel -o $nickname");
}

sub halfop {
  my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
  if (defined $data[0] && $data[0] !~ /^\#(.*?)$/ && !defined $data[1]) {
    $nickname = $data[0];
  }
  elsif (defined $data[1] && $data[0] =~ /^\#(.*?)$/) {
    ($channel, $nickname) = ($data[0], $data[1]);
  }
  commands->send("MODE $channel +h $nickname");
}

sub dehalfop {
  my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
  if (defined $data[0] && $data[0] !~ /^\#(.*?)$/ && !defined $data[1]) {
    $nickname = $data[0];
  }
  elsif (defined $data[1] && $data[0] =~ /^\#(.*?)$/) {
    ($channel, $nickname) = ($data[0], $data[1]);
  }
  commands->send("MODE $channel -h $nickname");
}

sub protect {
  my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
  if (defined $data[0] && $data[0] !~ /^\#(.*?)$/ && !defined $data[1]) {
    $nickname = $data[0];
  }
  elsif (defined $data[1] && $data[0] =~ /^\#(.*?)$/) {
    ($channel, $nickname) = ($data[0], $data[1]);
  }
  commands->send("MODE $channel +a $nickname");
}

sub deprotect {
  my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
  if (defined $data[0] && $data[0] !~ /^\#(.*?)$/ && !defined $data[1]) {
    $nickname = $data[0];
  }
  elsif (defined $data[1] && $data[0] =~ /^\#(.*?)$/) {
    ($channel, $nickname) = ($data[0], $data[1]);
  }
  commands->send("MODE $channel -a $nickname");
}

sub owner {
  my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
  if (defined $data[0] && $data[0] !~ /^\#(.*?)$/ && !defined $data[1]) {
    $nickname = $data[0];
  }
  elsif (defined $data[1] && $data[0] =~ /^\#(.*?)$/) {
    ($channel, $nickname) = ($data[0], $data[1]);
  }
  commands->send("MODE $channel +q $nickname");
}

sub deowner {
  my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
  if (defined $data[0] && $data[0] !~ /^\#(.*?)$/ && !defined $data[1]) {
    $nickname = $data[0];
  }
  elsif (defined $data[1] && $data[0] =~ /^\#(.*?)$/) {
    ($channel, $nickname) = ($data[0], $data[1]);
  }
  commands->send("MODE $channel -q $nickname");
}

sub mode {
  my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
  my $modes = join(" ", @data);
  if ($data[0] =~ /^\#(.*?)$/) {
    $channel = shift(@data);
    $modes = join(" ", @data);
  }
  commands->send("MODE $channel $modes");
}

sub kick {
 my ($channel, $nickname, $kreason, @data) = ($_[1], $_[2], "Requested by ".$_[2], split(" ", $_[3]));
 # #epic glitch lol
 if (!defined $data[0]) {
   stats->kicks($channel, $nickname); return 0;
 }
 my $knick = $data[0];
 $kreason = join(" ", @data) if defined $data[1];
 $kreason =~ s/$knick//;
 if ($data[0] =~ /^\#(.*?)$/i && defined $data[1]) {
   ($channel, $knick) = (shift(@data), shift(@data));
   $kreason = join(" ", @data) if defined $data[2];
   print "$channel \- $knick \- $kreason\n";
 }
 my ($konchan, $bonchan) = (users->onchan($channel, $knick), users->onchan($channel, $config::nickname));
 if (!defined $konchan) {
  commands->send("NOTICE $nickname :User $knick isn't on $channel"); return 0;
 }
 elsif (!defined $bonchan) {
  commands->send("NOTICE $nickname :I'm not currently on $channel try !join $channel"); return 0;
 }
 commands->send("KICK $channel $knick $kreason");
}

sub kickban {
 my ($channel, $nickname, $kreason, @data) = ($_[1], $_[2], "Requested by ".$_[2], split(" ", $_[3]));
 # #epic glitch lol
 if (!defined $data[0]) {
   stats->kicks($channel, $nickname); return 0;
 }
 my $knick = $data[0];
 $kreason = join(" ", @data) if defined $data[1];
 $kreason =~ s/$knick//;
 if ($data[0] =~ /^\#(.*?)$/i && defined $data[1]) {
   ($channel, $knick) = (shift(@data), shift(@data));
   $kreason = join(" ", @data) if defined $data[2];
   print "$channel \- $knick \- $kreason\n";
 }
 my ($konchan, $bonchan) = (users->onchan($channel, $knick), users->onchan($channel, $config::nickname));
 if (!defined $konchan) {
  commands->send("NOTICE $nickname :User $knick isn't on $channel"); return 0;
 }
 elsif (!defined $bonchan) {
  commands->send("NOTICE $nickname :I'm not currently on $channel try !join $channel"); return 0;
 }
 my @udata = split("@", $channels::channels{$channel}->{$knick}->{'mask'});
 $channels::bans{$channel}->{$knick}->{'mask'} = "\*\!\*\@$udata[1]";
 commands->send("MODE $channel +b \*\!\*\@$udata[1]\r\nKICK $channel $knick $kreason");
}

sub ban { 
 my ($channel, $nickname, $mask) = ($_[1], $_[2], $_[3]);
 
}

sub unban {
 my ($channel, $nickname) = split(" ", $_[1]);
 return 0 if !defined $nickname;
 if (defined $channels::bans{$channel}->{$nickname}->{'mask'}) {
   commands->send("MODE $channel -b $channels::bans{$channel}->{$nickname}->{'mask'}");
   delete  $channels::bans{$channel}->{$nickname}->{'mask'};
 }
}

sub topic {

}

sub msg {

}

sub say {
	my ($channel, $nickname, @data) = ($_[1], $_[2], split(" ", $_[3]));
	commands->send("PRIVMSG $channel @data\r\n");
}

sub notice {

}

sub act {

}

sub describe {

}

sub cycle {

}

sub cs {

}

sub ns {

}

sub hs {

}

sub ms {

}

sub lock {

}

sub unlock {

}


1;
