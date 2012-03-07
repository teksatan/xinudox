#!/usr/bin/perl


use strict;
use warnings;
use Switch;

sub mod_load {
    our %modules;
    
    my @dirs = qw(games user);

    for my $dir (@dirs) {
        my $strdir = "include/modules/".$dir."/";
  	my @moddirs = <$strdir\*.pm>;
  	for my $moddir (@moddirs) {
  	    print $moddir."\n";
  	}
    }
}

mod_load();