#! usr/bin/perl
use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib './';

use Syllabification qw(maximum_onset_principle);

# Generate Orthographic & Phonetic Corpora
system("python Spanish/scripts/dict_convert.py");

# Generate Syllabified Corpus
my $phon_file = 'Spanish/Spanish-phon.txt';
my $syl_file = 'Spanish/Spanish-syl.txt';

open(my $phon_fh,"<",$phon_file) or die("Couldn't open $phon_file: $!\n");
my @phon_lines = <$phon_fh>; chomp(@phon_lines);
close($phon_fh);

open(my $syl_fh,">",$syl_file) or die("Couldn't open $syl_file: $!\n");

my $vowels = 'aeiou\%\$\#\@\!\&\*\+\-3';
# IDENTIFY VALID ONSETS
my %onsets;
foreach my $line (@phon_lines){
    my @words = split(/\s+/,$line);
    foreach my $word (@words){
       # print "$word\n";
        my $onset = ''; my $found_vowel = 0;
        foreach my $char (split(//,$word)){
            if($found_vowel == 0){
                if($char =~ /[\%\$\#\@\!\&\*\+\-]/){
                    $char = '\\' . $char;
                }
                if($vowels =~ /$char/){
                    $found_vowel = 1;
                }else{
                    $onset .= $char;
                }
            }
        }
        $onset =~ s/\\//g;
       #print "$onset\n"; my $a = <STDIN>;
        if($onset =~ /^\S+$/){
            $onsets{$onset} = 1;
        }
    }
}
# ADD ADDITIONAL ONSETS
$onsets{'|'} = 1;

# PRINT ONSETS
my $onset_file = 'Spanish/dicts/valid_onsets.txt';
open(my $onset_fh,">",$onset_file) or die("Couldn't open $onset_file: $1\n");
foreach (sort keys %onsets){
    print $onset_fh "$_\n";
}
close($onset_fh);

# SYLLABIFY AND PRINT FILE, ALSO PRINT ALL SYLLABIFIED WORDS
my $syl_word_file = 'Spanish/dicts/syllabified_words.txt';
open(my $syl_word_fh,">",$syl_word_file) or die("Couldn't open $syl_word_file: $!\n");
my %syl_words;
for my $i (0..$#phon_lines){
    my @words = split(/\s+/,$phon_lines[$i]);
    my $syllabified_line = '';
    foreach my $word (@words){
        my $syl_word = maximum_onset_principle($word,$vowels,\%onsets);
        $syl_words{$syl_word} = 1;
        $syllabified_line .= "$syl_word ";
    }
    $syllabified_line =~ s/ $//;
    print $syl_fh $syllabified_line;
    if($i < $#phon_lines){ print $syl_fh "\n"; }
}

foreach (sort keys %syl_words){
    print $syl_word_fh "$_\n";
}
close($syl_word_fh);

close($syl_fh);
