#!/usr/bin/perl

#fuck it i'll go all out with this one
#lol

package abuse;
use strict;
use warnings;
#use threads;
#seperate by space

our %abuse;
our $version = "1.0 glitch & wired";

my $bans = "nigger";
BEGIN {
  commands->add('channel', 'normal', '!update', 'return 0 if $channel ne "#abuse"; abuse->update()');
  commands->add('channel', 'normal', '!users', 'return 0 if $channel ne "#abuse"; my @users = <data/abuse/*>; commands->send("PRIVMSG #abuse :Users-> ".int(@users));')  
}
sub isregd {
  my ($nickname) = $_[1];
  if ($nickname ne 1) {
    $handle::raw{'whois'}->{'abuse'} = $nickname;
    commands->send("WHOIS $nickname");
  }
}

sub join {
  my ($nickname, $mask) = ($_[1], $_[2]);
  if ($nickname =~ m/$bans/i) {
    commands->send("KICK #abuse $nickname :gtfo");
    return 0;
  }
  if (!defined $abuse{$nickname}->{'mask'}) {
    abuse->isregd($nickname);
    sleep 1;
    if (!defined $abuse{$nickname}->{'registered'}) {
      commands->send("KICK #abuse $nickname Register your nick nigger or gtfo");
      return 0;
    }
    elsif ($abuse{$nickname}->{'registered'} == 1) {
      $abuse{$nickname} = {
                    registered => 1,
                    mask => $mask,
                    onchan => 1,
                  };
                    
                    
      open(my $ufid, "> data/abuse/$nickname");
      print $ufid "$mask\:".$abuse{$nickname}->{'registered'}."\:1";
      close $ufid;
      commands->send("PRIVMSG ChanServ access add $nickname 9999\r\nMODE #abuse +qao $nickname $nickname $nickname");
      commands->send("NOTICE $nickname :Welcome to #abuse you've been givin 9999 access enjoy =D");
    }
    return 1;
  }
  else {
    $abuse{$nickname}->{'onchan'} = 1;
    $abuse{$nickname}->{'mask'} = $mask;
  }
}

sub part {
  my ($nickname, $mask) = ($_[1], $_[2]);
  $abuse{$nickname}->{'mask'} = $mask;
  $abuse{$nickname}->{'onchan'} = 0;
}

sub kick {
  my ($nickname, $mask) = ($_[1], $_[2]);
  $abuse{$nickname}->{'mask'} = $mask;
  $abuse{$nickname}->{'onchan'} = 0;
}

sub quit {
  my ($nickname, $mask) = ($_[1], $_[2]);
  $abuse{$nickname}->{'mask'} = $mask;
  $abuse{$nickname}->{'onchan'} = 0;
}

sub update {
 $handle::raw{'353'}->{'channel'} = '#abuse';
 commands->send("NAMES #abuse");
}

sub save {
  for my $user (keys %abuse) {
    next if $user == 'conf';
    open(my $ufid, "> data/abuse/$user");
    print $ufid $abuse{$user}->{'mask'}.":".$abuse{$user}->{'registered'}."".$abuse{$user}->{'onchan'};
    close $ufid;
  }
}

sub check {
  my $what = $_[1];
  commands->send("PRIVMSG ChanServ clear #abuse bans") if $what eq'bans';
  commands->send("PRIVMSG ChanServ clear #abuse excepts") if $what eq'excepts';
  commands->send("PRIVMSG ChanServ clear #abuse invites") if $what eq'invites';
  if ($what =~ m/^users (.*?)$/i) {
    my $data = $1;
    $data =~ s/\r//;
    #doshit
  }
}
1;
