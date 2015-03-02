use Test::Modern; # see done_testing()
use Carp;
use Data::Dumper;

use CalVAD::WIM::ParseStatusSpreadsheeets;
my $obj;
my $warnings;
my $data;
my $header;
##################################################
# crazy failure
##################################################

my $file = File::Spec->rel2abs('./t/files/IRD 02-2012 MONTHLY SITE STATUS.xlsx');
$obj = CalVAD::WIM::ParseStatusSpreadsheeets->new
    (
             'write_undefined' => 0,
             'past_month'=>0,
             'file'=>$file,
             'year'=>2012,
    );

$header  = $obj->header ;

is_deeply($header,{
                   site_no=>1,
                   class_status=>5,
                   class_notes=>6,
                   internal_class_notes=>7,
                   weight_status=>10,
                   weight_notes=>11,
                   internal_weight_notes=>12,
                  }
          ,'header is parsed into correct column definitions');


$warnings = [warnings { $data = $obj->data; }];
is(scalar @{$warnings},0,"got expected number of warnings from $file");

ok($data,'got data okay');

for my $record (@{$data}){
    if($record->{'site_no'} == 43){
        is($record->{'class_status'},'G/B','Removed spaces from G / B');
    }
}

done_testing;
