#! usr/bin/perl
use warnings;
use strict;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib './';

use Syllabification qw(print_array);

# Convert the orthographic Brent corpus into a phonetic, and syllabified form.

open(my $syllable_dictionary,"<","English/dicts/syllabified-dict.txt") or die("Couldn't open syllabified-dict.txt: $!\n");
my @syllable_lines = <$syllable_dictionary>; chomp(@syllable_lines);
close($syllable_dictionary);

open(my $brent_corpus,"<","English/English-ortho.txt") or die("Couldn't open English-ortho.txt: $!\n");
my @brent = <$brent_corpus>; chomp(@brent);
close($brent_corpus);

# Process Syllable Dictionary
my %syllables;
foreach (@syllable_lines){
	my @fields = split(/\t/,$_);
	$syllables{$fields[0]} = $fields[1];
}

my @syllabified_brent;
my @phonetic_brent;
my @not_found;

for my $i (0..$#brent){
	$syllabified_brent[$i] = '';
	my @words = split(/\s+/,lc($brent[$i]));
	for my $j (0..$#words){
		if($syllables{$words[$j]} =~ /^.+$/){
			$syllabified_brent[$i] .= $syllables{$words[$j]};
		}else{
			$syllabified_brent[$i] .= 'NA';
			push(@not_found,$words[$j]);
		}
		if ($j < $#words){ $syllabified_brent[$i] .= ' '; }
	}
	$phonetic_brent[$i] = $syllabified_brent[$i];
	$phonetic_brent[$i] =~ s/\///g; # Remove syllabification for the purely phonetic version
}

my $syllable_file = 'English/English-syl.txt';
my $phonetic_file = 'English/English-phon.txt';

print_array(\@syllabified_brent,$syllable_file);
print_array(\@phonetic_brent,$phonetic_file);

print "$#not_found\n";
