#! usr/bin/perl
use strict;
use warnings;


# Generate phonological dictionary from dict-Brent
# dict-Brent-klatt is encoded in Klattese (http://www.people.ku.edu/~mvitevit/Klatt_IPA.pdf)

open(my $dict_fh, "<English/dicts/dict-Brent.txt")or die("Couldn't open dict-Brent.txt for reading: $!\n");
my @dict_lines = <$dict_fh>; chomp(@dict_lines);
close($dict_fh);

open(my $out_fh, ">English/dicts/dict-Brent-Klatt.txt") or die("Couldn't open dict-Brent-Klatt.txt for writing: $!\n");

for my $i (0..$#dict_lines){
	my $line = $dict_lines[$i];

	my @words = split(/\s+/,$line);
	my $first_word = shift(@words);
	my @rest = @words;

	# Phonological form is encoded as '.IPA' where there may be intervening items
	# marked prepended with '-'
	# Add only IPA if prepended with a period
	my $brent_word = '';
	foreach my $item (@rest){
		if ($item =~ /\./){
			$item  =~ s/\.//g;
			$brent_word .= $item;
		}
	}
	
	# now start replacing characters with their Klattese equivalents
	# assorted mistakes I stumbled on
	$brent_word =~ s/m6sOG/m6sOZ/g;
	$brent_word =~ s/pZnc/p\^nc/g;
	$brent_word =~ s/\-w//g;
	$brent_word =~ s/\]\=//g;
	# consonants
	$brent_word =~ s/L/xl/g;
	$brent_word =~ s/G/J/g;
	$brent_word =~ s/M/xm/g;
	$brent_word =~ s/\~/xn/g;
	$brent_word =~ s/N/G/g;
	$brent_word =~ s/c/C/g;
	#vowels
	$brent_word =~ s/\&/\@/g;
	$brent_word =~ s/O/c/g;
	$brent_word =~ s/0/o/g;
	$brent_word =~ s/9/Y/g;
	$brent_word =~ s/7/O/g;
	$brent_word =~ s/Q/W/g;
	$brent_word =~ s/6/x/g;
	$brent_word =~ s/3/R/g;
	$brent_word =~ s/A/^/g;
	$brent_word =~ s/\(/Ir/g;
	$brent_word =~ s/\*/Er/g;
	$brent_word =~ s/\)/Ur/g;
	$brent_word =~ s/\#/ar/g;
	$brent_word =~ s/\%/cr/g;
	#missing entries
	if ($first_word eq 'mmm'){
		print $out_fh "mm\txm\n";
		print $out_fh "mhm\txmhxm\n";
		print $out_fh "ohgoodness\togUdnIs\n";
		print $out_fh "mygoodness\tmYgUdnIs\n";
		print $out_fh "ohmygoodness\tomYgUdnIs\n";
		print $out_fh "guzenheit\@snle\tgxz^ndhYt\n";
		print $out_fh "mms\txmz\n";
	}

	print $out_fh "$first_word\t$brent_word";
	if($i < $#dict_lines){ print $out_fh "\n"; }
}

close($out_fh);
