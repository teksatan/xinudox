#!/usr/bin/perl

#####################################################
###							 ###
###       Welcome to teh config niggers =p        ###
###							 ###
#####################################################

package config;
use strict;
use warnings;


### bot configuration
our $server = '69.60.121.217:6667'; # server:port must contain :port
our $localhost = ''; # local bind ip
our $localport = ''; # local bind port
our $nickname = 'xinudox'; # irc nickname
our $ident = 'xinu'; # irc ident
our $realname = 'anondox bot'; # @ irc "real name"
our $channel = '#anondox,#711chan,#anthrax,#epic,#noob_hiding'; # irc CHANNEL should actually only be one here (working on multi channel array)
our $default_modes = '+nt'; # default modes bot will enforce on a channel
our $default_topic = 'Welcome to %c niggers <3'; # default topic the bot sets in his channel
our $nickserv = '1.3`=-4DFdsdm'; # nickserv password
our $operup = 0; # should we oper on connect keep it 0 use -o on commandline?
our $oper = 'xinudox x1nud0x!%^'; # oper name password
our $debug = 0; # debugging?
our $salt = 536784; # salt key to use for passwords
our $logging = 0; # logging?
our $daemonize = 0; # fork to child?
our $logsize = 50000; # max log size
our $pid; # actual PID of child proccess
our @repz = qw(nigga slut bitch cunt fgt whore); # some shit for a game(should be moved to your module now that we have a modular includes system)
our @triggers = qw(faggot emo suicide wired hyp crazor Romnous kiyoura glitch Kristin jew jews jewbag slut); # idk wtf this is lol but same as above)


### irc version reply list
our @versionreply = (
  "mIRC v6.2 Khaled Mardam-Bey",
  "irssi v0.8.10 - running on Linux i686",
  "xchat 2.6.2-1 Windows XP [AMD/2.40GHz]",
  "xchat 2.8.0 Linux 2.6.20.3 [i686/1.70GHz]",
  "Konversation 1.0.1 (C) 2002-2006 by the Konversation team",
  "anondox.org irc bot \@authors wired,tak,glitch",
  "TELNET BITCH GTFO"
);

### irc revenge /kill message list
our @killreply = (
  "you fag",
  "bitch",
  "you fuckin cunt",
  "and go eat shit",
  "fucking jewish prick",
  "n gtfo mung gobblin"
);


### database configuration
our $dbname = 'xinudox';
our $dbhost = 'localhost';
our $dbuser = $dbname;
our $dbpassword = '3picshity0$$';


### Links configuration
our @links = (
  "http://www.anondox.org/",
  "http://titsorgtfo.info/",
  "http://imgdump.org",
  "http://r4ge.us",
  "http://c0kedup.info",
  "http://raidchan.org",
  "http://freesteam.org",
);

#delete this next line to allow the bot to run.
# my $die = "You need to edit the config retard.\n";


#### DONT TOUCH ANYTHING BELOW THIS LINE
# our @includes = <./include/*.pm>;
# our @classes = <./include/classes/*.class>;
# our @games = <./include/modules/games/*.pm>;
# our @ai = <./include/modules/AI/*.pm>;
# our @oper = <./include/modules/oper/*.pm>;

our $opered = 0;
our $version = "xinudox version 2.4 beta. perl~ OOP";
our $uptime = 0;
our $logs = 0;
1;
