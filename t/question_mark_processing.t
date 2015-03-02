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

my $file = File::Spec->rel2abs('./t/files/IRD 08-2011 MONTHLY SITE STATUS.xlsx');
$obj = CalVAD::WIM::ParseStatusSpreadsheeets->new
    (
             'write_undefined' => 0,
             'past_month'=>0,
             'file'=>$file,
             'year'=>2011,
    );

$header  = $obj->header ;

is_deeply($header,{
                   site_no=>1,
                   class_status=>5,
                   class_notes=>6,
                   internal_class_notes=>7,
                   weight_status=>9,
                   weight_notes=>10,
                   internal_weight_notes=>11,
                  }
          ,'header is parsed into correct column definitions');


$warnings = [warnings { $data = $obj->data; }];
is(scalar @{$warnings},0,"got expected number of warnings from $file");

ok($data,'got data okay');

for my $record (@{$data}){
    if($record->{'site_no'} == 15){
        is($record->{'class_status'},'?','Passed along question mark without change');
    }
}
$obj = CalVAD::WIM::ParseStatusSpreadsheeets->new
    (
             'write_undefined' => 1,
             'past_month'=>0,
             'file'=>$file,
             'year'=>2011,
    );
$warnings = [warnings { $data = $obj->data; }];
is(scalar @{$warnings},1,"got expected number of warnings from $file");

ok($data,'got data okay');

for my $record (@{$data}){
    if($record->{'site_no'} == 15){
        is($record->{'class_status'},'UNDEFINED','Reset question mark to UNDEFINED');
    }
}


done_testing;
