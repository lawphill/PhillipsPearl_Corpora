#! usr/bin/perl
# Run all code for English corpora

system("perl edit-dict-brent.pl");
system("perl adding-syllabification.pl");
system("perl create-unicode-dict.pl");
system("perl convert-to-unicode.pl");
system("perl convert-to-english.pl");
