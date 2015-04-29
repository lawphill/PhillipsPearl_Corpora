#! usr/bin/perl

# Clean up the morph & funcwords Japanese files, removing extra information and turning the remaining words into their IPA equivalents.

open(MORPH,"<morph_text_japanese.txt") or die("couldn't open morph_text_japanese.txt\n");
@morph = <MORPH>; chomp(@morph);
close(MORPH);

open(FUNC,"<funcwords_text_japanese.txt") or die("couldn't open funcwords_text_japanese.txt\n");
@func = <FUNC>; chomp(@func);
close(FUNC);

open(OUTM,">../../analysis/morph_japanese.txt") or die("couldn't open morph_japanese.txt for writing\n");
open(OUTF,">../../analysis/funcwords_japanese.txt") or die("couldn't open funcowrds_japanese.txt for writing\n");

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
	$line =~ /^\-?([\w ]*)[\:\-\[\]\(\)]?.*$/;
	$1;
}

sub translate{
	my $word = $_[0];
	$word =~ s/j/G/g;
	$word =~ s/aa/A/g;
	$word =~ s/e[ie]/E/g;
	$word =~ s/ii/I/g;
	$word =~ s/o[ou]/O/g;
	$word =~ s/uu/U/g;
	$word =~ s/shit/shYt/g;
	$word =~ s/masu/masW/g;
	$word =~ s/desu/desW/g;
	$word =~ s/sh/S/g;

	$word;	
}
