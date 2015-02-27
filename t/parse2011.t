use Test::Modern; # see done_testing()
use Carp;
use Data::Dumper;

use CalVAD::WIM::ParseStatusSpreadsheeets;

my $file = File::Spec->rel2abs('./t/files/IRD 07-2011 MONTHLY SITE STATUS.xlsx');

my $obj = new_ok( 'CalVAD::WIM::ParseStatusSpreadsheeets' =>
               [
                'write_undefined' => 0,
                'past_month'=>0,
                'file'=>$file,
                'year'=>2011,
               ]
             );

my $doc;
eval{ $doc = $obj->doc; };
warn $@ if $@;

ok($doc,'created doc with xlsx file');

is($doc->[0]{'error'},undef,'no parsing error');
is($doc->[0]{'sheets'},2,'This one has two sheets for some reason.  Second one blank');
is($doc->[0]{'type'},'xlsx','recognized xlsx type');
is($doc->[0]{'parser'},'Spreadsheet::ParseXLSX','used Spreadsheet::ParseXLSX');

# try the header
my $header;
eval { $header = $obj->header ;} ;
if($@) {
  warn $@;
}

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


# get the spreadsheet's date

my $ts;
eval {$ts = $obj->ts; };
if($@){
        warn $@;
}
is($ts,'2011-07-01','timestamp not okay');

# try the data array

my $data;
eval { $data = $obj->data ;} ;
if($@) {
  warn $@;
}
is(scalar @{$data},112,'expect 112 records of WIM status info');



done_testing( 10 );
