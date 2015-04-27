#! usr/bin/perl

# Some words in the original dict file were missing syllabified entries
# This code should be used only once to insert the newly syllabified entries into the
# original dict file

open(NEW,"<redone_words.txt")or die("couldn't open redone_words\n");
@lines = <NEW>;
close(NEW);

# READ IN NEW ENTRIES
%new;
foreach $line (@lines){
	chomp($line);
	@data = split(/\,/,$line);
	$ortho = shift(@data);
	$syllabified = shift(@data);
	$syllabified =~ s/^\s+//; # remove initial spaces
	$syllabified =~ s/\s+$//;
	$new{$ortho} = $syllabified;
}

# READ IN OLD ENTRIES
%dict;
open(OLD,"<japanese_dict.txt")or die("couldn't open japanese_dict.txt\n");
@lines = <OLD>;
close(OLD);

foreach $line (@lines){
	chomp($line);
	@data = split(/\,/,$line);
	$ortho = shift(@data);
	$syllabified = shift(@data);
	$syllabified =~ s/^\s+//;
	$syllabified =~ s/\s+$//;
	$dict{$ortho} = $syllabified;
}

# ADD IN NEW ENTRIES

foreach $ortho (keys %new){
	$dict{$ortho} = $new{$ortho};
}

# PRINT OUT NEW DICT
open(OUT,">japanese_dict.txt") or die("couldn't open japanese_dict.txt for writing\n");

@keys = sort (keys %dict);
$last_key = pop(@keys);

foreach $ortho (sort (keys %dict)){
	$line = $ortho . ',' . $dict{$ortho};
	print OUT "$line";
	if(!($ortho eq $last_key)){
		print OUT "\n";	
	}
}
close(OUT);
