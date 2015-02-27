use Test::Modern; # see done_testing()
use Carp;
use Data::Dumper;

use CalVAD::WIM::ParseStatusSpreadsheeets;

my $obj;
my $header;
my $ts;

eval { $obj = CalVAD::WIM::ParseStatusSpreadsheeets->new(); };

is($obj, undef, "object failed creation as expected");

my $file = File::Spec->rel2abs('./t/files/IRD 08-2013 MONTHLY SITE STATUSBA.xlsx');
$obj = new_ok( 'CalVAD::WIM::ParseStatusSpreadsheeets' =>
               [
                'past_month'=>1,
                'file'=>$file,
                'year'=>2013,
               ]
             );

can_ok($obj,qw/past_month file year doc header data ts/);

is($obj->year,2013,'year should be 2013');
is($obj->file,$file,'file should not change');
is($obj->past_month,1,'past month should be truthy');

# try the header
eval { $header = $obj->header ;} ;
if($@) {
  warn $@;
}

is_deeply($header,{
                   site_no=>1,
                   class_status=>4,
                   class_notes=>6,
                   internal_class_notes=>7,
                   weight_status=>8,
                   weight_notes=>10,
                   internal_weight_notes=>11,
                  }
          ,'puke');

# get the spreadsheet's date

eval {$ts = $obj->ts; };
if($@){
        warn $@;
}
is($ts,'2013-07-01','timestamp okay');

# my $data = $obj->data;
# carp Dumper $data;

done_testing( 9 );
