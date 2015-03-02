use Test::Modern; # see done_testing()
use Carp;
use Data::Dumper;

use CalVAD::WIM::StatusRecord;


use Test::Deep qw[
eq_deeply array_each subhashof ignore
];

my $str = 'MISSION GRADE NB';

my $num = CalVAD::WIM::StatusRecord->get_site_from_name($str);

is($num,856,'got mission grade nb site number');


done_testing;
