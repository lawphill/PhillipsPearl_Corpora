#! usr/bin/perl

use utf8;

# Clean up the morph & funcwords Farsi files, removing extra information and turning the remaining words into their IPA equivalents.

open(MORPH,"<Farsi/morphemes-ortho.txt") or die("couldn't open morpheme-ortho.txt\n");
@morph = <MORPH>; chomp(@morph);
close(MORPH);

open(FUNC,"<Farsi/funcwords-ortho.txt") or die("couldn't open funcwords-ortho.txt\n");
@func = <FUNC>; chomp(@func);
close(FUNC);

open(OUTM,">Farsi/morphemes-phon.txt") or die("couldn't open morph-phon.txt for writing\n");
open(OUTF,">Farsi/funcwords-phon.txt") or die("couldn't open funcwords-phon.txt for writing\n");

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
