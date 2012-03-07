#!/usr/bin/perl
###############
# webserver file produced by glitch
# ~ NOT finnished!
###############
package web;

use strict;
use warnings;
use threads;
use IO::Socket;
use Net::hostent;
#use Switch;
use Digest::MD5;
#use Env;
# our $self;

our %threads;
our %client;
our $socket;
our $x = 0;
our %config;

handler->events_add('querymsg', 'owner', '^!apanel', 'web->configure($nickname, "\!$ident\@$vhost", $parameters);');

print "Webserver loaded\n";
$config{'name'} = 'Perl Webserver v1.00.00b'; # server name
$config{'port'} = 8080; # server port
$config{'laddr'} = '67.21.66.245'; # server local bind addr MUST BE CORRECT
$config{'dir'} = 'modules/web/';
$config{'htmldir'} = $config{'dir'}.'html'; # dir for serving html/php/js files
$config{'tmpdir'} = $config{'dir'}.'tmp'; # temporary directory for temp data/cookies
$config{'modules'} = $config{'dir'}.'modules'; # perl server modules
$config{'src'} = $config{'dir'}.'src'; # perl server source files/modules
$config{'index'} = 'login.html'; # index file to be served upon / request
$config{'allowcookies'} = 1; # allow cookies to be saved by server? 1=yes/0=no
$config{'debug'} = 1;

sub configure {
	my ($nick, $mask, @params) = ($_[1], $_[2], split " ", $_[3]);
	if (!defined $params[1]) {
		handler->msg($nick, "Syntax: !apanel admin adminpass");
		return 0;
	}
	if (defined $users::users{$nick}->{'loggedin'} && $users::users{$nick}->{'loggedin'} == 1) {
		if ($handler::config{'admin'} =~ /$mask/) {
			if ($params[0] eq 'admin' && $handler::config{'adminpass'} eq Digest::MD5::md5_hex(crypt($params[1],$handler::config{'salt'}))) {
				$config{'port'} = int rand 9999 + 300;
				my $thr = threads->new( sub { web->start(); } )->detach;
				handler->msg($nick, "http\:\/\/$config{'laddr'}\:$config{'lport'}");
			} else {
				handler->msg($nick, "Incorrect password for \(admin\) logged.");
				handler->writeLog('bot', "$nick\($mask\) failed admin loggin with password $params[1]");
				return 0;
			}
		} else {
			handler->msg($nick, "Your mask doesn't match th elist i have saved. Attempt has been logged");
			handler->writeLog('bot', "$nick\($mask\) failed admin loggin with password $params[1] reason: hostmask didn't match admin list.");
			return 0;
		}
	} else {
		handler->msg($nick, "you don't appear to be loggedin to your regular account. Try !login nickname password first.");
		return 0;
	}
	
}
sub status {
	my ($self, $status, $type, $id, $headers) = @_;
	print {$client{$id}->{'socket'}} "HTTP/1.1 $status\r\nContent-type: $type\r\n",web->response($headers),"\r\n\r\n";
}

sub header {
	my ($id, $header) = ($_[1], $_[2]);
	web->status('200 OK', 'text/html charset=utf-8', $id, $header);
}
sub perlscript {
	my ($file, $id, $rguments) = ($_[1], $_[2], $_[3]);
	if ($file eq 'login.pl') {
			my ($nickname, $password) = ("ok", "no");
			if (!defined $nickname || !defined $password) {
				web->header($id, 'Location: http://192.168.1.11/login.html');
			}
			my $hashpass = Digest::MD5::md5_hex(crypt($password,$handler::config{'salt'}));
			if (defined $users::users{$nickname}->{'password'} && $hashpass eq $users::users{$nickname}->{'password'} && $users::users{$nickname}->{'type'} eq 'owner') {
				$users::users{$nickname}->{'web_loggedin'} = 1;
				web->status('200 OK', 'text/html charset=utf-8', $id);
				return 1;
			}
			web->status('200 OK', 'text/html charset=utf-8', $id);
		}
	return 0;
}

sub parse {
	my ($self, $id) = @_;
	for my $ky (sort keys %{$client{$id}}) {
		next if $ky eq 'socket';
		my $prm = $client{$id}->{$ky};
		$prm =~ s/\///;
		if ($ky eq 'Cache-Control') {
				if ($prm =~ m/^max\-age\=(.*?)$/i) {
					my $expirey = $1;
				}
			}
		if ($ky eq 'location') {
				if($prm eq '') {
					$prm = $client{$id}->{$ky} = 'login.html';
				}
				if($prm =~ m/(.*?)\.html/) {
					my $file = $1;
					if(-e 'modules/web/'.$prm) {
						print "Sending $prm\n";
						open my $fid, "< modules/web/".$prm;
						web->status('200 OK', 'text/html charset=utf-8', $id);
						for my $line (<$fid>) {
							print {$client{$id}->{'socket'}} $line;
						}
						print {$client{$id}->{'socket'}} "\r\n";
						close $fid;
					}
					else {
						web->status('404 Not Found', 'text/html charset=utf-8', $id, 'Status: 404 Not Found');
						print {$client{$id}->{'socket'}} '<title>404 - File not Found</title></body><h1>404</h1> - <b>404 - No such file or directory</b></body>\r\n';
					}
				}
				elsif($prm =~ m/(.*?)\.pl(.*?)/i) {
					my ($file, $arguments) = ($1."\.pl", $2);
					print $prm."\n";
					if ($file eq 'login.pl') {
							my $data = web->perlscript('login.pl', $id);
							if ($data == 1) {
								web->status('200 OK', 'text/html charset=utf-8', $id);
								open my $fid, "< modules/web/html/ok.html";
								while (<$fid>) {
									print {$client{$id}->{'socket'}} $_;
								}
								close $fid;
								print {$client{$id}->{'socket'}} "\r\n";
							}  else { $client{$id}->{'socket'}->shutdown(1); }
								return 0;
						}
					}
				elsif($prm =~ m/(.*?)\.css/i) {
					if(-e $prm) {
						open my $fid, "< $prm";
						web->status('200 OK', 'text/css', $id);
						while (<$fid>) {
							my $line = $_;
							print {$client{$id}->{'socket'}} $line;
						}
						close $fid;
						print {$client{$id}->{'socket'}} "\r\n";
					}
					else {
						web->status('404 Not Found', 'text/html charset=utf-8', $id, 'Status: 404 Not Found');
						print {$client{$id}->{'socket'}} '<title>404 - File not Found</title></body><h1>404</h1> - <b>404 - No such file or directory</b></body>\r\n';
					}
				}
				elsif($prm =~ m/(.*?)\.(jpg|png|gif|)/i) {
					my ($tname, $ttype) = split(/./, $prm);
					if(-e $prm) {
						web->status('200 OK', 'image/$ttype', $id);
						open my $fid, "< $prm";
						while(<$fid>) {
							my $data = $_;
							print {$client{$id}->{'socket'}} $data;
						}
						close $fid;
						print {$client{$id}->{'socket'}} "\r\n";
					} else {
						web->status('404 Not Found', 'text/html charset=utf-8', $id, 'Status: 404 Not Found');
						print {$client{$id}->{'socket'}} '<title>404 - File not Found</title></body><h1>404</h1> - <b>404 - No such file or directory</b></body>\r\n';
					}
				}
				else { web->status('404 Not Found', 'text/html charset=utf-8', $id, 'Status: 404 Not Found'); }
		}
	}
}

sub response {
	my ($self, $response) = @_;
	if (defined $response) {
		$response = $response."Server: ".$config{'name'};
	}
	else { $response = "Server: ".$config{'name'}; }
	return $response;
}

sub start {
	$socket = IO::Socket::INET->new(
				Proto => 'tcp',
				LocalAddr => $config{'laddr'},
				LocalPort => $config{'port'},
				Listen =>	4,
				Reuse => 1) || die ("Error: $!\n");
			
	while($client{$x}->{'socket'} = $socket->accept()) {
		$client{$x}->{'socket'}->autoflush(1);
		# here i send client handler to clients module and fork;
		sleep 1; #clear que
		$threads{$x} = threads->new( sub { web->handle($x); })->detach();
		next;
	}
	++$x;
	return 0;
}

sub shutdown {
	if (defined $socket) {
		$socket->shutdown(2);
	}
	return 1;
}

sub handle2 {
	my ($self, $id, $headersRecieved) = (shift, shift, 0);
	while(my $line = $client{$id}->{'socket'}->getline()) {
		$line =~ s/\r\n//;
		print $line."\n";
		print {$client{$id}->{'socket'}} web->status('100 CONTINUE', 'text/css', $id) if $line =~ /^POST \/(.*?) HTTP\/1\.1$/;
		if ($headersRecieved == 0) {
			if ($line eq '') {
				$headersRecieved = 1;
				# now we need to parse these headers check for cookies, sessions etc.
				web->parse($id);
				last;
			} elsif($line =~ m/(.*?) (.*?) HTTP\/1\.(.*?)$/i) {
				my ($type, $location, $version) = ($1, $2, "1".$3);
				$client{$id}->{'type'} = uc $type;
				$client{$id}->{'location'} = $location;
				$client{$id}->{'version'} = $version;
			} elsif($line =~ m/(.*?)\: (.*?)$/i) {
				my ($key, $object) = ($1, $2);
				$client{$id}->{$key} = $object;
			}
		}
	}
	print STDOUT "disconnected\n";
	$client{$id}->{'socket'}->shutdown(2);
	delete $client{$id};
	return 1;
}

sub handle {
	my ($self, $id, $headersRecieved) = (shift, shift, 0);
	while(my $line = $client{$id}->{'socket'}->getline()) {
		$line =~ s/\r\n//;
		next if ($line eq '' && $headersRecieved == 1);
		print $line."\n";
		my $post = 1 if $line =~ /^POST \/(.*?) HTTP\/1\.1$/;
		#web->status('100 continue', 'text/html', $id) if $line =~ /^POST \/(.*?) HTTP\/1\.1$/;
		if ($headersRecieved == 0) {
			if ($line eq '') {
				$headersRecieved = 1;
				# now we need to parse these headers check for cookies, sessions etc.
				web->parse($id);
				next if defined($post);
				last;
			} elsif($line =~ m/(.*?) (.*?) HTTP\/1\.(.*?)$/i) {
				my ($type, $location, $version) = ($1, $2, "1".$3);
				$client{$id}->{'type'} = uc $type;
				$client{$id}->{'location'} = $location;
				$client{$id}->{'version'} = $version;
			} elsif($line =~ m/(.*?)\: (.*?)$/i) {
				my ($key, $object) = ($1, $2);
				$client{$id}->{$key} = $object;
			}
		}
	}
	print STDOUT "disconnected\n";
	$client{$id}->{'socket'}->shutdown(2);
	delete $client{$id};
	return 1;
}


1;