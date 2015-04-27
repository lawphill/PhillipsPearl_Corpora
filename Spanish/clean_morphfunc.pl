#! usr/bin/perl

use utf8;

# Clean up the morph & funcwords Italian files, removing extra information and turning the remaining words into their IPA equivalents.

# Using :utf8 to deal with accented characters in the original files.

open(MORPH,"<morphology_orthography.txt") or die("couldn't open Spanish Morphemes.txt\n");
@morph = <MORPH>; chomp(@morph);
close(MORPH);

open(FUNC,"<funcwords - spanish.txt") or die("couldn't open Spanish Function Words.txt\n");
@func = <FUNC>; chomp(@func);
close(FUNC);

open(OUTM,">../../../analysis/morph_jacksonthal.txt") or die("couldn't open morph_jacksonthal.txt for writing\n");
open(OUTF,">../../../analysis/funcwords_jacksonthal.txt") or die("couldn't open funcowrds_jacksonthal.txt for writing\n");

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

	$word =~ s/é/e/g; # Remove diacritics
	$word =~ s/á/a/g;
	$word =~ s/ó/o/g;
	$word =~ s/í/i/g;
	$word =~ s/ú/u/g;
	$word =~ s/([aeiour])b([aeiourl])/$1B$2/g; # b->B, d->D, g->G
	$word =~ s/([aeiour])d([aeiourl])/$1D$2/g;
	$word =~ s/([aeiour])g([aeiourl])/$1G$2/g;
	$word =~ s/qu/k/g; # Silent-u phrases
	$word =~ s/([ n])gua/$1g\&/g;
	$word =~ s/gue/ge/g;
	$word =~ s/gui/gi/g;
	$word =~ s/Gue/Ge/g;
	$word =~ s/Gui/Gi/g;
	$word =~ s/c([ei])/s$1/g; # Soft-c
	$word =~ s/ch/1/g;
	$word =~ s/c/k/g;
	$word =~ s/1/c/g; # used 1 as a tmp work-around
	$word =~ s/ia/\%/g; # Diphthongs
	$word =~ s/ie/\#/g;
	$word =~ s/io/\@/g;
	$word =~ s/ue/\$/g;
	$word =~ s/ua/\&/g;
	$word =~ s/ui/\!/g;
	$word =~ s/ei/\*/g;
	$word =~ s/au/\+/g;
	$word =~ s/ai/\-/g;
	$word =~ s/oi/3/g;
	$word =~ s/ll/j/g; # assorted

	$word;	
}
