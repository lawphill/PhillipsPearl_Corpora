#! usr/bin/perl

# This code will syllabify the Japanese Corpus.
# 
# 1) Create list of Syllables and Unicode equivalents
# 2) Syllabify corpus
#
# Files you'll need:
#  2-20mos.utt.syl
#  run_syllabification.pl (this file)
#
# Made by Lawrence Phillips 2/27/2012
# For questions/comments/feedback reach me at lawphill@gmail.com

# CREATE UNICODE DICTIONARY & REPLACE SYLLABLES WITH UNICODE

%uni_dict;
undef(@corp);
open(CORP,"<2-20mos.utt.syl")or die("Couldn't open Japanese corpus\n");
@corp = <CORP>;
close(CORP);

$base=3001;$i=0;
print "Replacing with Unicode encoding\n";
open(UNI,">japanese.uni")or die("Couldn't open japanese.uni\n");
binmode(UNI,":utf8");
foreach $line (@corp){
	chomp($line);
	if($line !~ /^$/){
	@words = split(/ /,$line);
	foreach $word (@words){
		@syls = split(/\//,$word);
		foreach $syl (@syls){
			if(exists($uni_dict{$syl})){
			}else{
				$uni_dict{$syl} = chr(hex($base+$i));
				$i++;
			}
			print UNI "$uni_dict{$syl}";
		}
		print UNI " ";
	}
	print UNI "\n";
	}
}
close(UNI);
print "$i\n";

open(OUT,">japanese_dict.uni")or die("Couldn't open japanese_dict.uni\n");
binmode(OUT,":utf8");
foreach $key (sort keys %uni_dict){
	print OUT "$key\t$uni_dict{$key}\n";
}
close(OUT);

# Don't forget to remove line final spaces & the final newline!!!
