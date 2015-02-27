use Test::Modern; # see done_testing()
use Carp;
use Data::Dumper;

use CalVAD::WIM::ParseStatusSpreadsheeets;
my $obj;

##################################################
# lame file with a unique format
##################################################

my $file = File::Spec->rel2abs('./t/files/IRD 11-2011 MONTHLY SITE STATUS.xlsx');
$obj = new_ok( 'CalVAD::WIM::ParseStatusSpreadsheeets' =>
               [
                'past_month'=>0,
                'file'=>$file,
                'year'=>2011,
               ]
             );

can_ok($obj,qw/past_month file year doc header data ts/);

my $sheet = $obj->doc->[1];
my $fmt = $sheet->{'attr'};

## what is in column 1 for these?

my $site_cell = $obj->site_cell;
is($site_cell,'A1','found the row and column with "site"');
my $data_row= $obj->first_data_row;
is($data_row,3,'found start of data');

my $months = $obj->month_cells;
is_deeply($months,['D2','F2','H2','J2',],'identified months correctly');

my $header  = $obj->header ;

is_deeply($header,{
                   site_no=>1,
                   class_status=>6,
                   class_notes=>7,
                   # internal_class_notes=>undef,
                   weight_status=>10,
                   weight_notes=>11,
                   # internal_weight_notes=>undef,
                  }
          ,'header is parsed into correct column definitions');


# get the spreadsheet's date
my $ts = $obj->ts;

is($ts,'2011-11-15','timestamp  okay');


my $notes_array = $obj->_build_notes_cells;

is_deeply($notes_array,[7,0,11,0,],'got notes in right places');

# get data
my $data;
eval {$data = $obj->data; };
if($@){
        warn $@;
}
ok($data,'got data okay');

done_testing;
