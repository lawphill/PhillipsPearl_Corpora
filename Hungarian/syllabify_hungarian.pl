#! usr/bin/perl

#use utf8;

# Syllabify hungarian_morph_ipa and hungarian_funcwords_ipa by using:
#	Corpus judgments where they exist
#	MOP where they do not
# Then convert into Unicode

open(CORP,"<hungarian_corpus.txt")or die("couldn't open corpus for reading\n");
@corp = <CORP>; chomp(@corp);
close(CORP);

# Create dictionary of words from original corpus
%dict;
foreach $line (@corp){
	@words = split(/\s/,$line);
	foreach $word (@words){
		$new_word = $word; $new_word =~ s/\///g;
		$dict{$new_word} = $word;
	}
}
undef(@corp);

# Come up with list of valid onsets
%onsets; @vowels = qw(a e i o ö u ü á é í ó ú ő ű); $combined = join("|",@vowels);
foreach $word (keys %dict){

	if($word =~ /^$combined/){
	}elsif($word =~ /$combined/){
		@chars = split(//,$word);
		$on = ""; $i = 0;
		$curr = $chars[$i];
		while($curr !~ /$combined/){
			$on = $on . $curr; $i++; $curr = $chars[$i];
		}
		$onsets{$on} = 1;
	}
}


open(FUNC,"<hungarian_funcwords_ipa.txt")or die("couldn't open funcwords_ipa.txt to read\n");
@func = <FUNC>; chomp(@func);
close(FUNC);

open(MORPH,"<hungarian_morph_ipa.txt")or die("Couldn't open morph_ipa.txt to read\n");
@morph = <MORPH>; chomp(@morph);
close(MORPH);


open(OUT_FUNC,">hungarian_funcwords_syl.txt") or die("couldn't open funcwords_syl\n");
open(OUT_MORPH,">hungarian_morph_syl.txt") or die("couldn't open morph_syl\n");
# Begin syllabification
for($i=0;$i<@func;$i++){
	$new_line = &syllabify($func[$i]);
#	if($new_line !~ /^\s*$/){
		print OUT_FUNC "$new_line";
		if($i+1!=@func){ print OUT_FUNC "\n"; }
#	}
}
undef(@func);
for($i=0;$i<@morph;$i++){
	$new_line = &syllabify($morph[$i]);
#	if($new_line !~ /^\s*$/){
		print OUT_MORPH "$new_line";
		if($i+1!=@morph){ print OUT_MORPH "\n"; }
#	}
}
undef(@morph);

close(OUT_FUNC);
close(OUT_MORPH);

sub syllabify{
	$word = $_[0];
	if(exists($dict{$word})){
		$dict{$word}; # Return syl from corpus
		print "DEBUG: FROM CORPUS: $word\n";
	}else{
		@chars = split(//,$word); $curr_onset = ""; $curr_syl = ""; $mop_word = "";
		for($j=@chars-1;$j>=0;$j--){
			# Check for vowel
			if($curr_syl =~ /$combined/){
				$test = $chars[$j] . $curr_onset;
				if(exists($onsets{$test})){
					$curr_onset = $test; # Sound passes, add it on
					$curr_syl = $chars[$j] . $curr_syl;
				}else{ # Did not pass, reset for next syl
					$mop_word = "\/" . $curr_syl . $mop_word;
					$curr_onset = ""; $curr_syl = $chars[$j];
				}
			}else{
				$curr_syl = $chars[$j] . $curr_syl; #Add next sound to curr syl
			}
				if($j==0){ $mop_word = $curr_syl . $mop_word; }				
		}
		$mop_word =~ s/^\///;
		$mop_word;
	}
}
