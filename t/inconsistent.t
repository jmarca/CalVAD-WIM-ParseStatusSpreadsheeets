use Test::Modern; # see done_testing()
use Carp;
use Data::Dumper;

use CalVAD::WIM::ParseStatusSpreadsheeets;

my $obj;
my $ts;
my $data;
my $header;
my $warnings;

my $file = File::Spec->rel2abs('./t/files/IRD 04-2009 MONTHLY SITE STATUS.xls');
$obj = new_ok( 'CalVAD::WIM::ParseStatusSpreadsheeets' =>
               [
                'write_undefined'=>0,
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
$warnings = [warnings { $data = $obj->data; }];
is(scalar @{$warnings},0,"got expected number of warnings from $file");

ok($data,'got data okay');

##################################################
# try another inconsistent file
##################################################

$file = File::Spec->rel2abs('./t/files/IRD 11-2009 MONTHLY SITE STATUS.xls');
$obj = new_ok( 'CalVAD::WIM::ParseStatusSpreadsheeets' =>
               [
                'write_undefined'=>0,
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
is($ts,'2009-11-01','timestamp not okay');

# get data
$warnings = [warnings { $data = $obj->data; }];
is(scalar @{$warnings},1,"got expected number of warnings from $file");

ok($data,'got data okay');


# try again with write_undefined switched on
$obj = CalVAD::WIM::ParseStatusSpreadsheeets->new(
    {
        'write_undefined' => 1,
        'past_month'      => 0,
        'file'            => $file,
        'year'            => 2009,
    }
);
# get data
$warnings = [warnings { $data = $obj->data; }];
is(scalar @{$warnings},3,"got expected number of warnings from $file");
ok($data,'got data okay');

##################################################
# try another inconsistent file
##################################################

$file = File::Spec->rel2abs('./t/files/ird 02-2010 monthly site status_binyu.xls');
$obj = CalVAD::WIM::ParseStatusSpreadsheeets->new(
    {
        'write_undefined' => 0,
        'past_month'      => 0,
        'file'            => $file,
        'year'            => 2010,
    }
);

can_ok($obj,qw/past_month file year doc header data ts/);

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

# get data
$warnings = [warnings { $obj->data; }];
is(scalar @{$warnings},46,"got expected number of warnings from this badly broken $file");
ok($data,'got data okay');

# try again with write_undefined set to true
$obj = CalVAD::WIM::ParseStatusSpreadsheeets->new(
    {
        'write_undefined' => 1,
        'past_month'      => 0,
        'file'            => $file,
        'year'            => 2010,
    }
);
$warnings = [warnings { $obj->data; }];
is(scalar @{$warnings},95,"got expected number of warnings from this badly broken $file");
ok($data,'got data okay');


done_testing();
