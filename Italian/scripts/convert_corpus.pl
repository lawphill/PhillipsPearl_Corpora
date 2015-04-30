#! usr/bin/perl
use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib './';

use Syllabification;


my $gervain_file = 'Italian/ItalianAnnotatedSyllables.txt';
my @corpus = read_gervain($gervain_file);

my @phon_corpus = @corpus;
for my $i (0..$#phon_corpus){
    $phon_corpus[$i] =~ s/\///g;
}

my $syl_file = 'Italian/Italian-syl.txt';
my $phon_file = 'Italian/Italian-phon.txt';
print_array(\@corpus,$syl_file);
print_array(\@phon_corpus,$phon_file);
