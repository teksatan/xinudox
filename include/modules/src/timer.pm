#!/usr/bin/perl

package timer;

use strict;
use warnings;
#use threads;

our $version = "1.0 by glitch";

# i haz alot more planned for this.
BEGIN {
  commands->add('channel', 'owner', '!timer', 'timer->add(shift(@data), shift(@data), join(" ", @data))');
}



sub add {
  my ($subroutine, $interval, $time) = ($_[1], $_[2], $_[3]);
  my $thr = threads->create( sub {
    for (my $count = 0; $count <= $time; $count++) {
     sleep $interval;
     eval($subroutine);
    }
  } )->detach();
}


# for #perl lol
sub rmsg {
  my $chan = $_[1];
  open my $fid, "< data/rtext.txt";
  my @lines = <$fid>;
  close $fid;
  commands->msg($chan, $lines[int rand scalar @lines]);
}
1;
