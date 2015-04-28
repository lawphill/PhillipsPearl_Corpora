#! usr/bin/perl
use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib './';

use Syllabification;

my $orig_phonetic_corpus = 'German/German.txt';
my $phonetic_corpus = 'German/German-phon.txt';
open(my $phonetic_fh,"<",$orig_phonetic_corpus) or die("Couldn't open $orig_phonetic_corpus: $!\n");
my @phonetic_lines = <$phonetic_fh>; chomp(@phonetic_lines);
close($phonetic_fh);

# Change Phonetic corpus so that it's encoded in more compatible IPA
open($phonetic_fh,">",$phonetic_corpus) or die("Couldn't open $phonetic_corpus for writing: $!\n");
for my $i (0..$#phonetic_lines){

    $phonetic_lines[$i] =~ s/O/q/g; # O -> q
	$phonetic_lines[$i] =~ s/Q/3/g; # Q -> 3
	$phonetic_lines[$i] =~ s/\&/Q/g; # & -> Q
	$phonetic_lines[$i] =~ s/\)/O/g; # ) -> O
	$phonetic_lines[$i] =~ s/9/1/g; # 9 -> 1
	$phonetic_lines[$i] =~ s/7/2/g; # 7 -> 2
	$phonetic_lines[$i] =~ s/6/\@/g; # 6 -> @
	$phonetic_lines[$i] =~ s/C/4/g; # C -> c
	$phonetic_lines[$i] =~ s/c/C/g; # c -> C
	$phonetic_lines[$i] =~ s/4/c/g; 
	$phonetic_lines[$i] =~ s/G/J/g; # G -> J
	$phonetic_lines[$i] =~ s/w/v/g; # w -> v
	$phonetic_lines[$i] =~ s/Z/T/g; # Z -> T

    print $phonetic_fh $phonetic_lines[$i];
    if ($i < $#phonetic_lines){ print $phonetic_fh "\n"; }
}
close($phonetic_fh);

# FIND VALID ONSETS
my $vowels = 'iIyYeEqQaAOoUu123R@LMN';
my %onsets = find_onsets(\@phonetic_lines,$vowels);

my $onset_file = "German/dicts/valid_onsets.txt";
open(my $onset_fh,">",$onset_file)or die("Couldn't open $onset_file: $!\n");
my @onset_array = sort keys %onsets;
print_array(\@onset_array,$onset_file);
close($onset_fh);

# READ CELEX DICTIONARY
my $celex_file = 'German/dicts/celex_dict.txt';
open(my $celex_fh,"<",$celex_file) or die("Couldn't open $celex_file\n");
my @celex_lines = <$celex_fh>; chomp(@celex_lines);
close($celex_fh);

my %syl_dict;
foreach (@celex_lines){
    my @fields = split(/\t/,$_);
    $syl_dict{$fields[0]} = $fields[1];
}

# SYLLABIFY CORPUS
# USE CELEX DICTIONARY IF POSSIBLE, OTHERWISE MAXIMUM-ONSET PRINCIPLE
my @syl_lines;
for my $i (0..$#phonetic_lines){
    $syl_lines[$i] = '';
    my @words = split(/\s+/,$phonetic_lines[$i]);
    for my $j (0..$#words){
        my $syl_word;
        if(exists($syl_dict{$words[$j]})){
            $syl_word = $syl_dict{$words[$j]};
        }else{
            $syl_word = maximum_onset_principle($words[$j],$vowels,\%onsets);
        }
        $syl_lines[$i] .= "$syl_word ";
    }
    $syl_lines[$i] =~ s/\s$//;
}

my $syl_file = 'German/German-syl.txt';
print_array(\@syl_lines,$syl_file);
