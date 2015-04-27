#! usr/bin/perl

# MODIFY THE ITALIAN CORPUS

open(ITAL,"<ItalianAnnotatedSyllables.txt")or die("Couldn't open Italian Corpus\n");
@ital = <ITAL>;
close(ITAL);

$n = @ital; $n = $n - 1;
$line = $ital[$n];

@data = split(/ /,$line);

open(OUT,">italian_corpus.txt")or die("Couldn't open italian_corpus.txt\n");
$curr_word = "";
while(@data > 0){
	$syl = shift(@data);
	if($syl =~ /WB/){
		print OUT "$curr_word ";
	}elsif($syl =~ /WI/){
		print OUT "\/";
	}elsif($syl =~ /UB/){
		print OUT "\n";
	}else{
		print OUT "$syl";
	}
}
close(OUT);

# MODIFY THE HUNGARIAN CORPUS

open(HUNG,"<HungarianAnnotatedSyllables.txt") or die("Couldn't open Hungarian Corpus\n");
@hung = <HUNG>;
close(HUNG);

$n = @hung; $n = $n - 1;
$line = $hung[$n];

@data = split(/ /,$line);

open(OUT,">hungarian_corpus.txt")or die("Couldn't open hungarian_corpus.txt\n");
$curr_word = "";
while(@data > 0){
	$syl = shift(@data);
	if($syl =~ /WB/){
		print OUT "$curr_word ";
	}elsif($syl =~ /WI/){
		print OUT "\/";
	}elsif($syl =~ /MB/){
		print OUT "\/";
	}elsif($syl =~ /UB/){
		print OUT "\n";
	}else{
		print OUT "$syl";
	}
}
close(OUT);