#! usr/bin/perl

# Clean up the morph & funcwords Japanese files, removing extra information and turning the remaining words into their IPA equivalents.

open(MORPH,"<Japanese/morphemes-ortho.txt") or die("couldn't open morphemes-ortho.txt: $!\n");
@morph = <MORPH>; chomp(@morph);
close(MORPH);

open(FUNC,"<Japanese/funcwords-ortho.txt") or die("couldn't open funcwords-ortho.txt: $!\n");
@func = <FUNC>; chomp(@func);
close(FUNC);

open(OUTM,">Japanese/morphemes-phon.txt") or die("couldn't open morphemes-phon.txt for writing: $!\n");
open(OUTF,">Japanese/funcwords-phon.txt") or die("couldn't open funcwords-phon.txt for writing: $!\n");

# Convert Morphology
for($i=0;$i<@morph;$i++){
	$line = $morph[$i];
	$word = &remove_extra($line);
	$word = &translate($word);

	print OUTM "$word";
	if($i<$#morph){ print OUTM "\n"; }
}
close(OUTM);

# Convert Function Words
for($i=0;$i<@func;$i++){
	$line = $func[$i];
	$word = &remove_extra($line);
	$word = &translate($word);

	print OUTF "$word";
	if($i<$#func){ print OUTF "\n"; }
}
close(OUTF);

sub remove_extra{
	my $line = $_[0];
	$line =~ /^\-?([\w ]*)[\:\-\[\]\(\)]?.*$/;
	return $1;
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

	return $word;	
}
