#! usr/bin/perl
use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib './';

use Syllabification;

my $verbose = 1;

# CREATE PHONETIC/SYLLABIFIED CORPORA

# use Lisa's script for japanese & spanish
# my script for German, Farsi, English

# english
if($verbose==1){ print "Pre-processing ENGLISH...\n"; }
system("perl English/scripts/edit_dict_brent.pl");
system("perl English/scripts/adding_syllabification.pl");
system("perl English/scripts/syllabify_corpus.pl");

# german
if($verbose==1){ print "Pre-processing GERMAN...\n"; }
system("perl German/scripts/syllabify_corpus.pl");

# spanish
if($verbose==1){ print "Pre-processing SPANISH...\n"; }
system("perl Spanish/scripts/create_corpus.pl");

# japanese
if($verbose==1){ print "Pre-processing JAPANESE...\n"; }
system("perl Japanese/scripts/createIPAsylstress.pl -inputfile Japanese/Japanese-ortho.txt -dictfile Japanese/dicts/japanese_dict.txt -sylstressout Japanese/Japanese-sylstress.txt -sylout Japanese/Japanese-syl.txt -ipaout Japanese/Japanese-phon.txt");

# farsi
if($verbose==1){ print "Pre-processing FARSI...\n"; }
system("perl Farsi/scripts/createIPAsyl.pl -inputfile Farsi/Farsi-ortho.txt -outputfile Farsi/Farsi-syl.txt -dictfile Farsi/dicts/farsi_dict.txt -mode syl");
system("perl Farsi/scripts/createIPAsyl.pl -inputfile Farsi/Farsi-ortho.txt -outputfile Farsi/Farsi-phon.txt -dictfile Farsi/dicts/farsi_dict.txt -mode pho");

# italian
if($verbose==1){ print "Pre-processing ITALIAN...\n"; }
system("perl Italian/scripts/convert_corpus.pl");

# hungarian
if($verbose==1){ print "Pre-processing HUNGARIAN...\n"; }
system("perl Hungarian/scripts/convert_corpus.pl");


# CONVERT SYLLABIFIED CORPORA TO UNICODE
my @languages = qw(English German Spanish Italian Farsi Hungarian Japanese);
if($verbose==1){ print "Converting to unicode...\n"; }
foreach (@languages){
	my $corpus_file = "$_/$_-syl.txt";

	open(my $corpus_fh,"<",$corpus_file) or die("Couldn't open $corpus_file: $!\n");
	my @corpus = <$corpus_fh>; chomp(@corpus);
	close($corpus_fh);

	my ($uni_ref, $word_dictref, $syl_dictref) = unicode_conversion(\@corpus,$_);
}

my %vowels = (
    English => 'iIeE@acoUuYOWRx^',
    German => 'iIyYeEqQaAOoUu123R@LMN',
    Spanish => 'aeiou%$#@!&*+-3',
    Italian => 'aeiou',
    Farsi => 'aeiouAEIQU&',
    Hungarian => 'aeioÃ¶uÃŒÃ¡Ã©Ã­Ã³ÃºÅÅ±',
    Japanese => 'aeiouAEIOUWY'
);

# CREATE TRAIN TEST SETS
if($verbose==1){ print "Creating train/test sets...\n"; }

my $splits = 5;
my $amt_train = .9;
foreach (@languages){
	my $unicode_file = "$_/$_-uni.txt";
	my $syl_file = "$_/$_-syl.txt";

	open(my $unicode_fh,"<",$unicode_file) or die("Couldn't open $unicode_file: $!\n");
	binmode($unicode_fh,":utf8");
	my @unicode_lines = <$unicode_fh>; chomp(@unicode_lines);
	close($unicode_fh);

	open(my $syl_fh,"<",$syl_file) or die("Couldn't open $syl_file: $!\n");
	my @syl_lines = <$syl_fh>; chomp(@syl_lines);
	close($syl_fh);

	# PROCESS SYL FILE TO BE LIGNOS READABLE
    my @lignos_lines = convert_to_lignos(\@syl_lines,$vowels{$_});

	# TRAIN/TEST SPLIT
	for my $i (1..$splits){
		my ($uni_train,$uni_test) = train_test_split(\@unicode_lines,$amt_train);
		print_array($uni_train,"$_/train_sets/$_\_unicode_train$i.txt");
		print_array($uni_test,"$_/test_sets/$_\_unicode_test$i.txt");

		my ($syl_train,$syl_test) = train_test_split(\@syl_lines,$amt_train);
		print_array($syl_train,"$_/train_sets/$_\_syllable_train$i.txt");
		print_array($syl_test,"$_/test_sets/$_\_syllable_test$i.txt");

        my ($lignos_train,$lignos_test) = train_test_split(\@lignos_lines,$amt_train);
        print_array($lignos_train,"$_/train_sets/$_\_lignos_train$i.txt");
        print_array($lignos_test,"$_/test_sets/$_\_lignos_test$i.txt");
	}
}
