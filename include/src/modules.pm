#!/usr/bin/perl

package modules;

use strict;
use warnings;

our %modules;

my @dirs = qw(AI bot games misc oper rpg src users channels); # don't allow additional dirs to read by the bot
 
for my $dir (@dirs) {
  my $strdir = "include/modules/".$dir."/";
  my @moddirs = <$strdir\*.pm>;
  for my $moddir (@moddirs) {
  modules->add($strdir,$moddir);
  }
}

commands->add('channel', 'ops', '!modules', 'modules->list($channel);');
commands->add('channel', 'owner', '!addmod', 'modules->add($parameters, $channel)');
commands->add('channel', 'owner', '!unload', 'modules->unload($channel, $parameters)');

sub add {
  my ($dir, $module, $require, $target) = ($_[1], $_[2], $_[2], $_[3]);
  $module =~ s/$dir//;
  $module =~ s/\.pm//;
  if (! -f $require) {
    print "No such file $require\n";
    commands->send("PRIVMSG $target :No such file $require") if defined $target;
    return 1;
  }
  if (!defined $modules{$module}->{'version'}) {
    eval { require $require; } || error->handle($module, $@);
    my $version = eval("\$$module\::version");
    die "Can't find module version for $module\n" if !defined $version;
    $modules{$module} = { 
      version => $version,
      name => $module};
    print "Module $module loaded\n";
    commands->send("PRIVMSG $target :Module $module loaded") if defined $target;
    return 1;
  }
  else {
    print "Module $module already exists (Change the module name of $require)\n";
    commands->send("PRIVMSG $target :Module $module already exists (Change the module name of $require)") if defined $target;
    return 0;
  }
}

sub list {
  my ($target, @coremdls) = ($_[1], <include/*.pm>);
  commands->send("PRIVMSG $target \:Core Modules \($config::version\):");
  for my $coremdl (sort @coremdls) {
    next if $coremdl eq 'include/modules.pm';
    $coremdl =~ s/include\///;
    $coremdl =~ s/\.pm//;
    commands->msg($target, $coremdl);
  }
  commands->msg($target, "External modules (include/modules/):");
  for my $dir (@dirs) {
    commands->msg($target, "Modules in $dir\:");
    my $strdir = "include/modules/".$dir."/";
    my @moddirs = <$strdir\*.pm>;
    for my $moddir (@moddirs) {
      $moddir =~ s/$strdir//;
      $moddir =~ s/\.pm//;
      commands->msg($target, "\~ $moddir \- ".$modules::modules{$moddir}->{'version'});
    }
  }
}

sub unload {
	my ($channel, @data) = ($_[1], split(" ", $_[2]));
	my $unload = $data[0];
	
	if($unload) {
		unrequire $unload;
		commands->msg($channel, 'Unloaded module '.$unload.'');
	}
	if(!$unload) {
		commands->msg($channel, 'Usage: !unload <module>');
	}
}

1;
