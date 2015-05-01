package Syllabification;
use strict;
use warnings;

use Exporter;
use vars qw(@ISA @EXPORT);
our @ISA = qw(Exporter);
our @EXPORT = qw(maximum_onset_principle unicode_conversion train_test_split convert_to_lignos print_array find_onsets read_gervain);

sub maximum_onset_principle{
	my ($word, $vowels, $onset_ref) = @_;
	my %onsets = %{$onset_ref};

	my @syllables;
	my $curr_syl = "";

	my @char_array = split(//,$word);
	while(@char_array > 0){	
		my $char = pop(@char_array);
		$curr_syl = $char . $curr_syl;

        if($char =~ /[\%\$\#\@\!\&\*\+\-]/){
            $char = '\\' . $char;
        }

		# If we hit a vowel
		if($vowels =~ $char){
			my $onset = "";
			# Grab the largest possible onset
			while(@char_array > 0 && exists($onsets{$char_array[$#char_array] . $onset})){
				my $new_char = pop(@char_array);
				$onset = $new_char . $onset;
			}
			$curr_syl = $onset . $curr_syl;
			
			# Add syllable to syllabification
			unshift(@syllables, $curr_syl);
			$curr_syl = "";
		}
	}

	return join('/',@syllables);
}

sub unicode_conversion{
	my ($corpus_ref, $lang) = @_;
	my @corpus = @{$corpus_ref};
	my @uni_corpus;

	my $counter = 3001;
	my %syl_dict; my %word_dict;

	for my $i (0..$#corpus){
		my $line = $corpus[$i];
		# Clean up corpus line, just in case
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;

		my @words = split(/ /,$line);
		my $uni_line = '';
		for my $w (0..$#words){
			my @syls = split(/\//,$words[$w]);
			my $unicode_word = '';
			for my $s (0..$#syls){
				if(!exists($syl_dict{$syls[$s]})){
					$syl_dict{$syls[$s]} = chr(hex($counter));
					$counter++;
				}
				$unicode_word .= $syl_dict{$syls[$s]};
			}
			$word_dict{$words[$w]} = $unicode_word;

			$uni_line .= $unicode_word;
			if($w < $#words){ $uni_line .= ' '; }
		}
		if($i < $#corpus){ $uni_line .= "\n"; }

		$uni_corpus[$i] = $uni_line;
	}

	my $syl_dict_filename = "$lang/dicts/unicode-dict.txt";
	my $word_dict_filename = "$lang/dicts/unicode-word-dict.txt";
	my $unicode_corpus_filename = "$lang/$lang-uni.txt";

	# PRINT SYLLABLE-TO-UNICODE DICTIONARY
	open(my $syl_fh,">",$syl_dict_filename) or die("Couldn't open $syl_dict_filename for writing: $!\n");
	binmode($syl_fh,":utf8");
	my @syl_keys = sort keys %syl_dict;
	for my $i (0..$#syl_keys){
		print $syl_fh "$syl_keys[$i]\t$syl_dict{$syl_keys[$i]}";
		if($i < $#syl_keys){ print $syl_fh "\n"; }
	}
	close($syl_fh);

	# PRINT WORD-TO-UNICODE DICTIONARY
	open(my $word_fh,">",$word_dict_filename) or die("Couldn't open $word_dict_filename for writing: $!\n");
	binmode($word_fh,":utf8");
	my @word_keys = sort keys %word_dict;
	for my $i (0..$#word_keys){
		print $word_fh "$word_keys[$i]\t$word_dict{$word_keys[$i]}";
		if($i < $#word_keys){ print $word_fh "\n"; }
	}
	close($word_fh);

	# PRINT UNICODE CORPUS
	open(my $uni_fh,">",$unicode_corpus_filename) or die("Couldn't open $unicode_corpus_filename for writing: $!\n");
	binmode($uni_fh,":utf8");
	for my $i (0..$#uni_corpus){
		print $uni_fh $uni_corpus[$i];
	}
	close($uni_fh);

	return (\@uni_corpus, \%word_dict, \%syl_dict);
}

sub convert_to_lignos{
	my ($syl_ref, $vowels) = @_;
	my @syl_corpus = @$syl_ref;

	for my $i (0..$#syl_corpus){
		$syl_corpus[$i] =~ s/\s+$//; # Remove line-final spaces
		$syl_corpus[$i] =~ s/\/$//; # Remove line-final syllabification
		$syl_corpus[$i] =~ s/\|/\(/g;
		$syl_corpus[$i] =~ s/\//\|/g; # Syllable boundaries marked by '|'

		# Numbers cause issues in Lignos scripts
		$syl_corpus[$i] =~ s/1/~/g;
		$syl_corpus[$i] =~ s/2/=/g;
		$syl_corpus[$i] =~ s/3/?/g;
		$syl_corpus[$i] =~ s/4/{/g;
		$syl_corpus[$i] =~ s/5/}/g;
		$syl_corpus[$i] =~ s/6/[/g;
		$syl_corpus[$i] =~ s/7/]/g;
		$syl_corpus[$i] =~ s/8/</g;
		$syl_corpus[$i] =~ s/9/>/g;

		my $line = join('.',split(//,$syl_corpus[$i]));
	
		$line =~ s/(\s|\|)\./$1/g;
		$line =~ s/\.(\s|\|)/$1/g;

		$syl_corpus[$i] = '';
		foreach my $c (split(//,$line)){
			$syl_corpus[$i] .= $c;
			if($vowels =~ /\Q$c\E/ and $c !~ /[\.\|]/){
				$syl_corpus[$i] .= '0'; #If a vowel, give a 0 for stress marking
			}
		}
	}	

	return @syl_corpus;
}

sub train_test_split{
	# Take an array of lines, create 5 train/test splits, 90%/10% each
    my ($array_ref,$amt_train) = @_;
    my @lines = @$array_ref; chomp(@lines);
    ($amt_train > 0 and $amt_train < 1) or warn("Train \% of $amt_train is an invalid probability\n"), return 0;

	my $test_start = int(rand($#lines * $amt_train));
	my $test_end = int($test_start + $#lines * (1 - $amt_train));
    #print "Test start: $test_start\nTest end: $test_end\n";

	my @train = @lines[0..$test_start-1,$test_end+1..$#lines];
	my @test = @lines[$test_start..$test_end];

	return (\@train,\@test);
}

sub print_array{
	my ($array_ref, $filename) = @_;
	open(my $filehandle,">",$filename) or die("Couldn't open $filename for writing: $!\n");
	binmode($filehandle,":utf8");

	for my $i (0..$#{ $array_ref }){
		if($array_ref->[$i] !~ /^\s*$/){ # Only print if line is non-empty
			print $filehandle "$array_ref->[$i]";
			if($i < $#{ $array_ref }){ print $filehandle "\n"; }
		}
	}

	close($filehandle);
	return 1;
}

sub find_onsets{
    my ($corpus_ref,$vowels) = @_;
    my %onset_hash;

    ($vowels !~ /^\s*$/) or warn("Warning: No vowels found, behavior may be erratic\n"), return %onset_hash;

    foreach my $line (@{$corpus_ref}){
        my @words = split(/\s+/,$line);

        foreach my $word (@words){
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

            if($onset =~ /^\S+$/){
                $onset_hash{$onset} = 1;
            }
        }
    }

    return %onset_hash;
}

sub read_gervain{
    # The Gervain corpora (Italian/Hungarian) are formatted as a single line
    # With words separated by identifiers for syllable/word/utterance boundaries
    # Convert this line into a typical corpus
    # 1 utterance per line, words separated by spaces, syllables separated by '/'
    my $filename = $_[0];
    open(my $filehandle, "<",$filename) or die("Couldn't open $filename: $!\n");
    binmode($filehandle,":utf8");
    my @lines = <$filehandle>; chomp(@lines);
    close($filehandle);

    # Look at every item individually
    my @gervain_corpus = split(/\s+/,pop(@lines));
    my @corpus;
    my $corpus_line = 0; $corpus[$corpus_line] = '';
    foreach (@gervain_corpus){
        if($_ eq 'WB'){
            $corpus[$corpus_line] .= ' ';
        }elsif($_ eq 'WI' or $_ eq 'MB'){
            $corpus[$corpus_line] .= '/';
        }elsif($_ =~ /UB/){
            $corpus[$corpus_line] =~ s/\s+$//; # remove any trailing spaces
            $corpus_line++;
            $corpus[$corpus_line] = '';

            #print "Prev line: $corpus[$corpus_line - 1]\nCurr line: $corpus[$corpus_line]\nLine index: $corpus_line\n";
            #my $a = <STDIN>;
        }elsif($_ !~ /^\s*$/){
            $corpus[$corpus_line] .= $_;
        }          
    }

    return @corpus;
}

1;
