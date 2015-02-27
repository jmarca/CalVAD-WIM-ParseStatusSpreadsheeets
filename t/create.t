use Test::Modern; # see done_testing()
use Carp;
use Data::Dumper;

use CalVAD::WIM::ParseStatusSpreadsheeets;

my $obj;
eval { $obj = CalVAD::WIM::ParseStatusSpreadsheeets->new(); };

is($obj, undef, "object failed creation as expected");

my $file = File::Spec->rel2abs('./t/files/IRD 08-2013 MONTHLY SITE STATUSBA.xlsx');

$obj = new_ok( 'CalVAD::WIM::ParseStatusSpreadsheeets' =>
               [
                'past_month'=>0,
                'write_undefined' => 0,
                'file'=>$file,
                'year'=>2013,
               ]
             );

can_ok($obj,qw/past_month file year doc header data ts/);

is($obj->year,2013,'year should be 2013');
is($obj->file,$file,'file should not change');
isnt($obj->past_month,1,'past month should be falsy');

my $doc;
eval{ $doc = $obj->doc; };
warn $@ if $@;

ok($doc,'created doc with xlsx file');

is($doc->[0]{'error'},undef,'no parsing error');
is($doc->[0]{'sheets'},1,'got one sheet');
is($doc->[0]{'type'},'xlsx','did not recognize xlsx type');
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
          ,'puke');

# get the spreadsheet's date

my $ts;
eval {$ts = $obj->ts; };
if($@){
        warn $@;
}
is($ts,'2013-08-01','timestamp okay');

# try the data array

my $data;
eval { $data = $obj->data ;} ;
if($@) {
  warn $@;
}
is(scalar @{$data},117,'expect 117 records of WIM status info');


##################################################
# now repeat with an older excel file

$file = File::Spec->rel2abs('./t/files/IRD 08-2009 MONTHLY SITE STATUS.xls');
$obj = new_ok( 'CalVAD::WIM::ParseStatusSpreadsheeets' =>
               [
                'past_month'=>0,
                'write_undefined' => 0,
                'file'=>$file,
                'year'=>2009,
               ]
             );
eval{ $doc = $obj->doc; };
warn $@ if $@;
ok($doc,'created doc with xls file');
is($doc->[0]{'error'},undef,'no parsing error');
is($doc->[0]{'sheets'},1,'got one sheet');
is($doc->[0]{'type'},'xls','did not recognize xls type');
is($doc->[0]{'parser'},'Spreadsheet::ParseExcel','used Spreadsheet::ParseExel');


# try the header
eval { $header = $obj->header ;} ;
if($@) {
  warn $@;
}

is_deeply($header,{
                   site_no=>1,
                   class_status=>5,
                   class_notes=>6,
                   weight_status=>8,
                   weight_notes=>9,
                  }
          ,'puke');

# get the spreadsheet's date
eval {$ts = $obj->ts; };
if($@){
        warn $@;
}
is($ts,'2009-08-01','timestamp okay');

# try the data array

eval { $data = $obj->data ;} ;
if($@) {
  warn $@;
}
is(scalar @{$data},110,'expect 110 records of WIM status info');


done_testing( 24 );
