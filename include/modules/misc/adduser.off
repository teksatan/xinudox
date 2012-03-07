#!/usr/bin/perl
# adduser module
# freeshells
# default is linux/debian oriented
# freebsd version is commented out
# @author wired
##################
package adduser;

use strict;
use warnings;
use Expect;

sub add {
        my ($nickname, $host, @data) = ($_[1], $_[2], split(" ", $_[3]));
        my($username, $password) = ($data[0], $data[1]);

        if($username =~ /[^[:alnum:]]/) {
                commands->send("NOTICE $nickname :Illegal characters in your username douchebag..\r\n");
        }

        open(my $pass, "</etc/passwd");
        my @exists = <$pass>;
        my $user = grep(/$username/, @exists);

        if($user) {
                commands->send("NOTICE $nickname :$username already exists please try another username.\r\n");
                close($pass);
        }

        open(my $uname, "<db/uname.log");
        my @nicks = <$uname>;
        for my $nick (@nicks) {
                if($nick =~ /$nickname/i) {
                        commands->send("NOTICE $nickname :No going to work playa.\r\n");
                }
        }
        close($uname);

        open(my $check, "<db/hosts.log");
        my @hosts = <$check>;
        for my $mask (@hosts) {
                if($mask =~ /$host/i) {
                        commands->send("NOTICE $nickname :Failed bruh, contact an administrator.\r\n");
                }
        }
        close($check);

	# linux tested on debian
        my $exec = "sudo /usr/sbin/useradd -b /home/free -m -U -s /bin/rbash $username";
        system($exec);

	# freebsd 
	# uncomment this if you're using this module on freebsd and comment out the linux version
	# my @dirs = ('/home/free');
	# my $exec = "sudo /usr/sbin/pw groupadd $username && sudo /usr/sbin/pw useradd $username -g $username -s /usr/local/bin/bash -L free -d $dirs[0] -m";
	# system($exec);

        if($? == 0) {
                commands->send("NOTICE $nickname :$username added to the system login at $username\@blackbox.anondox.com port 22 with your password $password\r\n");
        } else {
                commands->send("NOTICE $nickname :Unable to add $username to system contact an administrator.\r\n");
        }

        my $exp = Expect->spawn("sudo passwd $username");

	# expect syntax needs to be changed depending on system output
        if($? == 0) {
                $exp->expect(30,
                        [ 'Enter new UNIX password:', sub { # change here for different passwd outputs
                                my $fh = shift;
                                $fh->send("$password\n");
                                exp_continue;
                                }
                        ],
                        [ 'Retype new UNIX password:', sub { # change here for different passwd outputs
                                my $fh = shift;
                                $fh->send("$password\n");
                                exp_continue;
                                }
                        ],
                );
                open(my $check, ">>db/hosts.log");
                print $check "$host\r\n";
                close($check);
                open(my $ulog, ">>db/users.log");
                print $ulog "$nickname added $username from $host\r\n";
                close($ulog);
                open(my $uname, ">>db/uname.log");
                print $uname "$nickname\r\n";
                close($uname);
        }

}

1;

