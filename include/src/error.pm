#!/usr/bin/perl

package error;

use strict;
use warnings;


sub handle {
  my ($module, $errmsg, $die) = ($_[1], $_[2], $_[3]);
  open my $errfid, ">> logs/bot/error.log";
  print $errfid "### ".localtime()." $module ###\n\t$errmsg\n###\n";
  close $errfid;
  if (defined $die) {
    commands->send("QUIT :Error: $errmsg") if defined $core::socket;
    print "Fatal Error: shutting down!\n $errmsg\n";
    eval { users->save(); };
    telnet->shutdown($errmsg);
    die "$errmsg\n";
  }
  else {
    print "Error from $module:\n $errmsg\n";
    return 0;
  }
}

sub subroutine {
  my ($subroutine, $errmsg, $die) = ($_[1], $_[2], $_[3]);
  return 0 if !$errmsg;
  open my $errfid, ">> logs/bot/error.log";
  print $errfid "### ".localtime()." $subroutine ###\n\t$errmsg\n###\n";
  close $errfid;
  if (defined $die) {
    commands->send("QUIT :Error: $errmsg") if defined $core::socket;
    print "Fatal Error: shutting down!\n $errmsg\n";
    eval { users->save(); };
    telnet->shutdown($errmsg);
    die "$errmsg\n";
  }
  else {
    print "Error from $subroutine:\n $errmsg\n";
    commands->msg("#epic", "Error [$subroutine] -> $errmsg") if defined $core::socket;
    return 0;
  }
}
 

1;