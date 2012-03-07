#!/usr/bin/perl

package revenge;

use strict;
use warnings;

our $version = "1.0 glitch~";

our %revenge;



sub kick {
  my ($knickname, $nickname, $channel, $reason) = ($_[1], $_[2], $_[3], $_[4]);
  if ($knickname eq $config::nickname) {
    if (defined $users::users{$nickname}->{'password'} || $nickname eq $config::nickname) {
      commands->send("JOIN $channel"); return 1;
    }
    else {
      commands->msg("ChanServ", "ban $channel $nickname");
      commands->send("JOIN $channel");
    }
  }
}


1;