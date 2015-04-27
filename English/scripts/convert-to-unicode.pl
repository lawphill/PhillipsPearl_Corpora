#! usr/bin/perl
use warnings;
use strict;

# Convert Brent file to unicode

# Read unicode/word pairs from unicode-word-dict.txt
open(my $dict_fh, "<dicts/unicode-word-dict.txt") or die "Couldn't open unicode-word-dict.txt for reading\n";
binmode($dict_fh, ":utf8");
my @dict_lines = <$dict_fh>; chomp(@dict_lines);
close($dict_fh);

my %dict;
foreach my $dict_line (@dict_lines){
	if($dict_line =~ /(.+)\t(.+)$/){
		$dict{$1} = $2;  
	}
}

# Read Ortho corpus
my $ortho_orig = '../brent9mos.txt';
system("cp -b $ortho_orig ../English-ortho.txt");

open(my $corpus_fh, "<../English-ortho.txt") or die("Couldn't open English-ortho.txt: $!\n");
binmode($corpus_fh, ":utf8");
my @ortho_lines = <$corpus_fh>; chomp(@ortho_lines);
close($corpus_fh);

# Print out Unicode corpus
open(my $unicode_fh, ">../English-uni.txt") or die("Couldn't open English-uni.txt: $!\n");
binmode($unicode_fh, ":utf8");


for my $i (0..$#ortho_lines){
	my $line = $ortho_lines[$i];

	my @words = split(/ /,$line);

	# go through and replace
	my $index = 0;
	for my $j (0..$#words){
		my $word = $words[$j];
		# switch uppercase letters to lowercase letters
		$word =~ tr/[A-Z]/[a-z]/;
		# check to make sure word has some characters in it
		if($word =~ /./){
			# check to see if in dict hash
			if(exists($dict{$word})){
				print $unicode_fh $dict{$word};
				if($j < $#words){ print $unicode_fh " "; }
			}
		}
	}
	if($i < $#ortho_lines){ print $unicode_fh "\n"; }
}
close($unicode_fh);
