use strict;
use warnings;
use Spreadsheet::Read;
use Data::Dumper;

my $ref;
eval{ $ref = ReadData('../../../t/files/IRD 08-2013 MONTHLY SITE STATUSBA.xlsx') ; };
warn $@ if $@;
warn Dumper $ref->[0];

eval{ $ref = ReadData('../../../t/files/IRD 08-2009 MONTHLY SITE STATUS.xls') ; };
warn $@ if $@;
warn Dumper $ref->[0];

warn $ref->[1]{'G1'};
my $sheet = $ref->[1];
warn $sheet->{'G1'};
