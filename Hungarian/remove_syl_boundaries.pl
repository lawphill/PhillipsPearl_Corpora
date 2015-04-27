#! usr/bin/perl

open(ITA,"<italian_corpus.txt")or die("1\n");
open(HUN,"<hungarian_corpus.txt")or die("2\n");
@ita = <ITA>;
@hun = <HUN>;
close(ITA);
close(HUN);

open(OUT_ITA,">italian.pho")or die("3\n");
open(OUT_HUN,">hungarian.pho")or die("4\n");

foreach $line (@ita){
	$new_line = $line;
	$new_line =~ s/\///g;
	print OUT_ITA "$new_line";
}

foreach $line (@hun){
	$new_line = $line;
	$new_line =~ s/\///g;
	print OUT_HUN "$new_line";
}

close(OUT_ITA);
close(OUT_HUN);
