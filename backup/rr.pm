#!\usr\bin\perl

package rr;
use strict;
use warnings;

our $version = "1.0 glitch~";
our %rr;
our %rrtmp;
our $state = 0;
our $turn = $config::nickname;
our @players;
our @played;
our $playernum = 0;
our $gamechan;
our $starter;
commands->add('channel', 'normal', '!rr', 'rr->start($nickname, $ident, $vhost, $channel, $parameters);');




sub start {
  my ($nickname, $ident, $vhost, $channel, $parameters) = ($_[1], $_[2], $_[3], $_[4], $_[5]);
  if ($parameters eq 'start') {
    if ($state == 1 || $state == 2) {
      commands->send("NOTICE $nickname :Rusian Roulette is already active on $gamechan");
      return 0;
    }
    elsif ($state == 0) {
      commands->msg($channel, "Russian Roulette game has been started by $nickname, There are currently 5 available spots left type !rr join to join this round");
      $state = 1;
      $playernum++;
      push(@players, $nickname);
      $starter = $nickname;
      $gamechan = $channel;
    }
  }
  elsif ($parameters eq 'join') {
    if ($state == 0) {
      commands->send("NOTICE $nickname :Rusian Roulette isn't currently on type !rr start to start a round");
      return 0
    }
    if ($channel ne $gamechan) {
      commands->send("NOTICE $nickname :Try typing !rr join in the chan the game is currently active in \($gamechan\)");
      return 0
    }
    if (scalar(@players) < 6) {
      if (defined $players[0] && join(" ", @players) =~ /$nickname/) {
        commands->send("NOTICE $nickname :Your already in the queue of players!");
        return 0;
      }
      push(@players, $nickname);
      $playernum++;
      my $points = 0;
      if ( defined $players[0] && -f "data\/rr\/$players[0]\.rr") {
        open my $rrfid, "< data/rr/$players[0]\.rr";
        $points = <$rrfid>;
        close $rrfid;
      }
      commands->send("NOTICE $nickname :Your currently player \#$playernum\, now just wait for either all 5 spots ot be filled or for $starter to type !rr play, Current Points: $points");
      commands->msg($channel, "Current players are: ".join(" ", @players));
      return 0;
    }
    else {
      commands->msg($channel, "Game queue is full! $starter type !rr play, to begin this round");
      return 0;
    }
  }
  elsif ($parameters eq 'play') {
    if ($nickname eq $starter && $state == 1 && scalar(@players) > 1) {
      $state = 2;
      $turn = $nickname;
      commands->msg($gamechan, "Game started! $starter you go first type !rr to pull the trigger");
      return 0;
    }
  }
  elsif (!$parameters) {
    if ($state == 2) {
      if ($turn eq $nickname) {
        my $rnd = int rand 4;
        if ($rnd == 1 || $rnd == 4) {
          commands->send("KICK $gamechan $nickname :BANG nigger, your dead, Points this round: 0");
          shift(@players);
          delete $rrtmp{$nickname} if defined $rrtmp{$nickname};
          commands->msg($gamechan, "$nickname is down!.. The round isn't over until only one person remains.. Players left: ".join(" ", @players));
          commands->msg($gamechan, "its your turn $players[0], type !rr") if defined $players[1];
          $turn = $players[0];
        }
        else {
          $rrtmp{$nickname}++;
          commands->msg($gamechan, "CLICK!, You survived! Points so far: $rrtmp{$nickname}");
          push(@players, shift(@players));
          commands->msg($gamechan, "its your turn $players[0], type !rr") if defined $players[1];
          $turn = $players[0];
          return 0;
        }
      }
      if (!defined $players[1]) {
        $rrtmp{$players[0]} = 1 if !defined $rrtmp{$players[0]};
        commands->msg($gamechan, "Congrats $players[0]\! you won this round!! for a total of $rrtmp{$players[0]} points.");
        if (! -f "data\/rr\/$players[0]\.rr") {
          open my $rrfid, ">> data/rr/$players[0]\.rr";
          print $rrfid $rrtmp{$players[0]};
          close $rrfid;
          delete $rrtmp{$players[0]};
        }
        $state = 0;
        $playernum = 0;
        @players = "";
        $turn = $config::nickname;
        return 0;
      }
    }
  }
}


1;
