#! usr/bin/perl

use utf8;

# This code will syllabify the jacksonthal20mos.txt file in the Jacksonthal Corpus.
# 
# 1) Grab all words from the Jacksonthal corpus
# 4) Syllabify using Maximum Onset Principle
# 5) Write corpus to jacksonthal_uni.txt
#
# Files you'll need:
#  jacksonthal20mos.txt
#  dict_converted.txt
#  run_syllabification.pl (this file)
#
# Made by Lawrence Phillips 2/27/2012
# For questions/comments/feedback reach me at lawphill@gmail.com

# FIRST CONVERT ORTHOGRAPHY TO IPA

#open(DICT,"<PythonFiles/dict.txt") or die("Couldn't open PythonFiles/dict.txt\n");
#binmode(DICT,":utf8");
#@dict_lines = <DICT>; chomp(@dict_lines);
#close(DICT);

#%orth_to_ipa; %orth_to_syl; %ipa_to_syl;
#foreach $line (@dict_lines){
#	$line =~ s/\t+/\t/g; # Remove multiple tabs
#	@parsed = split(/\t/,$line);
#	$orth_to_ipa{$parsed[0]} = $parsed[1];
#	$orth_to_syl{$parsed[0]} = $parsed[2];
#	$ipa_to_syl{$parsed[1]} = $parsed[2];
#}

#open(ORTH,"<jacksonthal20mos.txt") or die("Couldn't open jacksonthal20mos.txt\n");
#binmode(ORTH,":utf8");
#@orth_lines = <ORTH>; chomp(@orth_lines);
#close(ORTH);

#open(IPA,">JacksonThal_full.txt")or die("Couldn't open JacksonThal_full.txt\n");

#for($i=0;$i<@orth_lines;$i++){
#	$line = $orth_lines[$i];
#	$line =~ s/ ^//g; # Remove line-final spaces
#	@words = split(/ /,$line);
#	undef(@ipa_words); @ipa_words;
#	foreach $word (@words){
#		push(@ipa_words,$orth_to_ipa{$word});
#	}
#	$ipa_line = join(" ",@ipa_words);
#	print IPA "$ipa_line";
#	if($i+1 != @orth_lines){ print IPA "\n"; } # Formatting
#}

#close(IPA);

# CREATE LIST OF ALL WORDS IN CORPUS
print "Opening corpus\n";
open(CORP,"<JacksonThal_full.txt")or die("Couldn't open JacksonThal_full.txt\n");
@corp = <CORP>; chomp (@corp);
close(CORP);

%phon_dict; # temporary dict for jacksonthal words
print "Generating list of words\n";
@jacksonthal_words;
foreach $line (@corp){
	@words = split(/ /,$line);
	foreach $word (@words){
		if(!exists($phon_dict{$word})){
			push(@jacksonthal_words,$word);
		}
	}
}


open(OUT,">jacksonthal_words.txt")or die("couldn't open jacksonthal_words.txt\n");
foreach $word (@jacksonthal_words){
	print OUT "$word\n";
}
close(OUT);


# IDENTIFY WORD ONSETS FOR MAXIMUM ONSET PRINCIPLE
%onsets;
print "Generating list of word onsets\n";
open(ONSETS, ">ValidOnsets.txt") or die("Couldn't open ValidOnsets.txt\n");
foreach $word (@jacksonthal_words){
	undef(@on);	@on;
	@chars = split(//,$word);
	$end = 0; $count=0;
	while($end == 0){
		$count++;
		if($count>100){ $end = 1; }
		$char = shift(@chars);
		if($char !~ /[aioeu\%\#\@\$\&\!\*\+\-3\|\.]/){ # if it isn't a vowel
			push(@on,$char);
		}else{
			$end = 1;
		}
	}
	$n = @on; $onset = join('',@on);
	if($n > 0 and !exists($onsets{$onset})){
		$onsets{$onset} = 1;
	}
}
# print sorted onsets to ValidOnsets.txt
foreach $key (sort (keys(%onsets))) {
   print ONSETS "$key\n";
}
close(ONSETS);
undef(@on); undef(@chars); undef($word); undef($end); undef($char); undef($n); undef($onset);
undef($key);

# SYLLABIFY DICTIONARY USING ONSETS
%syl_dict;
print "Syllabifying dictionary with onsets\n";

foreach $word (@jacksonthal_words){
	$currsyllable = "";
	$entry = "";
	# work backwards with each word..
	@wordarray = split(//, $word);
	while(@wordarray > 0){
		$currchar = pop(@wordarray); # get current char, given count
		$currsyllable = $currchar . $currsyllable; # add current char to current syllable 
		
		if($currchar =~ /[aioeu\%\#\@\$\&\!\*\+\-3\|]/){				
			# find and add consonants for valid onset
			$onset = "";
			while(@wordarray > 0 && exists($onsets{$wordarray[@wordarray-1] . $onset})){
				$currchar = pop(@wordarray);
				$onset = $currchar . $onset;
			}
			$currsyllable = $onset . $currsyllable;
			# add syllable to word entry
			$entry = "\/" . $currsyllable . $entry;
#print "added syllable: $currsyllable\n";
			$currsyllable = "";
		}
	}
	if($entry eq ""){
		$entry = $currsyllable;
	}
	# print syllables as entry in collection of syllabified words
	$entry =~ s/\/$//g; # remove last '/'
	$entry =~ s/^\///g; # remove first '/"
	$syl_dict{$word}=$entry;
}

# Write to file
open(DICT,">jacksonthal_syl_dict.txt")or die("couldn't write jacksonthal_syl_dict\n");
foreach $key (sort (keys(%syl_dict))){
	print DICT "$key\t$syl_dict{$key}\n";
}
close(DICT);

undef(@chars); undef(@new_chars); undef($word); undef($end); undef($inonset); undef(@onset); undef($char);
undef($tmp); undef($syl_word);

# SYLLABIFY CORPUS
open(OUT,">jacksonthal_full_syl.txt")or die("couldn't write jacksonthal_full_syl.txt\n");

print "Syllabifying corpus\n";
open(ERROR,">errors.txt")or die("couldn't open errors\n");
foreach $line (@corp){
	chomp($line);
	@words = split(/ /,$line);
	foreach $word (@words){
		if(exists($syl_dict{$word})){
			$new_word = $syl_dict{$word};
		}else{ #Couldn't find word in dictionary
			print "Couldn't find word in dictionary\n";
			print ERROR "$word\n";
		}
		print OUT "$new_word ";
	}
	print OUT "\n";
}
close(OUT);
close(ERROR);

# CREATE UNICODE DICTIONARY & REPLACE SYLLABLES WITH UNICODE

%uni_dict; %word_dict;
undef(@corp);
open(CORP,"<jacksonthal_full_syl.txt")or die("Couldn't open jacksonthal_full_syl.txt\n");
@corp = <CORP>;
close(CORP);

$base=3001;$i=0;
print "Replacing with Unicode encoding\n";
open(UNI,">JacksonThal_full.uni")or die("Couldn't open JacksonThal_full.uni\n");
binmode(UNI,":utf8");
foreach $line (@corp){
	chomp($line);
	@words = split(/ /,$line);
	foreach $word (@words){
		@syls = split(/\//,$word);
		undef(@uni_array); @uni_array;
		foreach $syl (@syls){
			if(exists($uni_dict{$syl})){
			}else{
				$uni_dict{$syl} = chr(hex($base+$i));
				$i++;
			}
			print UNI "$uni_dict{$syl}";
			push(@uni_array,$uni_dict{$syl});
		}
		$tmp_word = $word; $tmp_word =~ s/\///g;
		if(!exists($word_dict{$tmp_word})){ $word_dict{$tmp_word} = join("",@uni_array); }
		print UNI " ";
	}
	print UNI "\n";
}
close(UNI);

print "$i\n";

# Print Syllable Dict
open(OUT,">jacksonthal_uni_dict.txt")or die("Couldn't open jacksonthal_uni_dict.txt\n");
binmode(OUT,":utf8");
foreach $key (sort keys %uni_dict){
	print OUT "$key\t$uni_dict{$key}\n";
}
close(OUT);

# Print Word Dict
open(OUT,">jacksonthal_word_dict.uni")or die("Couldn't open jacksonthal_word_dict.uni\n");
binmode(OUT,":utf8");
foreach $key (sort keys %word_dict){
	print OUT "$key\t$word_dict{$key}\n";
}
close(OUT);

# Don't forget to remove line final spaces & the final newline!!!
