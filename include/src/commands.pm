#!/usr/bin/perl


package commands;

use strict;
use warnings;
#use threads;
use Switch;
# use Google::Search;
use File::stat;

sub writelog {
  my ($target, $data) = ($_[1], $_[2]);
  my $logfile;
  return 0 if !$data or !$target;
  if ($config::logging == 1) {
    if ($target =~ m/^\#(.*?)$/i) {
      my @sdata = split " ", $data;
      $logfile = "logs/chans/$target\.log";
      $data = "\<" . shift(@sdata) ."\> " . join " ", @sdata;
      goto wlfile;
    }
    elsif($target eq "snotice") {
      $logfile = "logs/server/snotice.log";
      goto wlfile;
    }
    elsif ($target eq "admin") {
      $logfile = "logs/server/admin.log";
      goto wlfile;
    }
    elsif ($target eq $config::nickname) {
      my @sdata = split " ", $data;
      $logfile = "logs/users/" . shift(@sdata) . "\.log";
      $data = join " ", @sdata;
      goto wlfile;
    }
    elsif ($target eq "bot") {
      $logfile = "logs/bot/$config::nickname\.log";
      goto wlfile;
    }
    elsif ($target eq 'links') {
      $logfile = 'logs/bot/links.log';
      goto wlfile;
    }
    elsif ($target eq "telnet") {
      $logfile = "logs/telnet/clients\.log";
      goto wlfile;
    }
    else {
      #should never happen
      print "theres some weird shit going on with logging: $target $data\n";
      return 0;
    }
    wlfile:
    open(LOG, ">>$logfile");
    print LOG localtime() . " $data\n";
    close(LOG);
    if (stat($logfile)->size >= $config::logsize) {
      system("tar -cvzf $logfile\-" . time() . "\.tar.gz $logfile");
      unlink($logfile);
    }
  }
}

sub debug {
  my $text = $_[1];
  if ($config::debug == 1) {
    print "debug\-\>$text\n\n";
  }
}

sub daemonize {
  if ($config::daemonize == 1) {
    $config::pid = fork();
    die ("Failed to fork proccess. exiting") unless defined $config::pid;
    if ($config::pid != 0) {
      open (my $pidfile, ">", "logs/bot/$config::nickname.pid")
        or die "failed to open PID file.\n";
      print $pidfile "$config::pid\n";
      close ($pidfile);
      print "Became daemon \($config::pid\)\n";
      exit 0;
    }
  }
}

sub google {
	my ($nickname, $query, $resnum, $key, $referer) = ($_[1], $_[2], $_[3],'****', '******');
	my $search = Google::Search->Web(q => $query, key => $key, referer => $referer);
	my ($i, $succeed, $result) = (0, 0, $search->first);
  my $resmax = $resnum || 10 if defined $resnum;
    while ($result) {
      my $title = encode("utf8", $result->title) =~ s/<\/?b>//g;
        commands->send("NOTICE $nickname :" . $result->number + 1 . "\) $title " . $result->uri);
        $result = $result->next;
		$succeed = 1;
		$i++;
		last if $i >= $resmax;
    }
	if ($succeed == 0) {
		commands->send("NOTICE $nickname :No results found.");
	}
}

#catch signals from linux
sub SIGNAL {
  my $signal = $_[1];
  switch($signal) {
    case 'SIGHUP' {
     print "Caught SIGHUP rehashing..\n";
     #create a rehash sub
    }
    case 'SIGUSR1' {
      print "Caught SIGUSR1 restarting..\n";
      $core::socket->send("QUIT Caught SIGUSR1 restarting\r\n");
      users->save();
      commands->restart('-l -f');
    }
    case 'SIGUSR2' {
      # not sure yet what we should do with this one
      commands->msg('#perl', 'tits or gtfo');
    }
    case 'SIGINT' {
      print "Caught SIGINT shutting down.\n";
      users->save();
      exit 0;
    }
    case 'SIGSEGV' {
      print "Caught SIGSEGV shutting down.\n";
      users->save();
      threads->exit(0);
    }
    case 'SIGKILL' {
      print "Caught SIGKILL forcing shutdown.\n";
      users->save();
      threads->exit(0);
    }
    case 'SIGTERM' {
      print "Caught SIGTERM running clean shutdown\n";
      users->save();
      threads->exit(0);
    }
  }
}

sub restart {
  my $switches = $_[1];
  $switches = '-l -f -o' if !$switches;
  if ($core::socket->connected) {
    print "\nRestarting...\n";
    commands->send("QUIT :restarting");
    $core::socket->shutdown(2);
  }
  users->save();
  system("./xinudox.pl $switches");
  exit 0;
}

sub handlefile {
  my ($type, $file, $data) = ($_[1], $_[2], $_[3]);
  open(my $FID, "$type $file") or return 0;
  if ($data) {
    print $FID "$data";
    close $FID;
    return 1;
  }
  else {
    my @ret = <$FID>;
    my $tret = join ("\n", @ret);
    close $FID;
    return $tret;
  }
}

sub add {
  my ($where, $type, $newcmd, $code) = ($_[1], $_[2], $_[3], $_[4]);
  if ($where eq 'channel') {
    if (!defined $channel::cmd{$type}->{$newcmd}) {
      $channel::cmd{$type}->{$newcmd} = $code;
      return $newcmd;
    }
    else { return 0; }
  }
  elsif ($where eq 'query') {
    if (!defined $query::cmd{$type}->{$newcmd}) {
      $query::cmd{$type}->{$newcmd} = $code;
      return $newcmd;
    }
    else { return 0; }
  }
  elsif ($where eq 'notice') {
    if (!defined $notice::cmd{$type}->{$newcmd}) {
      $notice::cmd{$type}->{$newcmd} = $code;
      return $newcmd;
    }
    else { return 0; }
  }
  elsif ($where eq 'telnet') {
    if (!defined $telnet::cmds::cmd{$type}->{$newcmd}) {
      $telnet::cmds::cmd{$type}->{$newcmd} = $code;
      return $newcmd;
    }
    else { return 0; }
  }
  elsif (defined $module::modules{$where}->{'version'}) {
    #this is my special little project here
    if (!defined $module::modules{$where}->{$newcmd}) {
      $module::modules{$where}->{$newcmd} = $code;
      return $newcmd;
    }
    else { return 0; }
  }
}
sub del {
  my ($where, $type, $cmd) = ($_[1], $_[2], $_[3]);
  if ($where eq 'channel') {
    if (defined $channel::cmd{$type}->{$cmd}) {
      delete($channel::cmd{$type}->{$cmd});
      return $cmd;
    }
    else { return 0; }
  }
  elsif ($where eq 'query') {
    if (defined $query::cmd{$type}->{$cmd}) {
      delete($query::cmd{$type}->{$cmd});
      return $cmd;
    }
    else { return 0; }
  }
  elsif ($where eq 'notice') {
    if (defined $notice::cmd{$type}->{$cmd}) {
      delete($notice::cmd{$type}->{$cmd});
      return $cmd;
    }
    else { return 0; }
  }
  elsif ($where eq 'telnet') {
    if (defined $telnet::cmds::cmd{$type}->{$cmd}) {
      delete($telnet::cmds::cmd{$type}->{$cmd});
      return $cmd;
    }
    else { return 0; }
  }
  elsif (defined $module::modules{$where}->{'version'}) {
    #this is my special little project here
    if (defined $module::modules{$where}->{$cmd}) {
      delete($module::modules{$where}->{$cmd});
      return $cmd;
    }
    else { return 0; }
  }
}

sub cat {
  my ($file, $nickname, $channel, $min, $max) = ($_[1], $_[2], $_[3], $_[4], $_[5]);
  if (! -f $file) {
    commands->send("NOTICE $nickname :No such file");
    return 0;
  }
  else {
    open my $cfid, "< $file";
    my @data = <$cfid>;
    close $cfid;
    $min = 0 if !defined $min;
    $max = int(@data) if !defined $max;
    if ($min > $max) {
      commands->send("NOTICE $nickname :Reverse the minimum and maximum numbers in your command please \;p");
      return 0;
    }
    $max = int(@data) if $max > int(@data);
    my $i = 0;
    for my $line (@data) {
      next if $line eq "";
      $i++;
      last if $i == $max;
      next if $i < $min;
      commands->send("PRIVMSG $channel \:$line");
    }
  }
}
commands->add('channel', 'owner', '!cat', 'commands->cat($data[0], $nickname, $channel, $data[1], $data[2])');
commands->add('channel', 'owner', '!srmsg', 'my ($chan, $nick, $msg) = (shift(@data), shift(@data), join(" ", @data)); commands->send("SENDRAW $chan \:\:$nick PRIVMSG $chan \:$msg")');
sub change {
  my ($where, $type, $newcmd, $code) = ($_[1], $_[2], $_[3], $_[4]);
  if ($where eq 'channel') {
    if (defined $channel::cmd{$type}->{$newcmd}) {
      $channel::cmd{$type}->{$newcmd} = $code;
      print $channel::cmd{$type}->{$newcmd}."\n";
      return $newcmd;
    }
    else { return 0; }
  }
  elsif ($where eq 'query') {
    if (defined $query::cmd{$type}->{$newcmd}) {
      $query::cmd{$type}->{$newcmd} = $code;
      return $newcmd;
    }
    else { return 0; }
  }
  elsif ($where eq 'notice') {
    if (defined $notice::cmd{$type}->{$newcmd}) {
      $notice::cmd{$type}->{$newcmd} = $code;
      return $newcmd;
    }
    else { return 0; }
  }
  elsif ($where eq 'telnet') {
    if (defined $telnet::cmds::cmd{$type}->{$newcmd}) {
      $telnet::cmds::cmd{$type}->{$newcmd} = $code;
      return $newcmd;
    }
    else { return 0; }
  }
  elsif (defined $module::modules{$where}->{'version'}) {
    #this is my special little project here
    if (defined $module::modules{$where}->{$newcmd}) {
      $module::modules{$where}->{$newcmd} = $code;
      return $newcmd;
    }
    else { return 0; }
  }
}

sub clean {
  my $what = $_[1];
  if ($what eq 'all') {
    # do cleanup for everything
  }
  elsif ($what eq 'logs') {
    `mv -f logs/chans/*.tar.gz logs/backup/chans/`;
    `mv -f logs/users/*.tar.gz logs/backup/users/`;
    `mv -f logs/bot/*.tar.gz logs/backup/bot/`;
    `mv -f logs/server/*.tar.gz logs/backup/server/`;
  }
}

commands->add("channel", "owner", "!smusr", '
              $core::socket->send("WHO\r\n");
              my $tmp_cmd = $parameters;
              for my $usr (sort keys %users::users) {
                $tmp_cmd =~ s/%n/$usr/;
                $core::socket->send($tmp_cmd."\r\n");
                $tmp_cmd = $parameters;
                next;
              }
');

sub send {
  my ($text) = ($_[1]);
  $core::socket->send("$text\r\n");
}

sub msg {
  my ($target, $message) = ($_[1], $_[2]);
  $core::socket->send("PRIVMSG $target :$message\r\n") if defined $message;
}

sub describe {
  my ($target, $message) = ($_[1], $_[2]);
  $core::socket->send("PRIVMSG $target :ACTION $message\r\n") if defined $message;
}
1;
