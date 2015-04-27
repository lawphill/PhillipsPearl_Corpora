#! usr/bin/perl

# Clean up the morph & funcwords German files, removing extra information and turning the remaining words into their IPA equivalents.

open(MORPH,"<morph_german.txt") or die("couldn't open morph_german.txt\n");
@morph = <MORPH>; chomp(@morph);
close(MORPH);

open(FUNC,"<funcwords_german.txt") or die("couldn't open funcwords_german.txt\n");
@func = <FUNC>; chomp(@func);
close(FUNC);

open(OUTM,">../../../analysis/morph_carol.txt") or die("couldn't open morph_carol.txt for writing\n");
open(OUTF,">../../../analysis/funcwords_carol.txt") or die("couldn't open funcowrds_carol.txt for writing\n");

# Convert Morphology
for($i=0;$i<@morph;$i++){
	$word = $morph[$i];

	print OUTM "$word";
	if($i+1!=@morph){ print OUTM "\n"; }
}
close(OUTM);

# Convert Function Words
for($i=0;$i<@func;$i++){
	$word = $func[$i];

	print OUTF "$word";
	if($i+1!=@func){ print OUTF "\n"; }
}
close(OUTF);
