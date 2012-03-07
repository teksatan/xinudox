#!/usr/bin/perl -w

########################################################################
# Author(s): Kiyoura
# Name: Password Generator
# Description: 
#
# Generate random password for personal use.
########################################################################

use strict;
use Switch;

my $password = '';

sub algorithm
{    
    until (length($password) == $_[0]) {
        $password .= chr(int(rand(122 - 28) + 28));
        switch ($_[1]) {
            case 'numeral' {
               $password =~ s/[^0-9]//g;
            }
            case 'alpha' {
                $password =~ s/[^\w]//g;
            }
            case 'symbol'  {
                $password =~ s/[\w]//g;
            }
        }        
    }
    return $password;
}
if ($#ARGV != 1) {
    # introduction message.. (if arguments are invalid or empty)
    print  'Welcome to the ultimate Perl password generator. If this is your first time'
    . ' using this program, the instructions are as follows:'
    . ' The first argument must be a valid numerical (higher than zero) for length.'
    . ' The Second argument must be a valid type (i.e., numeral, alpha, or symbol).' ."\n";
    exit;
} else {
    # first number higher than zero
    if ($ARGV[0] !~ /^[1-9][0-9]*/) {
        die 'First argument must consist of numbers only.';
    } else {
        # valid types...
        if ($ARGV[1] !~ /numeral|alpha|symbol/){
            die 'Second argument must be ethier numeral, alpha, or symbol';
        }
    }
}
switch ($ARGV[1]) {
    
    case 'numeral' {
        print &algorithm($ARGV[0],'numeral');
    }
    case 'alpha' {
        print &algorithm($ARGV[0],'alpha');
    }
    case 'symbol' {
        print &algorithm($ARGV[0],'symbol');
    }
}