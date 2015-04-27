#! usr/bin/perl
use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib './';

use Syllabification qw(maximum_onset_principle);

# Uses the maximum onset principle to fully syllabify the Callhome dictionary 
# and print it to syllabified-dict.txt.

my $vowels = 'iIeE@acoUuYOWRx^';

# Save valid onsets from ValidOnsets.txt
my %onsets;
open(my $onset_fh, "<English/dicts/ValidOnsets.txt") or die("Couldn't open ValidOnsets.txt: $!\n");
while(defined(my $fileline = <$onset_fh>)){
		chomp($fileline);
		$fileline =~ s/L/l/g;
		$fileline =~ s/G/J/g;
		$fileline =~ s/\~/n/g;
		$fileline =~ s/N/G/g;
		$fileline =~ s/c/C/g;
		$fileline =~ s/M/m/g;
		$fileline =~ s/\r//g;
		$onsets{$fileline} = 1;
}
close($onset_fh);

open(my $mrc_fh, "<English/dicts/mrc-call-syllabified.txt") or die("Couldn't opne mrc-call-syllabified.txt for reading: $!\n");
my %mrccall; # hash holds already syllabified word = syllabification
while(defined(my $fileline = <$mrc_fh>)){
	chomp($fileline);
	if ($fileline =~ /^([\w|\@|\'|\-|\^]+)\s*(.*)$/){
		my $ortho = $1; my $ipa = $2;
		# Clean up the MRC dictionary to match our Klattese format
		$ipa =~ s/eI/e/g;
		$mrccall{$ortho} = $ipa;
	}
}
close($mrc_fh);

# Go through dict-brent.txt,
# for nonsyllabified words: for each syllable, find its vowel, and its maximum onset, given acceptable onsets and beginning of word.
# print syllabified version to syllabified-dict.txt.
open(my $syl_fh, ">English/dicts/syllabified-dict.txt") or die("Couldn't open syllabified-dict.txt for writing: $!\n");
open(my $brent_fh, "<English/dicts/dict-Brent-Klatt.txt") or die("Couldn't open dict-brent-klatt.txt for reading: $!\n");
my @englishwords=();  #the words in non-IPA, normal english. 

my $count_fromMRC=0; my $count_fromMOP=0;

open(my $none_fh,">English/dicts/no_syllabification.txt") or die("Couldn't open no_syllabification.txt for writing: $!\n");

my @lines = <$brent_fh>; chomp(@lines);
for my $i (0..$#lines){
	my $fileline = $lines[$i];
	my $entry;
	# extract first syllable and add to list of acceptable onsets.
	if($fileline =~ /^([\w|\@|\'|\-|\^]+)\s*(.*)$/){
		my $curreng = $1; # english word
		if (exists($mrccall{$curreng})){ # if there's already a syllabification use it
			$entry = $mrccall{$curreng};
			$entry =~ s/\r//g;
			$count_fromMRC++;
		}else{ # otherwise start doing an automatic segmentation
			$count_fromMOP++;
			print $none_fh "$curreng\n";
			my $ipa = $2; # IPA transcription
			
			$entry = maximum_onset_principle($ipa,$vowels,\%onsets);
		}
		print $syl_fh "$curreng\t$entry";
		if($i < $#lines){ print $syl_fh "\n"; }
	}
}

close($syl_fh);
close($brent_fh);
close($none_fh);

my $verbose = 0;
if($verbose == 1){
	print "Number of syllabifications\nFrom MRC:\t$count_fromMRC\nFrom MOP:\t$count_fromMOP\n";
}
