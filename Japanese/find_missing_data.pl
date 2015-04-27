#! usr/bin/perl

# Identify words in japanese_dict.txt that have no syllabification/stress information

open(IN,"<japanese_dict.txt")or die("couldn't open japanese_dict.txt\n");
@in = <IN>;
close(IN);

open(OUT,">missing_words.txt")or die("couldn't open missing_words.txt\n");
$v = 'aeiouAEIOUWY';
@vowels = split(//,$v);

foreach $line (@in){
	$bad_line = 0;
	chomp($line);
	@data = split(/\,/,$line);
	$ortho = shift(@data);
	$syl = shift(@data);

	@syls = split(/[\/ ]/,$syl);
	foreach $s (@syls){
		$n_vowels=0; $vowel_found=''; $prev_vowel='';
		@chars = split(//,$s);
		foreach $c (@chars){
			$vowel_found='';
			foreach $v (@vowels){
				if($c eq $v){
					$n_vowels++;
					$vowel_found=$v;
					print "found a vowel:\t$v\n";
				}
			}
			if($vowel_found eq ''){
				$prev_vowel='';
			}else{
				print "one step\n";
				if($prev_vowel eq ''){
				}else{
					print "made it closer\n";
					$tmp = $prev_vowel . $vowel_found;
					if($tmp =~ /[aA]i/){
						print "made it here\n";
						$n_vowels--;
					}
				}
				$prev_vowel=$vowel_found;
			}
		}
		if($n_vowels>1){
			$bad_line = 1; 
		}
	}
	if($bad_line == 1){
		print OUT "$ortho\,$syl\n";
	}
}
close(OUT);

open(OUT,">no_entries.txt")or die("couldn't open no_entries\n");
foreach $line (@in){
	chomp($line);
	@data = split(/\,/,$line);
	$ortho = shift(@data);
	$syl = shift(@data);
	if($syl =~ /^\s*$/){
		print OUT "$line\n";
	}
}
close(OUT);
