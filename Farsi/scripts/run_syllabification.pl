#! usr/bin/perl
use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib '../../';

use syllabification qw(convert_to_unicode);
# This code will syllabify the Farsi Corpus.
# 
# 1) Create list of Syllables and Unicode equivalents
# 2) Syllabify corpus
#
# Files you'll need:
#  farsi.phosyl
#  run_syllabification.pl (this file)
#
# Made by Lawrence Phillips 2/27/2012
# For questions/comments/feedback reach me at lawphill@gmail.com

# CREATE UNICODE DICTIONARY & REPLACE SYLLABLES WITH UNICODE

open(my $corpus_fh,"<farsi.phosyl")or die("Couldn't open farsi.phosyl\n");
my @corpus = <$corpus_fh>;
close($corpus_fh);


my ($uni_ref, $word_dictref, $syl_dictref) = convert_to_unicode(\@corpus,'Farsi');
