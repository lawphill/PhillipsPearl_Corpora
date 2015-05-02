#! usr/bin/perl
use strict;
use warnings;
use utf8;

# Clean up the morph & funcwords Spanish files, removing extra information and turning the remaining words into their IPA equivalents.
# Using :utf8 to deal with accented characters in the original files.
my $ortho_morphology_file = 'Spanish/morphemes-ortho.txt';
my $ortho_funcwords_file = 'Spanish/funcwords-ortho.txt';

open(my $morphology_fh,"<",$ortho_morphology_file) or die("couldn't open $ortho_morphology_file: $!\n");
my @ortho_morphology = <$morphology_fh>; chomp(@ortho_morphology);
close($morphology_fh);

open(my $func_fh,"<",$ortho_funcwords_file) or die("couldn't open $ortho_funcwords_file: $!\n");
my @ortho_funcwords = <$func_fh>; chomp(@ortho_funcwords);
close($func_fh);

my $phon_morphology_file = 'Spanish/morphemes-phon.txt';
my $phon_funcwords_file = 'Spanish/funcwords-phon.txt';

# Convert Morphology
open(my $morph_out_fh,">",$phon_morphology_file) or die("couldn't open $phon_morphology_file: $!\n");
for my $i (0..$#ortho_morphology){
	print $morph_out_fh &translate($ortho_morphology[$i]);
	if($i<$#ortho_morphology){ print $morph_out_fh "\n"; }
}
close($morph_out_fh);

# Convert Function Words
open(my $func_out_fh,">",$phon_funcwords_file) or die("couldn't open $phon_funcwords_file: $!\n");
for my $i (0..$#ortho_funcwords){
	print $func_out_fh translate($ortho_funcwords[$i]);
	if($i<$#ortho_funcwords){ print $func_out_fh "\n"; }
}
close($func_out_fh);

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

	return $word;	
}
