#!/usr/bin/perl

package sql;

use strict;
use warnings;
use DBI;
#use threads;

our ($dbh, $sth);
our $version = "1.0 by wired & glitch";


sub conn {
   my $dsn = "DBI:mysql:database=$config::dbname;host=$config::dbhost";
   $dbh = DBI->connect($dsn, $config::dbuser, $config::dbpassword)
	or die "can't connect to mysql database $config::dbname\n";
}

sub do {
  my $query = $_[1] or return undef;
  if (defined $dbh && defined $query) {
    $dbh->do($query);
    return 1;
  }
}

sub get {
  my ($table) = ($_[1]);
  if (defined $dbh && defined $table) {
    $sth = $dbh->prepare("SELECT * FROM $table");
    $sth->execute();
    return 1;
  }
}

sub tabcol {
	my ($table, $column) = ($_[1], $_[2]);
	if(defined $dbh && defined $column) {
		$sth = $dbh->prepare("SELECT $column from $table");
		$sth->execute();
		return 1;
	}
}

sub grab {
	my $nickname = $_[1];
	my $query = $_[2] or return undef;
	if(defined $dbh && defined $query) {
		$sth = $dbh->prepare($query);
		$sth->execute();
		
		my @data = $sth->fetch_array;
		
		foreach my $dat (@data) {
			commands->notice($nickname, $dat);
		}
	}
}

sub prepare {
  my $query = $_[1] or return undef;
  if (defined $dbh && defined $query) {
  $sth = $dbh->prepare($query);
  return 1;
  }
}

sub execute {
  if (defined $dbh && defined $sth) {
    $sth->execute;
    $sth->finish;
    return 1;
  }
}

sub quote {
  my $string = $_[1] or return undef;
  if (defined $dbh && defined $string) {
    return $dbh->quote($string);
  }
}

sub close {
  $dbh->disconnect() if defined $dbh;
  return 1;
}

1;
