#!/usr/bin/perl

package watch;
use strict;
use warnings;
#use threads;

our $version = "1.0 glitch & wired";


sub list {
  my ($nickname, $channel) = ($_[1], $_[2]);
  my $string = 'data/watch/';
  my @list = <data/watch/*.watch>;
  for my $watched (@list) {
    $watched =~ s/$string//;
    $watched =~ s/\.watch//;
    open(my $fid, "< data/watch/$watched\.watch");
    my $information = <$fid>;
    close $fid;
    commands->msg($channel, "$watched-> $information");
  }
}

sub add {
  my ($nickname, $channel, $parameters) = ($_[1], $_[2], $_[3]);
  my @data = split (" ", $parameters);
  my ($cmd, $nick, $reason) = (shift(@data), shift(@data), join(" ", @data));
  if (-f "data/watch/$nick\.watch") {
    commands->send("NOTICE $nickname :$nick is already in the oper watch list. try using !watch update");
    return 0;
 }
 else {
   open(my $wfid, ">> data/watch/$nick\.watch");
   print $wfid "$reason";
   close $wfid;
  commands->send("NOTICE $nickname :Added $nick to the oper watch list");
   return 1;
 }
}

sub del {
  my ($nickname, $channel, $watched) = ($_[1], $_[2], $_[3]);
  if (-f "data/watch/$watched\.watch") {
    unlink("data/watch/$watched\.watch");
    commands->send("NOTICE $nickname :Removed $watched from the oper watch list");
    return 1;
  }
  else {
    commands->send("NOTICE $nickname :Can't find user $watched\. \(NOTE: nicknames in the watch list are case sensitive\)");
    return 0;
  }
}

1;
