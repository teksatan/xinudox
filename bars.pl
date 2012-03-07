#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use LWP::UserAgent;



print $ARGV[1];
exit;
my $page = "http://hulkshare.com/swagbars";
#my $page = "http://72.187.58.207:8080";
#my $browser = LWP::UserAgent->new("Mozilla");
#my $response = HTTP::Request->new('GET', $page);
#my $html = $browser->request($response);

#print $html->content;

#while($html =~ m/<a href=\"(.*?)\"/g) {
#    print "$1\n";
#}

#here wired try this below here

my $query = $page;
my $ua = LWP::UserAgent->new();
$ua->timeout(120);
my $resp = $ua->get($page) or die 'Unable to get page';
my $html = $resp->content() if $resp->is_success();

for my $word (split /\n/, $html) {
  chomp($word);
  $word =~ s/\t//;
  next if $word eq "";
  print $word."\n";
}
