#!/usr/bin/perl

package handle;

use strict;
use warnings;
use Switch;
#use threads;
use File::stat;
use POSIX;
use Digest::MD5;


# THIS FILE IS BEGING UPDATED BRUH

our %raw;
our $version = "1.0 by glitch & wired";

my @commands = <include/modules/src/handle/*.cmd>;
for my $command (@commands) {
  require $command;
}

sub PRIVMSG {
  my ($nickname, $ident, $vhost, $target, $message, @data) = ($_[1], $_[2], $_[3], $_[4], $_[5], split " ", $_[5]);
  commands->debug ("PRIVMSG: $nickname\!$ident\@$vhost from $target\: $message");
  # run access handling
  return 0 if !$message;
  #channel messages
  my $access = users->isauthed($nickname, $ident, $vhost);
  if ($target =~ m/^\#(.*?)$/i) {
    commands->writelog($target, "$nickname $message");
    channel->parse($access, $nickname, $ident, $vhost, $target, $message); # two levels of access checking
    return 1;
  }
  elsif ($target eq $config::nickname) {
    commands->writelog($target, "$nickname $message");
    query->parse($access, $nickname, $ident, $vhost, $message);
    return 1;
  }
}

sub NOTICE {
  my ($nickname, $ident, $vhost, $target, $message, @data) = ($_[1], $_[2], $_[3], $_[4], $_[5], split " ", $_[5]);
  commands->debug ("NOTICE: $nickname\!$ident\@$vhost from $target\: $message");
  commands->writelog($target, "$nickname NOTICE: $message");
  # run access handling
  my $access = users->isauthed($nickname, $ident, $vhost);
  notice->parse($access, $nickname, $ident, $vhost, $target, $message);
}

sub SNOTICE {
  my ($server, $nickname, $message) = ($_[1], $_[2], $_[3]);
  commands->writelog('snotice', $message);
  #check to see if a bot owner/admin is killed or *lined
  if ($message =~ m/Notice -- Received KILL message for (.*) from (.*) Path: (.*) (.*?)$/i) {
    my ($mask, $killer, $reason, @killed) = ($1, $2, $4, split("!", $1));
    $reason =~ s/\r//;
    if (defined $users::users{$killed[0]}->{'host'} && $killer ne $config::nickname && !$users::users{$killer}->{'host'}) {
      return 0 if $users::users{$killed[0]}->{'host'} ne $mask;
      return 0 if $killed[0] eq $killer;
      commands->send("KILL $killer $reason\? get fucked bitch");
    }
    elsif ($killed[0] eq $config::nickname) {
      commands->restart('-l -f -o');
    }
  }
}

sub RAW {
  my ($server, $numeric, $value) = ($_[1], $_[2], $_[3]);
  switch($numeric) {
    case '001' {
      commands->send("PRIVMSG nickserv :identify $config::nickserv");
      commands->send("OPER $config::oper") if $config::operup == 1;
      commands->send("JOIN $config::channel") if join(" ", @config::channels) !~ /$config::channel/;
      for my $channel (@config::channels) {
        commands->send("JOIN $channel");
      }
    }
    case '340' {
      commands->send("NOTICE $raw{$numeric}->{nickname} :$value");
    }
    case '302' {
      commands->send("NOTICE $raw{$numeric}->{nickname} :$value");
    }
    case '433' {
      commands->send("NICK :$config::nickname" . int rand 500);
    }
    case '381' {
      $config::opered = 1;
    }
    case '311' {
      if (defined $raw{'whois'}->{'channel'}) {
        commands->msg($raw{'whois'}->{'channel'}, $value);
      }
    }
    case '379' {
      if (defined $raw{'whois'}->{'channel'}) {
        commands->msg($raw{'whois'}->{'channel'}, $value);
      }
    }
    case '378' {
      if (defined $raw{'whois'}->{'channel'} && !defined($raw{'whois'}->{'hideip'})) {
        commands->msg($raw{'whois'}->{'channel'}, $value);
      }
    }
    case '307' {
      if (defined $raw{'whois'}->{'channel'}) {
        commands->msg($raw{'whois'}->{'channel'}, $value);
      }
      if (defined $raw{'whois'}->{'abuse'}) {
        my $nickname = $raw{'whois'}->{'abuse'};
        delete($raw{'whois'}->{'abuse'});
        $abuse::abuse{$nickname}->{'registered'} = 1;
      }
    }
    case '319' {
      if (defined $raw{'whois'}->{'channel'}) {
        commands->msg($raw{'whois'}->{'channel'}, $value);
      }
    }
    case '312' {
      if (defined $raw{'whois'}->{'channel'}) {
        commands->msg($raw{'whois'}->{'channel'}, $value);
      }
    }
    case '313' {
      if (defined $raw{'whois'}->{'channel'}) {
        commands->msg($raw{'whois'}->{'channel'}, $value);
      }
    }
    case '310' {
      if (defined $raw{'whois'}->{'channel'}) {
        commands->msg($raw{'whois'}->{'channel'}, $value);
      }
    }
    case '317' {
      if (defined $raw{'whois'}->{'channel'}) {
        commands->msg($raw{'whois'}->{'channel'}, $value);
      }
    }
    case '320' {
      if (defined $raw{'whois'}->{'channel'}) {
        commands->msg($raw{'whois'}->{'channel'}, $value);
      }
    }
    case '671' {
      if (defined $raw{'whois'}->{'channel'}) {
        commands->msg($raw{'whois'}->{'channel'}, $value);
      }
    }
    case '318' {
      if (defined $raw{'whois'}->{'channel'}) {
        delete $raw{'whois'}->{'channel'};
      }
    }
    case '604' {
      my @data = split(" ", $value);
      # all this is a work in progress
    }
    case '352' {
      my @data = split( " ", $value);
      my ($nickname, $channel, $ident, $vhost, $server) = ($data[4], $data[0], $data[1], $data[2], $data[3]);
      return 0 if $channel eq '*';
      users->add($nickname, $ident, $vhost, $server);
      $channels::channels{$channel}->{$nickname}->{'mask'} = "$nickname\!$ident\@$vhost";
    }
    case '353' {
      return;
    }
  }
}




sub NICK {

}

# :xinudox!652@nigger-AD5E51F9 JOIN :#epic
sub JOIN {
  my ($nickname, $ident, $vhost, $channel) = ($_[1], $_[2], $_[3], $_[4]);
  $channel =~ s/\r//;
  commands->debug("JOIN: $nickname\!$ident\@$vhost to: $channel");
  commands->writelog($channel, "$nickname\!$ident\@$vhost Joined $channel");
  commands->send("WHO $channel");
  $channels::channels{$channel}->{$nickname}->{'mask'} = "$nickname\!$ident\@$vhost";
}
# :xinudox!652@nigger-AD5E51F9 PART #epic :cycling
sub PART {
  my ($nickname, $ident, $vhost, $channel, $message) = ($_[1], $_[2], $_[3], $_[4], $_[5] || return " ");
  commands->debug("PART: $nickname\!$ident\@$vhost from: $channel reason: $message");
  commands->writelog($channel, "$nickname\!$ident\@$vhost Left $channel \($message\)");
  delete($channels::channels{$channel}->{$nickname}) if defined $channels::channels{$channel}->{$nickname}->{'mask'};
}

sub MODE {
  my ($nickname, $ident, $vhost, $target, $modes) = ($_[1], $_[2], $_[3], $_[4], $_[5]);
  commands->debug("MODE: $nickname\!$ident\@$vhost $target $modes");
  commands->writelog($target, "$nickname\!$ident\@$vhost set modes $modes to $target");
}

sub KICK {
  my ($nickname, $ident, $vhost, $channel, $kicknick, $message) = ($_[1], $_[2], $_[3], $_[4], $_[5], $_[6]);
  revenge->kick($kicknick, $nickname, $channel, $message);
}

sub QUIT {
  my ($nickname, $ident, $vhost) = ($_[1], $_[2], $_[3]);
  if (defined $users::users{$nickname}->{'loggedin'} && $users::users{$nickname}->{'loggedin'} == 1) {
    commands->writelog('bot', "Automatically logged $nickname out");
    $users::users{$nickname}->{'loggedin'} = 0;
  }
  if (defined $abuse::abuse{$nickname}->{'mask'} && $abuse::abuse{$nickname}->{'onchan'} == 1) {
    #abuse->quit($nickname, "$nickname\!$ident\@$vhost");
  }
}

sub TOPIC {

}

1;
