#!/usr/bin/perl

use Cwd 'abs_path';
use File::Basename;
use File::Copy;

# @suffixes = (".mkv", ".mov", ".mp4", ".m4v"); ## currently unused



main();

sub main {
	my $curDir = getCurrentPath();
	print "$curDir\n";
	chdir "$curDir";

	my $showname = userInput("Please enter the name of the show");
	my @files = getFileList();

	$commitChanges = checkyN("Rename files (otherwise just simulate)?");

	renameFiles($showname, \@files);

}

sub renameFiles {
	my $showname = $_[0];
	my @files = @{$_[1]};

	foreach my $file (@files) {
		my $newName = generateNewName($showname, $file);
		if (defined $newName) {
			print "$file ->\n$newName\n\n";
			if ($commitChanges) {
				move($file,$newName);
			}

		}

	}
}

sub generateNewName {
	my $showname = $_[0];
	my $oldName = $_[1];

	# separate filename components
	my %fileComp = getFileComponents($oldName);
	my $oldBase = $fileComp{"base"};
	# print "oldbase $oldBase\n";
	my $ext = $fileComp{"ext"};
	# print "ext $ext\n";


	# extract season and episode info
	# [Cleo]Attack_on_Titan_S2_-_01_(Dual Audio_10bit_720p_x265)
	# $oldBase =~ /(s)(\d+)[^\D]*(\d+)/i;
	$oldBase =~ /(s|season)(\d{0,2})[^\D]*(e|episode)?(\d+)/i; ## works on harmonquest
	# $oldBase =~ /s(\d+)e(\d+)/i;

	my $season = $2;
	my $episode = $4;

	# print "season: $season\n";
	# print "episode: $episode\n";

	if ((length $season) == 0) {
		$season = seasonEpisodeInput("old: $oldBase:\nPlease enter the SEASON. (Any non numerical input will skip this file)");
	}
	# if ($season ne "-") {
	# 	print "season defined\n";
	# } else {
	# 	print "season undefined\n";
	# }

	if ((length $episode) == 0 && ($season ne "-")) {
		$episode = seasonEpisodeInput("old: $oldBase:\nPlease enter the EPISODE. (Any non numerical input will skip this file)");
	}

	my $newName = "$showname.s$season" . "e$episode$ext";


	if (($season eq "-") || ($episode eq "-")) {
		undef $newName
	}

	return $newName;
}



sub getFileList {
	my @files = <*>;
	return @files;
}


sub getCurrentPath {
	my $curPath = abs_path($0);
	my($filename, $dirs) = fileparse($curPath);

	return $dirs;
}

sub getFileExtension {
	my $path = $_[0];
	$path =~ /(.*)(\.\w+)$/;
	my $basename = $1;
	my $ext = $2;
	# my %dict;
	# $dict{"base"} = $basename;
	# $dict{"ext"} = $ext;

	return $ext;
}

sub getFileComponents {
	my $path = $_[0];
	$path =~ /(.*)(\.\w+)$/;
	my $basename = $1;
	my $ext = $2;
	my %dict;
	$dict{"base"} = $basename;
	$dict{"ext"} = $ext;

	return %dict;
}

sub checkyN {
    my $prompt = $_[0] . " [y/N]:";
    print "$prompt";
    my $rVal = -1;
    while($rVal == -1) {
        chomp(my $yn = <STDIN>);
        if ($yn =~ /^y+$/i) {
            $rVal = 1;
        } elsif ($yn =~ /^n*$/i) {
            $rVal = 0;
        } else {
            print "Sorry, that's not valid input. Please try again:\n\n$prompt";
        }
    }
    return $rVal;
}


sub userInput {
    my $prompt = $_[0] . ":";
    print "$prompt";
    my $rVal;
    while(!defined $rVal) {
        chomp(my $userTyped = <STDIN>);
        $rVal = sanitizeUserInput($userTyped);
        if (!defined $rVal) {
            print "Sorry, that's not valid input. Please try again:\n\n$prompt";
        }
    }
    return $rVal;
}

sub sanitizeUserInput {
    my ($userTyped) = @_;
    ## process $userTyped here - return undef if new input is required;
    chomp($userTyped);
    if ((length $userTyped) == 0) {
		undef $userTyped;
    }
    return $userTyped;
}

sub seasonEpisodeInput {
    my $prompt = $_[0] . ":";
    print "$prompt";
    my $rVal;
    while(!defined $rVal) {
        chomp(my $userTyped = <STDIN>);
        $rVal = sanitizeSeasonEpisodeInput($userTyped);
    }
    return $rVal;
}

sub sanitizeSeasonEpisodeInput {
    my ($userTyped) = @_;
    ## process $userTyped here - return undef if new input is required;
    chomp($userTyped);
    if ((length $userTyped) == 0 || ($userTyped =~ /\D/)) {
		$userTyped = "-";
    }
    return $userTyped;
}
