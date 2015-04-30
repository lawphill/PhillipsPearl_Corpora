#! usr/bin/perl

use utf8;

# Clean up the morph & funcwords Italian files, removing extra information and turning the remaining words into their IPA equivalents.

# Using :utf8 to deal with accented characters in the original files.

open(MORPH,"<ItalianMorphemes.txt") or die("couldn't open ItalianMorphemes.txt\n");
@morph = <MORPH>; chomp(@morph);
close(MORPH);

open(FUNC,"<ItalianFunctionWords.txt") or die("couldn't open ItalianFunctionWords.txt\n");
@func = <FUNC>; chomp(@func);
close(FUNC);

open(OUTM,">../../../analysis/morph_italian.txt") or die("couldn't open morph_italian.txt for writing\n");
open(OUTF,">../../../analysis/funcwords_italian.txt") or die("couldn't open funcowrds_italian.txt for writing\n");

# Convert Morphology
for($i=0;$i<@morph;$i++){
	$line = $morph[$i];
	$word = &remove_extra($line);
	$word = &translate($word);

	print OUTM "$word";
	if($i+1!=@morph){ print OUTM "\n"; }
}
close(OUTM);

# Convert Function Words
for($i=0;$i<@func;$i++){
	$line = $func[$i];
	$word = &remove_extra($line);
	$word = &translate($word);

	print OUTF "$word";
	if($i+1!=@func){ print OUTF "\n"; }
}
close(OUTF);

sub remove_extra{
	my $line = $_[0];
	$line =~ /^\-?(.*)\-?$/;
	$1;
}

sub translate{
	my $word = $_[0];

	$word =~ s/ò/o/g; # Remove Diacritics
	$word =~ s/à/a/g;
	$word =~ s/é/e/g;
	$word =~ s/è/e/g;
	$word =~ s/ù/u/g;
	$word =~ s/nc/9c/g; # velar nasal
	$word =~ s/cia/1a/g; # CH sounds
	$word =~ s/cio/1o/g;
	$word =~ s/ciu/1u/g;
	$word =~ s/ci/1i/g;
	$word =~ s/ce/1e/g;
	$word =~ s/chi/ki/g; # K sounds
	$word =~ s/che/ke/g;
	$word =~ s/c/k/g;
	$word =~ s/gia/3a/g; # Hard J sounds
	$word =~ s/giu/3u/g;
	$word =~ s/gio/3o/g;
	$word =~ s/gi/3i/g;
	$word =~ s/ge/3e/g;
	$word =~ s/ghi/gi/g; # g sounds
	$word =~ s/ghe/ge/g;
	$word =~ s/zz/2/g; # dz sounds
	$word =~ s/glio/4o/g; # palatal lateral
	$word =~ s/glia/4a/g;
	$word =~ s/gliu/4u/g;
	$word =~ s/gli/4i/g;
	$word =~ s/gn/5/g; # palatal nasal
	$word =~ s/s/6/g; # s sounds

	$word =~ s/'//g;
	$word =~ s/ //g;
	$word =~ s/\-//g;

	$word;	
}
