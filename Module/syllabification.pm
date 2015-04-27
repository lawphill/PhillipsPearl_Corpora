package syllabification;
use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(maximum_onset_principle);

sub maximum_onset_principle{
	my ($word, $vowels, $onset_ref) = @_;
	my %onsets = %{$onset_ref};

	my @syllables;
	my $curr_syl = "";

	my @char_array = split(//,$word);
	while(@char_array > 0){	
		my $char = pop(@char_array);
		$curr_syl = $char . $curr_syl;

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

	#my $syllabified = join('/',@syllables);
	#return $syllabified;
	return join('/',@syllables);
}

1;
