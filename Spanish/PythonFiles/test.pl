#! usr/bin/perl

open(FULL,"<JacksonThal_full.txt") or die("Couldn't open Full\n");
binmode(FULL,":utf8");
@full = <FULL>; chomp(@full);
close(FULL);

open(MOS,"<jacksonthal20mos.txt") or die("Couldn't open Full\n");
binmode(MOS,":utf8");
@mos = <MOS>; chomp(@mos);
close(MOS);

open(OUT,">test.txt") or die("couldn't open out\n");
binmode(OUT,":utf8");

for($i=0;$i<@full;$i++){
	@full_words = split(/ /,$full[$i]);
	@mos_words = split(/ /,$mos[$i]);

	if(@full_words != @mos_words){
		print OUT "$i:\t$full[$i]\n\t$mos[$i]\n";
	}
}

close(OUT);
