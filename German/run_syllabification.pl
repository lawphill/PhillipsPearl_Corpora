#! usr/bin/perl

# This code will syllabify the corpus.phone.gold file in the Caroline Corpus.
# 
# 1) Grab all words from the Caroline corpus
# 2) Grab all words from the CELEX database
# 3) Where CELEX = Caroline apply CELEX syllabification
# 4) Otherwise use Maximum Onset Principle
# 5) Write corpus to corpus.syl.gold
#
# Files you'll need:
#  corpus.phone.gold
#  corpus.txt
#  gpw.cd (celex2/german/gpw/gpw.cd) CELEX2 DATABASE
#  run_syllabification.pl (this file)
#
# Made by Lawrence Phillips 2/24/2012
# For questions/comments/feedback reach me at lawphill@gmail.com

# CREATE LIST OF ALL WORDS IN CORPUS
print "Opening corpus\n";
open(CORP,"<corpus.phone.gold")or die("Couldn't open corpus.phone.gold\n");
@corp = <CORP>;
close(CORP);

open(CORP2,"<corpus.txt")or die("couldn't open corpus.txt\n");
@corp_ortho = <CORP2>;
close(CORP2);

$n = @corp; $n2 = @corp_ortho;
if ($n != $n2){
	die("Corpora are not of same size\n");
}

%phon_dict; # holds the orthographic and IPA forms for the Caroline Corpus
print "Generating list of words\n";
$error = 0;
for($i=0;$i<$n;$i++){
	$phon = $corp[$i];
	$ortho = $corp_ortho[$i];
	chomp($phon); chomp($ortho);
	# remove uppercase orthographic letters
	$ortho = lc($ortho);
	@phon_w = split(/ /,$phon);
	@ortho_w = split(/ /,$ortho);
	$m1 = @phon_w; $m2 = @ortho_w;
	if($m1 != $m2){
		print "Lines are not of equal length: $i\n";
	}else{
		for($j=0;$j<$m1;$j++){
			$p = $phon_w[$j]; $o = $ortho_w[$j];
			if(!exists($phon_dict{$o})){
				$phon_dict{$o} = $p;
			}else{
				if($phon_dict{$o} eq $p){
				}else{
					print "Multiple pronunciations of orthographic form\n";
					$error++;
				}
			}
		}
	}
}
print "Errors:\t$error\n";

undef(@corp); undef($error); undef($phon); undef($ortho); undef(@corp_ortho); undef($m1); undef($m2); undef($n);
undef($n2); undef($p); undef($o); undef($i); undef($j); undef(@phon_w); undef(@ortho_w);

# REPLACE Caroline IPA with LAP-Standard
foreach $key (keys %phon_dict){
	$ipa = $phon_dict{$key};
	$ipa =~ s/O/q/g; # O -> q
	$ipa =~ s/Q/3/g; # Q -> 3
	$ipa =~ s/\&/Q/g; # & -> Q
	$ipa =~ s/\)/O/g; # ) -> O
	$ipa =~ s/9/1/g; # 9 -> 1
	$ipa =~ s/7/2/g; # 7 -> 2
	$ipa =~ s/6/\@/g; # 6 -> @
	$ipa =~ s/C/4/g; # C -> c
	$ipa =~ s/c/C/g; # c -> C
	$ipa =~ s/4/c/g; 
	$ipa =~ s/G/J/g; # G -> J
	$ipa =~ s/w/v/g; # w -> v
	$ipa =~ s/Z/T/g; # Z -> T
	$phon_dict{$key} = $ipa;
}

open(WORDS,">caroline_phon_dict.txt") or die("2\n");
foreach $word (sort keys (%phon_dict)){
	print WORDS "$word\t$phon_dict{$word}\n";
}
close(WORDS);


# IDENTIFY WORD ONSETS FOR MAXIMUM ONSET PRINCIPLE
%onsets;
print "Generating list of word onsets\n";
#open(ONSETS, ">ValidOnsets.txt") or die("Couldn't open ValidOnsets.txt\n");
foreach $ortho (keys (%phon_dict)){
	$word = $phon_dict{$ortho};
	undef(@on);
	@on;
	@chars = split(//,$word);
	$end = 0;
	while($end == 0){
		$char = shift(@chars);
		if($char !~ /[iIyYeEqQaAOoUu123R\@LMN]/){ # if it isn't a vowel
			push(@on,$char);
		}else{
			$end = 1;
			#print "Out of loop\n";
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
undef($ortho); undef(@on); undef(@chars); undef($word); undef($end); undef($char); undef($n); undef($onset);
undef($key);

# GRAB SYLLABIFICATIONS FROM CELEX2
print "Opening CELEX\n";
open(CELEX,"<celex2/german/gpw/gpw.cd") or die("couldn't open celex\n");
@celex = <CELEX>;
close(CELEX);

%cel;
print "Grabbing syllabifications from CELEX\n";
foreach $line (@celex){
	@items = split(/\\/,$line);
	$ortho = lc($items[1]);
	$syl = $items[5];
	$syl =~ s/\]\[/\//g; # replace ][ with a /
	$syl =~ s/^\[//; # remove initial [ and final ]
	$syl =~ s/\]$//;
	# remove [\w+]
	$syl =~ s/\[(\w+)\]/\/$1/g;
	# remove ] [ pattern
	$syl =~ s/\] \[/ /g;
	$cel{$ortho} = $syl;
}
undef(@celex); undef(@items); undef($syl); undef($ortho);

# REPLACE CELEX IPA with LAP-Standard
foreach $key (keys %cel){
	$ipa = $cel{$key};
	$ipa =~ s/\~//g; # ~ -> null
	$ipa =~ s/i\:/i/g; # i: -> i
	$ipa =~ s/y\:/y/g; # y: -> y
	$ipa =~ s/e\:/e/g; # e: -> e
	$ipa =~ s/E\:/E/g; # E: -> E
	$ipa =~ s/\&:/q/g; # &: -> q
	$ipa =~ s/a\:/5/g; # a: -> a
	$ipa =~ s/a/A/g; # a -> A
	$ipa =~ s/5/a/g;
	$ipa =~ s/o\:/o/g; # o: -> o
	$ipa =~ s/u\:/u/g; # u: -> u
	$ipa =~ s/ai/1/g; # ai -> 1
	$ipa =~ s/Oy/2/g; # Oy -> 2
	$ipa =~ s/au/3/g; # au -> 3
	$ipa =~ s/\@r/R/g; # @r -> R
	$ipa =~ s/N/ng/g; # N -> ng
	$ipa =~ s/tS/C/g; # tS -> C
	$ipa =~ s/dZ/J/g; # dZ -> J
	$ipa =~ s/pf/P/g; # pf -> P
	$ipa =~ s/ts/T/g; # ts -> T
	$ipa =~ s/x/c/g; # x -> c
	$ipa =~ s/\@n/N/g;
	$ipa =~ s/\@m/M/g;
	$ipa =~ s/\@l/L/g;
	$ipa =~ s/Au/3/g;
	$ipa =~ s/Ai/1/g;
	$ipa =~ s/\://g;
	$ipa =~ s/[aAoOuU3]c/x/g; # c -> x when after back vowel
	$cel{$key} = $ipa;
}

open(CELEX,">celex_dict.txt")or die("4\n");
foreach $key (sort (keys(%cel))) {
   print CELEX "$key\t$cel{$key}\n";
}
close(CELEX);

# SYLLABIFY DICTIONARY USING ONSETS
%syl_dict;
print "Syllabifying dictionary with onsets\n";

$celex_count=0; $carol_count = 0;
foreach $ortho (keys %phon_dict){
	# Test to see if it already exists in CELEX
	$ce = $cel{$ortho};
	$ce =~ s/\///g;
	if (length($ce) == length($phon_dict{$ortho})){
		$ce_cv = $ce; $ca_cv = $phon_dict{$ortho};
		
		$ce_cv =~ s/[aAeEiIyYqQoOuU123R\@LMN]/V/g;
		$ce_cv =~ s/[^V]/C/g;
	
		$ca_cv =~ s/[aAeEiIyYqQoOuU123R\@LMN]/V/g;
		$ca_cv =~ s/[^V]/C/g;
		if($ce_cv eq $ca_cv){ # If same CV structure, apply Syl Structure from CELEX onto Caroline IPA
			@segments;
			@ipa_celex = split(//,$cel{$ortho});
			@ipa_carol = split(//,$phon_dict{$ortho});
			while(@ipa_celex != 0){
				$curr_celex = shift(@ipa_celex);
				if($curr_celex =~ /\//){
					push(@segments,$curr_celex); # add a syllable boundary
				}else{
					$curr_ipa = shift(@ipa_carol);
					push(@segments,$curr_ipa);  # add the next IPA from carol
				}
			}
			$syl_dict{$ortho} = join("",@segments);
			$celex_count++;
		}else{
			$mop = 1;
		}
	}else{
		$mop = 1;
	}
	if($mop == 1){
	$carol_count++;
	$word = $phon_dict{$ortho};
		$currsyllable = "";
		$entry = "";
		# work backwards with each word..
		@wordarray = split(//, $word);
		while(@wordarray > 0){
			$currchar = pop(@wordarray); # get current char, given count
			$currsyllable = $currchar . $currsyllable; # add current char to current syllable 
			
			if($currchar =~ /[iIyYeEqQaAOoUu123R\@LMN]/){				
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
		# print syllables as entry in collection of syllabified words
		$entry =~ s/\/$//g; # remove last '/'
		$entry =~ s/^\///g; # remove first '/"
		$syl_dict{$ortho}=$entry;
	}
}
print "From CELEX:\t$celex_count\nFrom Caroline:\t$carol_count\n";















# Write to file
open(DICT,">caroline_syl_dict.txt")or die("couldn't write caroline dict\n");
foreach $key (sort (keys(%syl_dict))){
	print DICT "$key\t$syl_dict{$key}\n";
}
close(DICT);

undef(@chars); undef(@new_chars); undef($word); undef($end); undef($inonset); undef(@onset); undef($char);
undef($tmp); undef($syl_word);

# SYLLABIFY CORPUS
open(OUT,">corpus.syl.gold")or die("couldn't write corpus.syl.gold\n");
#open(CORP,"<corpus.phone.gold")or die("Couldn't open corpus.phone.gold\n");
open(CORP,"<corpus.txt")or die("couldn't open corpus.txt\n");
@corp = <CORP>;
close(CORP);

print "Syllabifying corpus\n";
open(ERROR,">errors.txt")or die("couldn't open errors\n");
foreach $line (@corp){
	chomp($line);
	@words = split(/ /,$line);
	foreach $word (@words){
		$word = lc($word);
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

%uni_dict;
open(CORP,"<corpus.syl.gold")or die("Couldn't open Corpus.syl.gold\n");
@corp = <CORP>;
close(CORP);

$base=3001;$i=0;
print "Replacing with Unicode encoding\n";
open(UNI,">corpus.uni.gold")or die("Couldn't open corpus.uni.gold\n");
binmode(UNI,":utf8");
foreach $line (@corp){
	chomp($line);
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
close(UNI);

open(OUT,">caroline_uni_dict.txt")or die("Couldn't open caroline_uni_dict.txt\n");
binmode(OUT,":utf8");
foreach $key (sort keys %uni_dict){
	print OUT "$key\t$uni_dict{$key}\n";
}
close(OUT);

# Don't forget to remove line final spaces & the final newline!!!