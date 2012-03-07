#!/usr/bin/perl

package kingsql;

use strict;
use warnings;
use DBI;
#use threads;

our ($dbh, $sth);
our $version = "1.0 glitch & wired";

sub conn {
   my $dsn = "DBI:mysql:database=kingpin;host=$config::dbhost";
   $dbh = DBI->connect($dsn, $config::dbuser, $config::dbpassword)
	or die "can't connect to mysql database kingpin\n";
}

sub do {
  my $query = $_[1] or return undef;
  if (defined $dbh && defined $query) {
    $dbh->do($query);
    return 1;
  }
}

sub exec {
	my $query = $_[1] or return undef;
	my $nickname = $_[2];
	if(defined $dbh && defined $query) {
		my $sth = $dbh->prepare($query);
		$sth->execute($nickname);
		$sth->finish();
	}
}

sub dranges {
	my ($nickname, $potrange, $hrange, $cokerange, $cidrange, $methrange, $crackrange, $pillrange, $xtcrange) = ($_[1], $_[2], $_[3], $_[4], $_[5], $_[6], $_[7], $_[8], $_[9]);
	my $query = "insert into drugs (mrange,hrange,cokerange,cidrange,methrange,crackrange,pillrange,xtcrange) values(".$potrange.", ".$hrange.", .".$cokerange.", ".$cidrange.", ".$methrange.", ".$crackrange.", ".$pillrange.", ".$xtcrange.") where username = ?";
	
	my $sth = $dbh->prepare($query);
	$sth->execute($nickname);
	$sth->finish();
}

sub paid {
	my ($nickname, $item, $range) = ($_[1], $_[2], $_[3]);
	my $iquery = "update users set item=? where username = ?";
	my $rquery = "update users set paid=? where username = ?";
	
	my $ith = $dbh->prepare($iquery);
	$ith->execute($item, $nickname);
	$ith->finish();
	
	my $rth = $dbh->prepare($rquery);
	$rth->execute($range, $nickname);
	$rth->finish();
}

sub outdrug {
	my ($nickname, $drug) = ($_[1], $_[2]);
	my $sth = $dbh->prepare("select $drug from drugs where username = ?");
	$sth->execute($nickname);
	
	my $amount = $sth->fetchrow_array();
	
	if($amount) {	
		return $amount;
	}	
	
	$sth->finish();
}

sub indrug {
	my ($nickname, $drug, $value, $amount) = ($_[1], $_[2], $_[3]);
	my $oldamount = kingsql->outdrug($nickname, $drug);
	my $newamount = $oldamount + $amount;
	
	my $query = "update drugs set $drug=? where username = ?";
	my $sth = $dbh->prepare($query);
	$sth->execute($nickname);
	
	commands->send("NOTICE $nickname :You buy $drug for $value added $amount to your $drug stash.\r\n");
	
	$sth->finish();
}

sub incity {
	my $nickname = $_[1];
	my $city = $_[2];
	my $query = "update users set city = ? where username = ?";
	$sth = $dbh->prepare($query);
	$sth->execute($city, $nickname);
	$sth->finish();
}

sub outcity {
	my $nickname = $_[1];
	$sth = $dbh->prepare("select city from users where username = ?");
	$sth->execute($nickname);
	
	my $city = $sth->fetchrow_array();

	commands->send("NOTICE $nickname :You are currently in $city.\r\n");
	
	$sth->finish();
}

sub ucheck {
	my $nickname = $_[1];
	$sth = $dbh->prepare("SELECT username from users where username = ?");
	$sth->execute($nickname);
	
	my $check = $sth->fetchrow_array();
	
	if($check) {
		kingsql->udata($nickname);
	} else {
		commands->send("NOTICE $nickname :You are required to register with the bot before you can play kingpin. !register\r\n");
	}
	
	$sth->finish();
}

sub udata {
	# i'm high and i'm retarded and i have no idea what i'm doing with this
	my ($nickname) = ($_[1]);
	my $drugcol = "marijuana,heroin,cocaine,acid,meth,crack,pills,xtc";
	my $guncol = "baretta,fourfive,treyeight,ruger,shotgun,ak,m16,mp5";
	my $propcol = "stripclub,bar,cornerstore,casino,laundrymat,pizzashop,recorddealer";
	my $whipcol = "benz,beamer,corvette,jaguar,lambo,skyline";
	my $usercol = "money,rank,bitches";
		
	my $drugq = "select ".$drugcol." from drugs where username = ?";
	my $gunq = "select ".$guncol." from guns where username = ?";
	my $propq = "select ".$propcol." from property where username = ?";
	my $whipq = "select ".$whipcol." from whips where username = ?";
	my $userq = "select ".$usercol." from users where username = ?";
	
		
	my $uth = $dbh->prepare($userq);
	$uth->execute($nickname);
	my $dth = $dbh->prepare($drugq);
	$dth->execute($nickname);
	my $gth = $dbh->prepare($gunq);
	$gth->execute($nickname);
	my $pth = $dbh->prepare($propq);
	$pth->execute($nickname);
	my $wth = $dbh->prepare($whipq);
	$wth->execute($nickname);
		
	my @drugdat = $dth->fetchrow_array();
	my @gundat = $gth->fetchrow_array();
	my @propdat = $pth->fetchrow_array();
	my @whipdat = $wth->fetchrow_array();
		
	while(my @userdat = $uth->fetchrow_array()) {
		commands->send("NOTICE $nickname :Yo \x02".$nickname."\x02 you have \$".$userdat[0]." dollars, your rank is ".$userdat[1]." and you have ".$userdat[2]." bitches.\r\n");
		commands->send("NOTICE $nickname :Your drug supply consists of ".$drugdat[0]." units of marijuana, ".$drugdat[1]." units of heroin, ".$drugdat[2]." untis of cocaine, ".$drugdat[3]." units of acid, ".$drugdat[4]." units of meth, ".$drugdat[5]." units of crack, ".$drugdat[6]." units of pills and ".$drugdat[7]." units of xtc.\r\n");
		commands->send("NOTICE $nickname :All properties owned are ".$propdat[0]." strip clubs, ".$propdat[1]." bars, ".$propdat[2]." corner stores, ".$propdat[3]." casino's, ".$propdat[4]." laundrymats, ".$propdat[5]." pizza shops and ".$propdat[6]." record dealers.\r\n");
		commands->send("NOTICE $nickname :Weapons locker: ".$gundat[0]." barreta's, ".$gundat[1]." forty fives, ".$gundat[2]." trey eights, ".$gundat[3]." rugers, ".$gundat[4]." shotguns, ".$gundat[5]." ak 47s, ".$gundat[6]." m16s, ".$gundat[7]." mp5s\r\n");
		commands->send("NOTICE $nickname :In your garage: ".$whipdat[0]." benz's, ".$whipdat[1]." beamers, ".$whipdat[2]." corvettes, ".$whipdat[3]." jaguars, ".$whipdat[4]." lambos, ".$whipdat[5]." skylines.\r\n");
	}
	
	$uth->finish();
	$dth->finish();
	$gth->finish();
	$pth->finish();
	$wth->finish();
}

sub close {
  $dbh->disconnect() if defined $dbh;
  return 1;
}

1;


