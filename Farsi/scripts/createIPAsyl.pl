#!/usr/bin/perl

# updated by Lisa Pearl, 4/6/11
# code designed to take in a file containing only words (from child-directed speech)
# and use a dictionary file to convert the words in each line into either
# their respective IPA encoding 
# or their respective syllabified IPA encoding
# 
# ex: input
# æz in mitærsi 
#
# ex: farsi_dict.txt for the dictionary file
# ...
# abaro           abaro              a/ba/ro
# ...
# ex: output for IPA (default)
# &z in mit&rsi
#
# ex: output for IPA syl
# &z in mi/t&r/si
#
# calling createIPAsyl.pl example with phoneme output
# createIPAsyl.pl -inputfile farsi_utterances_words.txt -outputfile farsi.pho -dictfile farsi_dict.txt -mode pho

# calling createIPAsyl.pl example with syllabified phoneme output
# createIPAsyl.pl -inputfile farsi_utterances_words.txt -outputfile farsi.phosyl -dictfile farsi_dict.txt
# OR 
# createIPAsyl.pl -inputfile farsi_utterances_words.txt -outputfile farsi.phosyl -dictfile farsi_dict.txt -mode syl


# in case of unicode character encodings
use utf8;

# default options
$mode = "syl";

# begin getting command line options
process_options();
if($opt_mode){
  $mode = $opt_mode;
}

print("Output mode: $mode\n");

# open dictfile and dump all the translations into a hash

%dict = ();

open(DICT, "$opt_dictfile") or die("Couldn't open $opt_dictfile\n");
binmode(DICT, ":utf8");
binmode(STDOUT, ":utf8");
while(defined($dictfileline = <DICT>)){
  
  # extract word and IPA entry
  if($dictfileline =~ /^(\S+)\s+(.+)\n$/ and $dictfileline !~ /^\S+\s+\n$/){
    #check entry and ipa
    $word = $1;
    $ipa_form = $2;
    #print("debug, before syl/pho check: word = $word, ipa_form = $ipa_form\n");
    # now extract syllabified form if there - else leave as regular phoneme only form
#    if($ipa_form =~ /^(.+)(\s\s+|\t)(.+)$/){
     if($ipa_form =~ /(\S+)(\s+)(\S+)/){
      #print("debug: have syllabified form: $2\n");
      $ipa_form = $3;
    }

    $dict{$word} = $ipa_form;
  }else{
	print STDOUT "$dictfileline\n";
  }
  #print("debug: word = $word, ipa_form = $ipa_form\n");

}
close(DICT);

# debug print dictionary hash
#binmode(STDOUT, ":utf8");
#foreach $w (sort (keys (%dict))){
#  print("debug: $w\t$dict{$w}\n");
#}


# now go through each line of inputfile and convert the words there using the %dict hash
open(IN, "$opt_inputfile");
open(OUT, ">$opt_outputfile");
binmode(IN, ":utf8");
binmode(OUT, ":utf8");

while(defined($inputfileline = <IN>)){
  # line should be words divided by one space each
  # get rid of newline at the end

  chomp($inputfileline);

  @words_in_line = split(/ /,$inputfileline);

  # go through and replace
  $index = 0;
  while(defined($words_in_line[$index])){

    $word_to_find = $words_in_line[$index];
    # switch uppercase letters to lowercase letters
    $word_to_find =~ tr/[A-Z]/[a-z]/;

    # check to make sure word has some characters in it
    if($word_to_find =~ /\w|\#|\&|\d/){
      # check to see if in dict hash

      if(exists ($dict{$word_to_find})){
	# check output mode
	$converted_word = $dict{$word_to_find};

	if($mode eq "pho"){
	  # get rid of syllable separator: /
	  $converted_word =~ s/\///g;
	}

	print(OUT "$converted_word ");
      }else{
	print("DEBUG: *** $word_to_find not found in $opt_dictfile\n");
      }
  }
 
    $index++;
  }
   print(OUT "\n");

}

close(OUT);
close(IN);


sub process_options{
  
  use Getopt::Long;
  &GetOptions("inputfile=s", "outputfile=s", "dictfile=s", # required filename options
	                "mode:s"); # (default = syl, option = pho) required filename options
}


