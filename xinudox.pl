#!/usr/bin/perl

package xinudox;

use strict;
use warnings;
use Getopt::Long;

$| = 1;
print "Starting...\n";

require 'config/config.pl';

die "Error no daemonize var in config!\n" if !defined $config::daemonize;
die "Error no debug var in config!\n" if !defined $config::debug;
die "Error no logging var in config!\n" if !defined $config::logging;
die "Error no nickname var in config!\n" if !defined $config::nickname;
die "Error no server var in config!\n" if !defined $config::server;
die "Error no operup var in config!\n" if !defined $config::operup;
die "Error no version var in config!\n" if !defined $config::version;
$SIG{HUP} = sub { commands->SIGNAL('SIGHUP'); };
$SIG{INT} = sub { commands->SIGNAL('SIGINT'); };
$SIG{TERM} = sub { commands->SIGNAL('SIGTERM'); };
$SIG{USR1} = sub { commands->SIGNAL('SIGUSR1'); };
$SIG{USR2} = sub { commands->SIGNAL('SIGUSR2'); };
$SIG{SEGV} = sub { commands->SIGNAL('SIGSEGV'); };

if (!-f 'data/beenrun') {
	print "This seems to be the first time the bot has been run\n",
	"Should we take a second to run the setup?(config file will be automaticaly generated\n";
	print  "Yes/No[Yes]";
	while(my $line = <STDIN>) {
		chomp $line;
		if ($line eq '' || $line eq 'yes') {
		} else { last; }
	}
}

my $getoptions = new Getopt::Long::Parser;

$getoptions->getoptions(
  "help" => sub {
  print "".$config::version."\n",
    "Commandline options:\n",
    " --nick|-n <nickname>\tSpecify bot nickname\n",
    " --server|-s <server>\tSpecify bot server\n",
    " --fork|-f\tFork the bot to run in the background?\n",
    " --debug|-d\tRun in debug mode outputs to ./debug/botnick.out\n",
    " --log|-l\tRun the bot with logging\n",
    " --oper|-o\t Forces the bot to oper up on connect\n";
    exit 0; 
 },
  "fork|f" => \$config::daemonize,
  "debug|d" => \$config::debug,
  "log|l" => \$config::logging,
  "oper|o" => \$config::operup,
  "nick|n=s" => \$config::nickname,
  "server|s=s" => \$config::server);
#run any additional initialization shit here

require 'include/core.pm';

#begin.
core->start();

1;
