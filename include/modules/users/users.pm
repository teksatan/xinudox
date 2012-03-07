#!/usr/bin/perl

package users;
use strict;
use warnings;
#use threads;

our %users;
our $version = "1.0 by glitch";
our $usrDir = 'data/users/';
users->get();

BEGIN {
  commands->add('channel', 'owner', '!dumpusers', 'users->list($channel)');
}

sub convertSQLToFlat {
  my $channel = $_[1];
  sql->conn();
  sql->get('users');
  while (my $ref = $sql::sth->fetchrow_hashref()) {
      open my $uid, '> data/users/'.$ref->{'nickname'}.'.user';
      print $uid "loggedin:".$ref->{'loggedin'}."\n";
      print $uid "mask:".$ref->{'mask'}."\n";
      print $uid "nickname:".$ref->{'nickname'}."\n";
      print $uid "password:".$ref->{'password'}."\n";
      print $uid "type:".$ref->{'type'}."\n";
      close $uid;
      if (defined($channel) && defined($core::socket)) {
          commands->msg($channel, $ref->{'nickname'}." converted to flatfile");
      }
  }
  $sql::sth->finish();
  sql->close();
}

sub get {
    if ($config::database ==1) {
        sql->get('users');
        while (my $ref = $sql::sth->fetchrow_hashref()) {
            $users{$ref->{'nickname'}}->{'type'} = $ref->{'type'};
            $users{$ref->{'nickname'}}->{'mask'} = $ref->{'mask'};
            $users{$ref->{'nickname'}}->{'password'} = $ref->{'password'};
            $users{$ref->{'nickname'}}->{'loggedin'} = $ref->{'loggedin'};
        }
        $sql::sth->finish();
    }
    else {
       my @userFiles = <$usrDir\*.user>;
       for my $file (sort @userFiles) {
	    my $user = $file;
	    $user =~ s/$usrDir//;
	    $user =~ s/\.user//;
	    open my $uid, "< $file";
	    my @tmpData = <$uid>;
	    close $uid;
	    for my $line (sort @tmpData) {
		next if $line =~ m/^#(.*?)$/i;
		print 'ok'.$line."\n";
		my ($subject, $value) = split(':', $line);
		chomp($value);
		$users{$user}->{$subject} = $value;
	    }
       }
    }
}
sub logout {
  my $switch = $_[1];
  if ($switch eq 'all') {
    foreach my $user (keys %users) {
      $users{$user}->{'loggedin'} = 0;
    }
    return 1;
  }
  elsif (defined $users{$switch}->{'loggedin'}) {
    $users{$switch}->{'loggedin'} = 0;
    users->save();
  }
}

sub save {
    for my $user (keys %users) {
	next if !defined $users{$user}->{'password'};
	if ($config::database ==1) {
	    sql->do("UPDATE users SET type = ".$sql::dbh->quote($users{$user}->{'type'})." WHERE nickname = ".$sql::dbh->quote($user));
	    sql->do("UPDATE users SET mask = ".$sql::dbh->quote($users{$user}->{'mask'})." WHERE nickname = ".$sql::dbh->quote($user));
	    sql->do("UPDATE users SET password = ".$sql::dbh->quote($users{$user}->{'password'})." WHERE nickname = ".$sql::dbh->quote($user));
	    sql->do("UPDATE users SET loggedin = ".$sql::dbh->quote($users{$user}->{'loggedin'})." WHERE nickname = ".$sql::dbh->quote($user));
        }
	else {
	    open my $uid, "> $usrDir$user\.user";
	    print $uid "loggedin:".$users{$user}->{'loggedin'}."\n",
	    "mask:".$users{$user}->{'mask'}."\n",
	    "nickname:".$user."\n",
	    "password:".$users{$user}->{'password'}."\n",
	    "type:".$users{$user}->{'type'}."\n";
            close $uid;	    
	}
    }
}

sub register {
    my ($nickname, $ident, $vhost, $password) = ($_[1], $_[2], $_[3], $_[4]);
    my $mask = "$nickname\!$ident\@$vhost";
    if ($config::database == 1) {
        sql->do("INSERT INTO users (nickname, mask, type, password) VALUES (".$sql::dbh->quote($nickname).", ".$sql::dbh->quote($mask).", 'normal', ".$sql::dbh->quote($password).")");
    }
    else {
	open my $uid, "> $usrDir$nickname\.user";
	print $uid "loggedin:1\n",
	"mask:$mask\n",
	"nickname:$nickname\n",
	"password:$password\n",
	"type:normal\n";
	close $uid;	 
    }
    users->get();
}

sub isauthed {
  my ($nickname, $ident, $vhost) = ($_[1], $_[2], $_[3]);
  if (defined $users{$nickname}->{'loggedin'} && $users{$nickname}->{'loggedin'} == 1 && $users{$nickname}->{'mask'} eq "$nickname\!$ident\@$vhost") {
    return $users{$nickname}->{'type'};
  }
  else {
    return 'normal';
  }
}

sub add {
  my ($nickname, $ident, $vhost, $server) = ($_[1], $_[2], $_[3], $_[4]);
  $users{$nickname}->{'mask'} = "$nickname\!$ident\@$vhost";
  $users{$nickname}->{'server'} = $server;
  return $nickname;
}

sub list {
  my ($regd, $channel) = ('no', $_[1]);
  for my $user (sort keys %users::users) {
    $regd = 'yes' if defined $users::users{$user}->{'loggedin'};
    commands->msg($channel, "$user\: Registered-> $regd");
    for my $key (sort keys %{$users::users{$user}}) {
      commands->msg($channel, "~ $key\: ". $users::users{$user}->{$key});
    }
    $regd = 'no'; next;
  }
}

sub onchan {
 my ($channel, $user) = ($_[1], $_[2]);
 if (!defined $users::users{$user}->{'mask'}) {
   commands->send("WHO $channel");
   print "User Not found!\n";
   return undef;
 }
 else {
   if (defined $channels::channels{$channel}->{$user}->{'mask'}) {
     return $channels::channels{$channel}->{$user}->{'mask'};
   }
 }
 return undef; 
}

1;
