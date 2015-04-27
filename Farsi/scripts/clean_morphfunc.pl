#! usr/bin/perl

use utf8;

# Clean up the morph & funcwords Farsi files, removing extra information and turning the remaining words into their IPA equivalents.

open(MORPH,"<FarsiMorphemes.txt") or die("couldn't open FarsiMorphemes.txt\n");
@morph = <MORPH>; chomp(@morph);
close(MORPH);

open(FUNC,"<FarsiFunctionWords.txt") or die("couldn't open FarsiFunctionWords.txt\n");
@func = <FUNC>; chomp(@func);
close(FUNC);

open(OUTM,">../../analysis/morph_farsi.txt") or die("couldn't open morph_farsi.txt for writing\n");
open(OUTF,">../../analysis/funcwords_farsi.txt") or die("couldn't open funcowrds_farsi.txt for writing\n");

# Convert Morphology
for($i=0;$i<@morph;$i++){
	$line = $morph[$i];
	$word = &translate($line);

	print OUTM "$word";
	if($i+1!=@morph){ print OUTM "\n"; }
}
close(OUTM);

# Convert Function Words
for($i=0;$i<@func;$i++){
	$line = $func[$i];
	$word = &translate($line);

	print OUTF "$word";
	if($i+1!=@func){ print OUTF "\n"; }
}
close(OUTF);

sub translate{
	my $word = $_[0];
	$word =~ s/æ/&/g;
	$word =~ s//S/g;
	$word =~ s/ //g;
	$word =~ s/-//g;
	$word =~ s/'//g;
	$word =~ s/è/e/g;
	$word =~ s/://g;
	$word =~ s/sh/S/g;
	$word =~ s/ch/c/g;
	$word =~ s/q/8/g;
	$word =~ s/kh/x/g;

	$word;	
}
