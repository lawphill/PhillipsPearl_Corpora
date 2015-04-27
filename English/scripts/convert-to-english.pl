#! usr/bin/perl

# converts unicode file back to english.

# Read unicode/syllable pairs from unicode-dict.txt
open(my $dict_fh, "<dicts/unicode-dict.txt") or die "Couldn't open unicode-dict.txt for reading: $!\n";
binmode($dict_fh, ":utf8");
my @dict_lines = <$dict_fh>; chomp(@dict_lines);
close($dict_fh);

my %dict;
foreach my $line (@dict_lines){
	if($line =~ /(.+)\t(.+)$/){
		$dict{$2} = $1;
	}
}

# Read in unicode file, translate back into plain English and print to engbrent-text-out.txt
open(my $uni_fh, "<../English-uni.txt") or die "Couldn't open English-uni.txt for reading: $!\n";
binmode($uni_fh, ":utf8");
my @unicode_corpus = <$uni_fh>; chomp(@unicode_corpus);
close($uni_fh);


open(my $klatt_fh, ">../English-syl.txt") or die "Couldn't open English-syl.txt: $!\n";
binmode($klatt_fh, ":utf8");

for my $i (0..$#unicode_corpus){
	my $fileline = $unicode_corpus[$i];

	my @line_chars = split(/ /, $fileline);
	foreach $line_char (@line_chars){
		my @word_chars = split(//, $line_char);
		my $utt_to_print;
		foreach my $word_char (@word_chars){
			if(exists($dict{$word_char})){
				$utt_to_print .= '/' . $dict{$word_char};
			}
		}
		$utt_to_print =~ s/^\///;
		print $klatt_fh "$utt_to_print ";
	}
	if($i < $#unicode_corpus){ print $klatt_fh "\n"; }
}

close($klatt_fh);
