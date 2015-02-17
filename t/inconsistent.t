use Test::More; # see done_testing()
use Carp;
use Data::Dumper;

require_ok( 'CalVAD::WIM::ParseStatusSpreadsheeets' );

my $obj;
eval { $obj = CalVAD::WIM::ParseStatusSpreadsheeets->new(); };

is($obj, undef, "object failed creation as expected");

my $file = File::Spec->rel2abs('./t/files/IRD 04-2009 MONTHLY SITE STATUS.xls');
my $obj = new_ok( 'CalVAD::WIM::ParseStatusSpreadsheeets' =>
               [
                'past_month'=>0,
                'file'=>$file,
                'year'=>2009,
               ]
             );

can_ok($obj,qw/past_month file year doc header data ts/);

is($obj->year,2009,'year should be 2009');
is($obj->file,$file,'file should not change');
is($obj->past_month,0,'past month should be falsy');

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
is($ts,'2009-04-01','timestamp not okay');

# get data
my $data;
eval {$data = $obj->data; };
if($@){
        warn $@;
}
ok($data,'got data okay');

done_testing( 10 );
