#!/usr/bin/perl

# created by Lisa Pearl, 12/4/08
# updated by Lisa Pearl, 3/20/12
# code designed to take in a file containing only words (from child-directed speech)
# and use a dictionary file to convert the words in each line into their respective
# IPA encoding, syllabified IPA coding, and syllabified + stress IPA coding
#
# ex: input
# hear the kitty Morgie
#
# ex: dict.txt for the dictionary file with syllabification & stress + IPA
# ...
#unchitte, un1 cit1/te1
# ...
# ex: output
# h) D6 kIti m&gi
#
#
# calling createIPAsylstress.pl example
# createIPAsylstress.pl -inputfile 2-20mos.utt -dictfile japanese_dict.txt -sylstressout 2-20mos.sylstress -sylout 2-20mos.syl -ipaout 2-20mos.pho


# begin getting command line options
  use Getopt::Long;
  &GetOptions("inputfile=s", # input file 
	               "dictfile=s", # dict file
	               "sylstressout:s", # sylstress file (default input.sylstress)
	               "sylout:s", # syllabification file (default input.syl)
	               "ipaout:s"); # ipa file (default input.pho)

if(!$opt_sylstressout){
  $opt_sylstressout = $opt_inputfile."\.sylstress";
}
if(!$opt_sylout){
  $opt_sylout = $opt_inputfile."\.syl";
}
if(!$opt_ipaout){
  $opt_ipaout = $opt_inputfile."\.pho";
}
print(STDERR "Reading in from $opt_inputfile\n");
print(STDERR "and creating $opt_sylstressout, $opt_sylout, and $opt_ipaout\n");

# open dictfile and dump all the translations into a hash

%dict = ();

open(DICT, "$opt_dictfile") or die("Couldn't open $opt_dictfile\n");
#binmode(DICT, ":utf8"); # for funky unicode characters
while(defined($dictfileline = <DICT>)){
  
  # extract word and IPA entry
#  if($dictfileline =~ /^([\w|\@|\'|\-|\^]+)\s+(.+)\n$/){
  if($dictfileline =~ /^([^\,]+)\,(.+)/){
    #check entry and ipa
    $word = $1;
    $ipa_form = $2;

    # make sure ipa form is non-empty
    if($ipa_form =~ /[\w\d]/){
      $dict{$word} = $ipa_form;
    }else{
      print("$word had empty ipa_form - not added to dictionary\n");
    }
  }
}
close(DICT);

# dict check: DEBUG
foreach $entry (sort(keys(%dict))){
#  print("DEBUG: dict entry $entry is $dict{$entry}\n");
}

# now go through each line of inputfile and convert the words there using the %dict hash
open(IN, "$opt_inputfile");
#binmode(IN, ":utf8"); # for funky unicode characters

# print out sylstress, syl only, & ipa only
open(SYLSTRESS, ">$opt_sylstressout");
#binmode(SYLSTRESS, ":utf8"); # for funky unicode characters
open(SYL, ">$opt_sylout");
#binmode(SYL, ":utf8"); # for funky unicode characters
open(IPA, ">$opt_ipaout");
#binmode(IPA, ":utf8"); # for funky unicode characters

while(defined($inputfileline = <IN>)){
  # line should be words divided by one space each
  # get rid of newline at the end
  # debug print
  #print("$inputfileline");

  chomp($inputfileline);

  @words_in_line = split(/ /,$inputfileline);

  # go through and replace
  $index = 0;
  while(defined($words_in_line[$index])){

    $word_to_find = $words_in_line[$index];
    # switch uppercase letters to lowercase letters
    # $word_to_find =~ tr/[A-Z]/[a-z]/;

    my $sylstress, $syl, $ipa;

    # check to make sure word has some characters in it
    if($word_to_find =~ /\w/){
      # check to see if in dict hash

      if(exists ($dict{$word_to_find})){
	#print($dict{$word_to_find} );
	$sylstress = $dict{$word_to_find};
	print(SYLSTRESS "$sylstress ");
	$syl = $sylstress;
	$syl =~ s/[01]//g;
	print(SYL "$syl ");
	$ipa = $syl;
	$ipa =~ s/\///g;
	print(IPA "$ipa ");
      }else{
	print("DEBUG: *** $word_to_find not found in \%dict\n");
      }
  }
    $index++;
  }
   print(SYLSTRESS "\n");
   print(SYL "\n");  
   print(IPA "\n");
}

close(IPA);
close(SYL);
close(SYLSTRESS);
close(IN);

# do some final preprocessing to get rid of final space at end
system("perl -p -e \'s\/ \$\/\/\' \< $opt_ipaout \> ipa.temp");
system("mv ipa.temp $opt_ipaout");
system("perl -p -e \'s\/ \$\/\/\' \< $opt_sylout \> syl.temp");
system("mv syl.temp $opt_sylout");
system("perl -p -e \'s\/ \$\/\/\' \< $opt_sylstressout \> sylstress.temp");
system("mv sylstress.temp $opt_sylstressout");




