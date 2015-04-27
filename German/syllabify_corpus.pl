#! usr/bin/perl

#Syllabify the Caroline corpus using Maximum Onset Principle

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

%phon_dict;
print "Generating list of words\n";
$error = 0;
for($i=0;$i<$n;$i++){
	$phon = $corp[$i];
	$ortho = $corp_ortho[$i];
	chomp($phon); chomp($ortho);
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

# IDENTIFY WORD ONSETS
%onsets;
print "Generating list of word onsets\n";
open(ONSETS, ">ValidOnsets.txt") or die("Couldn't open ValidOnsets.txt\n");
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
	$ortho = $items[1];
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
foreach $ortho (keys %phon_dict){
	if(exists($cel{$ortho})){
		$syl_word = $cel{$ortho};
	}else{
		$word = $phon_dict{$ortho};
		@chars = split(//,$word);
		@new_chars;
		$end = 0;
		$inonset=0; @onset;
		while($end==0){
			$n = @chars;
			if($n == 0){ $end = 1; }
			$char = pop(@chars);
			if($char =~ /[iIyYeEqQaAOoUu123R\@LMN]/){ # if a vowel
				$inonset = 1;
			}elsif($inonset == 1){
				$tmp = join(//,@onset) . $char;
				if(exists($onsets{$tmp})){
					push(@onset,$char);	
				}else{
					$inonset == 0;
					unshift(@new_chars,"/");
				}
			}
			unshift(@new_chars,$char);
		}
	$syl_word = join(@new_chars);
	}
	$syl_dict{$ortho}=$syl_word;
}
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

# Don't forget to remove line final spaces & the final newline!!!
