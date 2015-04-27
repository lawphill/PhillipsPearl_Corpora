#! usr/bin/perl

use utf8;

# This code will syllabify the Italian and Hungarian Corpora.
# 
# 1) Create list of Syllables and Unicode equivalents
# 2) Syllabify corpus
#
# Files you'll need:
#  italian_corpus.txt
#  hungarian_corpus.txt
#  run_syllabification.pl (this file)
#
# Made by Lawrence Phillips 2/29/2012
# For questions/comments/feedback reach me at lawphill@gmail.com

# CREATE ITALIAN UNICODE DICTIONARY & REPLACE SYLLABLES WITH UNICODE

%uni_dict; %word_dict;
undef(@corp);
open(CORP,"<italian_corpus.txt")or die("Couldn't open italian_corpus.txt\n");
@corp = <CORP>;
close(CORP);

$base=3001;$i=0;
print "Replacing with Unicode encoding\n";
open(UNI,">italian.uni")or die("Couldn't open italian.uni\n");
binmode(UNI,":utf8");
foreach $line (@corp){
	chomp($line);
	@words = split(/ /,$line);
	foreach $word (@words){
		$word_uni = "";
		@syls = split(/\//,$word);
		foreach $syl (@syls){
			if(exists($uni_dict{$syl})){
			}else{
				$uni_dict{$syl} = chr(hex($base+$i));
				$i++;
			}
			print UNI "$uni_dict{$syl}";
			$word_uni = $word_uni . "$uni_dict{$syl}";
		}
		print UNI " ";
		$word_dict{$word} = $word_uni;
	}
	print UNI "\n";
}
close(UNI);

# Print Syl dict
open(OUT,">italian_dict.uni")or die("Couldn't open italian_dict.uni\n");
binmode(OUT,":utf8");
foreach $key (sort keys %uni_dict){
	print OUT "$key\t$uni_dict{$key}\n";
}
close(OUT);

# Print Word dict
open(OUT,">italian_word_dict.uni")or die("Couldn't open italian_word_dict.uni\n");
binmode(OUT,":utf8");
foreach $key (sort keys %word_dict){
	print OUT "$key\t$word_dict{$key}\n";
}
close(OUT);

# Don't forget to remove line final spaces & the final newline!!!

# CREATE HUNGARIAN UNICODE DICTIONARY & REPLACE SYLLABLES WITH UNICODE
undef(%uni_dict); undef(%word_dict);
%uni_dict; %word_dict;
undef(@corp);
open(CORP,"<hungarian_corpus.txt")or die("Couldn't open hungarian_corpus.txt\n");
binmode(CORP,":utf8");
@corp = <CORP>;
close(CORP);

$base=3001;$i=0;
print "Replacing with Unicode encoding\n";
open(UNI,">hungarian.uni")or die("Couldn't open hungarian.uni\n");
binmode(UNI,":utf8");
foreach $line (@corp){
	chomp($line);
	@words = split(/ /,$line);
	foreach $word (@words){
		@syls = split(/\//,$word);
		$word_uni = "";
		foreach $syl (@syls){
			if(exists($uni_dict{$syl})){
			}else{
				$uni_dict{$syl} = chr(hex($base+$i));
				$i++;
			}
			print UNI "$uni_dict{$syl}";

			$word_uni = $word_uni . "$uni_dict{$syl}";
		}
		print UNI " ";
		$word_dict{$word} = $word_uni;
	}
	print UNI "\n";
}
close(UNI);

# Write Word dict
open(OUT,">hungarian_word_dict.uni")or die("Couldn't open hungarian_word_dict.uni\n");
binmode(OUT,":utf8");
foreach $key (sort keys %word_dict){
	print OUT "$key\t$word_dict{$key}\n";
}
close(OUT);


# Write syllable dict
open(OUT,">hungarian_dict.uni")or die("Couldn't open hungarian_dict.uni\n");
binmode(OUT,":utf8");
foreach $key (sort keys %uni_dict){
	print OUT "$key\t$uni_dict{$key}\n";
}
close(OUT);
