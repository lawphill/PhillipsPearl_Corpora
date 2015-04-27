#! usr/bin/perl

# The goal of this script is to translate all function words/morphemes into the same formatting as in the Gervain corpus

open(FUNC,"<hungarian_funcwords.txt") or die("coudlnt' open hungarian_funcwords for reading\n");
@func_raw = <FUNC>;
chomp(@func_raw);
close(FUNC);

open(MORPH,"<hungarian_morphemes.txt") or die("couldn't open hungarian_morphemes for reading\n");
@morph_raw = <MORPH>;
chomp(@morph_raw);
close(MORPH);

open(OUT_FUNC,">hungarian_funcwords_ipa.txt") or die("couldn't open funcwords_ipa.txt\n");
open(OUT_MORPH,">hungarian_morph_ipa.txt") or die("couldn't open morph_ipa.txt\n");

for($i=0;$i<@func_raw;$i++){
	$new_line = &modify($func_raw[$i]);
	if($new_line !~ /^\s*$/){
		print OUT_FUNC "$new_line";
		if($i+1!=@func_raw){ print OUT_FUNC "\n"; }
	}
}

for($i=0;$i<@morph_raw;$i++){
	$new_line = &modify($morph_raw[$i]);
	if($new_line !~ /^\s*$/){
		print OUT_MORPH "$new_line";
		if($i+1!=@morph_raw){ print OUT_MORPH "\n"; }
	}
}

close(OUT_FUNC);
close(OUT_MORPH);

sub modify {
	$line = $_[0];
	if($line =~ /^\s/){
		$line = "";
	}else{ # Grab the initial orthography
		if($line =~ /[\/\[]/){
			$line =~ /(.*?)[\/\[].*[\/\]]/;
			$word = $1;
			$word =~ s/\-//g;
		}elsif($line =~ /\-/){
			if($line =~ /^\-/){
				$line =~ /^\-(.*?)[\-\s]/; $word = $1;
			}else{ $line =~ /^(.*?)\-/; $word = $1;}

			$word =~ s/\-//g;
		}
	
		# Perform substitutions
		$word =~ s/dzs/3/g;
		$word =~ s/dz/2/g;	
		$word =~ s/cs/1/g;
		$word =~ s/gy/4/g;	
		$word =~ s/ny/5/g;
		$word =~ s/sz/6/g;
		$word =~ s/ty/7/g;
		$word =~ s/zs/8/g;
		$word =~ s/y/i/g;
		$word =~ s/ý/í/g;

		$word =~ s/\://g;
		$word =~ s/\s//g;

		$word; # return value
	}
}
