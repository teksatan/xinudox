#!/usr/bin/perl

################################
###							   ###
###       Welcome to teh config niggers =p            ###
###							  ###
###############################

package config;
use strict;
use warnings;

our $version = '2.0a';
### Bot Server configuration
our $server = 'irc.umad.us:6667'; # irc.anondox.com(:6667), ssl must contain :port(irc.anondox.com:6697)
our $localhost = ''; # local bind ip
our $localport = ''; # local bind port
our $ssl = 0; # use ssl? (requires the port to be specified manually)


### Bot configuration
our $nickname = 'xinudox[new]'; # irc nickname
our $ident = 'xinu'; # irc ident
our $realname = 'umad'; # @ irc "real name"
our $OS = "Win32"; # this will be automatically updated at program start
our $ithreads = 0; # should probably keep this 0 and let the bot set it
our $posix = 0; # should probably keep this 0 and let the bot set it


### Bot Channel configuration
our $channelName = '#umad'; # irc CHANNEL only add one...
our $channelPass = 'gtf0nigg3r'; # channel password
our $channelModes = '+nt'; # default modes bot will enforce on a channel
our $channelTopic = 'Welcome to %c <3'; # default topic the bot sets in her channel
our $channelOptions = ""; # default options to follow
our $channelSpecial = ""; # a peace of code to be executed on join of this channel


### Bot NickServ configuration
our $nsPassword = '1.3`=-4DFdsdm'; # nickserv password
our $nsOptions = "set kill quick"; # use NS kill security support?



### Bot Oper configuration
our $operup = 0; # should we oper on connect keep it 0 use -o on commandline?
our $oper = 'xinudox x1nud0x!%^'; # oper name password



### General configuration
our $debug = 0; # debugging?
our $salt = 536784; # salt key to use for passwords
our $logging = 0; # logging?
our $daemonize = 0; # fork to child?
our $logsize = 50000; # max log size




### database configuration (only needed if mysql is the selected dataabase type)
our $database = "0"; # 0 = plaintext, 1 = mysql, 2 = both (will only read from flatfile but keeps mysql backup "avoids conflict")


if ($database == 1 || $database == 2) { # i want to limit the ammount of vars as much as possible
  our $dbname = 'wired';
  our $dbhost = 'localhost';
  our $dbuser = $dbname;
  our $dbpassword = 'HaEnRJ3LKJUmdShN';
}


#delete this next line to allow the bot to run.
# my $die = "You need to edit the config retard.\n";

1;
