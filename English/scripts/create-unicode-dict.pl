#!/usr/bin/perl
use strict;
use warnings; 

# Creates/updates unicode-dict.txt
# unicode-dict.txt is a dictionary of possible syllabes, taken from syllabified-dict.txt
# represented as unicode characters.
 
my %dict; 
# a simple way to generate unicode assignments for whatever units we encounter
my $base = 3001; # shouldn't be any control characters below this range
my $current_uni = 0;

binmode(STDOUT, ":utf8");
open(my $syl_fh, "<dicts/syllabified-dict.txt") or die "Couldn't open syllabified-dict.txt: $!\n";
my @syl_dict = <$syl_fh>; chomp(@syl_dict);
close($syl_fh);

open(my $worddict_fh, ">dicts/unicode-word-dict.txt") or die "Couldn't open unicode-word-dict.txt: $!\n";
binmode($worddict_fh, ":utf8");

my %dup_hash; #hash for checking duplicate unicode values

# assign unicode characters to syllabes in syllabified-dict.txt
# also print word/unicode pairs to unicode-word-dict.txt

for my $i (0..$#syl_dict){
	my $fileline = $syl_dict[$i];
	$fileline =~ /^(.+)\t(.+)$/;
	print $worddict_fh "$1\t";

	my @syls_to_enter = split(/\//,$2);
	foreach my $syl (@syls_to_enter){
	  if(!exists($dict{$syl})){
		# add syllable to word/unicode dict
		my $char = chr(hex($current_uni + $base));
		if ($char =~ /\s/){ # Avoid any whitespace characters just in case
			while ($char =~ /\s/){
				$current_uni++;
				$char = chr(hex($current_uni+$base));
			}
		}
		$dict{$syl} = $char;
		if(exists($dup_hash{$char})){	
			$dup_hash{$char}++;
			print STDOUT "duplicate for $syl: $dup_hash{$char}\n";
		}else{ $dup_hash{$char} = 1; }

		# increment $current_uni
		$current_uni++;
	  }
	  print $worddict_fh "$dict{$syl}";
	}
	if($i < $#syl_dict){ print $worddict_fh "\n"; }
}
close($worddict_fh);

# print out new unicode dictionary to unicode-dict.txt
open(my $unicode_fh, ">dicts/unicode-dict.txt") or die "Couldn't open unicode-dict.txt: $!\n";
binmode($unicode_fh, ":utf8");
foreach my $syl (sort (keys %dict)){
	if($syl !~ /^$/){
		print $unicode_fh "$syl\t$dict{$syl}\n";
	}
}
close($unicode_fh);
