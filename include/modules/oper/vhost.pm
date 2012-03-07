#!/usr/bin/perl

package vhost;

use strict;
use warnings;
#use threads;

# who can use !sethost
my $setters = "glitch wired tak kiyoura Romnous Trapdoor";
our $version = "1.0 glitch & wired";
BEGIN {
  my $code = (
          'if (!$data[1]) {
          commands->send("NOTICE $nickname Syntax: !vhost (set|tmp) <vhost> [user]");
          return 0;
        }
        elsif (defined $data[1]) {
          vhost->set($nickname, $parameters);
        }');
        commands->add('channel', 'normal', '!vhost', $code);
  
}

sub set {
  my ($nickname, @data) = ($_[1], split(" ", $_[2]));
  return 0 if $config::opered == 0;
  if (defined $data[1] && $data[0] eq 'set') {
    if (!defined $data[2]) {
      commands->send("PRIVMSG HostServ :set $nickname $data[1]");
      commands->send("NOTICE $nickname Your vhost is now set to $data[1] type \'/msg HostServ on\' to activate it");
      return 1;
    }
    if (defined $data[2] && $setters =~ /$nickname/) {
      commands->send("PRIVMSG HostServ :set $data[2] $data[1]");
      commands->send("NOTICE $data[2] Your vhost is now set to $data[1] type \'/msg HostServ on\' to activate it");
      return 1;
    }
    else {
      commands->send("NOTICE $nickname you don't have access to change other users vhost");
      return 0;
    }
  }
  elsif (defined $data[1] && $data[0] eq 'tmp') {
    if (!defined $data[2]) {
      commands->send("chghost $nickname $data[1]");
      return 1;
    }
    if (defined $data[2] && $setters =~ /$nickname/) {
      commands->send("CHGHOST $data[2] $data[1]");
      return 1;
    }
    else {
      commands->send("NOTICE $nickname you don't have access to change other users vhost");
      return 0;
    }
  }
}


1;
