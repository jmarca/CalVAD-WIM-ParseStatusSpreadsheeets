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

my $file = File::Spec->rel2abs('./t/files/ird 09-2010 monthly site status.xls');
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
                   weight_status=>8,
                   weight_notes=>9,
                  }
          ,'header is parsed into correct column definitions');


$warnings = [warnings { $data = $obj->data; }];
is(scalar @{$warnings},0,"got expected number of warnings from $file");

ok($data,'got data okay');



done_testing;
