#!/usr/bin/perl

# reads in CLAN output and extracts child-directed speech utterances, removing irrelevant characters


#example input:
#kwal -t*CHI +re +s* +u *.cha
#Mon Nov 22 15:30:45 2010
#kwal (06-Jan-2005) is conducting analyses on:
#  ALL speaker main tiers EXCEPT the ones matching: *CHI;
#****************************************
#From file <Sinte:Users:lspearl:Documents:LingCogSci:Corpora:CHILDES:Farsi Transcripts:Family:lilia:lilia01.cha>
#----------------------------------------
#*** File "Sinte:Users:lspearl:Documents:LingCogSci:Corpora:CHILDES:Farsi Transcripts:Family:lilia:lilia01.cha": line 12. Keywords: xxx, . 
#*SOM:	xxx . 1_1963
#----------------------------------------
#*** File "Sinte:Users:lspearl:Documents:LingCogSci:Corpora:CHILDES:Farsi Transcripts:Family:lilia:lilia01.cha": line 15. Keywords: &laugh, . 
#*SOM:	&laugh . 3259_3990
#----------------------------------------
#*** File "Sinte:Users:lspearl:Documents:LingCogSci:Corpora:CHILDES:Farsi Transcripts:Family:lilia:lilia01.cha": line 18. Keywords: æz, in, mitærsi, ? 
#*MOT:	<æz in mitærsi> [>] ? 6036_7332
#----------------------------------------

# example output from above input
# æz in mitærsi

# example usage:
# extract_farsi_utt.pl --input farsi_utterances.cha --output farsi_utterances.txt

process_options();
open(INPUT, "$input") || die("Couldn't open $input as input file\n");
open(OUTPUT, ">$output") || die("Couldn't open $output as output file\n");

while(defined($in_line = <INPUT>)){
  # determine if line is utterance line
  if(want_this_line($in_line) eq "yes"){
    #print("debug: want this line: $in_line\n");
  # if so, get rid of all the irrelevant parts
    $no_junk_line = remove_junk($in_line);
    #print("***debug: no junk line is $no_junk_line\n");
    # if line still has any word characters left in it, print it out to output file
    if($no_junk_line =~ /\w/){
      print(OUTPUT $no_junk_line);
    }
  }
}

close(OUTPUT);
close(INPUT);

sub remove_junk{
  my ($curr_utterance) = @_;

  #print( "debug:\n***\nbefore extraneous junk removed: \n$curr_utterance\n");
  # get rid of speaker id info
  $curr_utterance =~ s/^\*\w+\:\s+//;
  #print( "debug:\n***\nafter header removed: \n$curr_utterance\n");

  $curr_utterance =~ s/\&\=[\w|\_]+//g;
  $curr_utterance =~ s/\&[^\s]+//g;
  $curr_utterance =~ s/\@(\w+)?//g;
  $curr_utterance =~ s/\=//g;
  $curr_utterance =~ s/≈//g;
  $curr_utterance =~ s/\~//g;
  $curr_utterance =~ s/\*//g;
  $curr_utterance =~ s/¿//g;
  $curr_utterance =~ s/\"//g;
  $curr_utterance =~ s/\://g;
  $curr_utterance =~ s/ʔ//g;
  $curr_utterance =~ s/.*?//g;
  $curr_utterance =~ s/\d\_\d//g;
  $curr_utterance =~ s/\#//g;
  $curr_utterance =~ s/\%//g;  
  $curr_utterance =~ s/\.\.+//g;
  $curr_utterance =~ s/\-\-+//g;
  $curr_utterance =~ s/\+//g;
  $curr_utterance =~ s/\[.*?\]//g;
  $curr_utterance =~ s/\<.*?\>//g;
  $curr_utterance =~ s/\{.*?\}//g;
  $curr_utterance =~ s/\[//g;
  $curr_utterance =~ s/\]//g;
  $curr_utterance =~ s///g;
  $curr_utterance =~ s///g;
  $curr_utterance =~ s/⌈//g;
  $curr_utterance =~ s/⌊//g;
  $curr_utterance =~ s/⌉//g;
  $curr_utterance =~ s/⌋//g;
  $curr_utterance =~ s/(\w)\:(\w)/$1$2/g;
  $curr_utterance =~ s/\#\d\_\d//g;
  $curr_utterance =~ s/\#[\d|\w]+//g;
  $curr_utterance =~ s/ \// /g;
  $curr_utterance =~ s/★//g;
  $curr_utterance =~ s/°//g;
  $curr_utterance =~ s/↑//g;
  $curr_utterance =~ s/↘//g;
  $curr_utterance =~ s/↗//g;
  $curr_utterance =~ s/↓//g;
  $curr_utterance =~ s/\&\w+//g;
  $curr_utterance =~ s/\///g;
  $curr_utterance =~ s/£//g;
  $curr_utterance =~ s/\:\:+//g;
  $curr_utterance =~ s/▁//g;
  $curr_utterance =~ s/▔//g;
  $curr_utterance =~ s/\d //g;
  $curr_utterance =~ s/xx+//g;
  $curr_utterance =~ s/yy+//g;
  $curr_utterance =~ s/ww+//g;
  $curr_utterance =~ s/\(//g;
  $curr_utterance =~ s/\)//g;
  $curr_utterance =~ s/\<//g;
  $curr_utterance =~ s/\^\w+//g;
  #print( "debug:\n***\nafter junk removed: \n$curr_utterance\n");

  # remove commas
  $curr_utterance =~ s/\,//g;
  # convert to lowercase
  $curr_utterance = lc($curr_utterance);

  # replace punctuation with newlines
  $curr_utterance =~ s/[\.|\?|\!]/\n/g;
  
  # get rid of line-initial spaces
  $curr_utterance =~ s/^\s+//g;
  
  # get rid of spaces after newly inserted lines
  $curr_utterance =~ s/\n +/\n/g;

  # get rid of spaces before newlines
  $curr_utterance =~ s/ +\n/\n/g;

  # get rid of underscores which mark routinized phrases
  $curr_utterance =~ s/\_//g;
  
  # get rid of multiple spaces
  $curr_utterance =~ s/ +/ /g;

  # get rid of duplicate newlines
  $curr_utterance =~ s/\n+/\n/g;

  return $curr_utterance;
}

sub want_this_line{
  my ($in_line) = @_;
  my $want_it = "no";

  if($in_line =~ /^\*(INV|PAR)\:/){ # Spoken by Investigator or Parent
    $want_it = "yes";
  }

  return $want_it;
}


sub process_options{
  
  use Getopt::Long;
  &GetOptions("input=s" => \$input, "output=s" => \$output); # required filename options
}
