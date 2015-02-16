# ABSTRACT: turns baubles into trinkets
use strict;
use warnings;
package CalVAD::WIM::ParseStatusSpreadsheeets;

use namespace::autoclean;
use Moose;

use Spreadsheet::Read;
use Data::Dumper;
use DateTime::Format::DateParse;
use DateTime::Format::Pg;
use Carp;

has 'past_month' => (
                     is  => 'ro',
                     isa => 'Bool',
                     required => 1,
                    );

has 'file' => (
               is  => 'ro',
               isa => 'Str',
               required => 1,
              );

has 'year' => (
               is  => 'ro',
               isa => 'Int',
               required => 1,
              );

has 'doc' => (
              is =>'ro',
              isa => 'ArrayRef',
              lazy => 1,
              init_arg => undef,
              builder   => '_build_doc',
             );

has 'header' => (
                 is=>'ro',
                 isa => 'HashRef',
                 lazy =>1,
                 init_arg => undef,
                 builder   => '_build_header',
                );

has 'data' => (
               is=>'ro',
               isa=>'ArrayRef',
               lazy=>1,
               init_arg => undef,
               builder   => '_build_data',
              );

has 'ts' =>(
            is=>'ro',
            isa=>'Str',
            lazy=>1,
            init_arg=>undef,
            builder => '_build_ts',
           );

sub _build_doc {
  my $self = shift;
  my $file = $self->file;
  #carp $file;

  my $ref;
  eval {$ref = ReadData ($file,'strip'=>3);};
  if( $@ ){
    croak $@ ;
  }
  return $ref;
}

sub _build_header {
  my $self = shift;
  my $sheet = $self->doc->[1];
  my $col = 1;
  my $row = 1;
  # look at the first row for the header
  my $header = {'site_no'=>1};
  if($self->past_month){
    $header->{'class_status'}=4;
  }else{
    $header->{'class_status'}=5;
  }
  $col=6;
  # verify?
  $header->{'class_notes'}=$col;
  $col++;
  # start checking values
  my $cell = cr2cell ($col, $row);
  #carp 'check for internal class notes ',$col, $cell, $sheet->{$cell};

  my $value = $sheet->{$cell};
  if($value =~ /class\s*notes/i){
    # that means there is something I care about
    $header->{'internal_class_notes'}=$col;
    $col++;
  }
  #$cell = cr2cell ($col, $row);
  #carp 'check before internal past month ',$col, $cell, $sheet->{$cell};
  if($self->past_month){
      $header->{'weight_status'}=$col;
      $col++; #skip the next month
  }else{
    $col++; # skip the prior month
    $header->{'weight_status'}=$col;
  }
  $col++;
  #$cell = cr2cell ($col, $row);
  #carp 'check for weight notes ',$col, $cell, $sheet->{$cell};
  $header->{'weight_notes'}=$col;
  # verify?

  $col++;
  $cell = cr2cell ($col, $row);
  $value = $sheet->{$cell};
  #carp 'check for internal weight notes ',$col, $cell, $value;
  if($value && $value =~ /weight\s*notes/i){
    # that means there is something I care about
    $header->{'internal_weight_notes'}=$col;
    $col++;
  }
  return $header;
}

sub _build_ts {
  my $self = shift;

  my $sheet = $self->doc->[1];             # first datasheet

  my $month = $sheet->{'E1'};
  if($self->past_month){
    $month = $sheet->{'D1'};
  }

  my $year = $self->year;
  my $ts = DateTime::Format::DateParse->parse_datetime("$month 1, $year");
  #  carp "$month 1, $year:  ", $ts;
  return DateTime::Format::Pg->format_date($ts);
}

sub _build_data {

  my $self = shift;

  my $sheet = $self->doc->[1];             # first datasheet

  my $ts = $self->ts;

  my $header = $self->header;

  my $bulk = [];
  # parse from row 2 until the first cell is empty
  my $row = 2;
  while(!$sheet->{"A$row"}){
      $row++;
  }
  while($sheet->{"A$row"}){
    my $record = {};
    foreach (keys %{$header}) {
      my $cell = cr2cell($header->{$_},$row);
      $record->{$_} = $sheet->{$cell};
    }
    $record->{'ts'}=$self->ts;

    # check for a possible error
    if ( !$record->{'class_status'} || !$record->{'weight_status'} ) {
      # possible mistake
      if ( ( $record->{'class_status'} || $record->{'weight_status'} )
           || ( $record->{'class_notes'} || $record->{'weight_notes'} ) )
        {
          # um, oops!
          carp Dumper  $record;
          croak 'inconsistent data';
        }
      # otherwise, nothing to see here.  move along
      carp 'nada';
      next;
    }
    #    carp Dumper 'pushing ',$record;
    push @{$bulk},$record;
  }
  continue {

    # increment the row
    $row++;
  }
  return $bulk;
}

__PACKAGE__->meta->make_immutable;
1;

=head1 SYNOPSIS

Parse the Excel spreadsheets that Caltrans WIM staff use to track the monthly status of each Weigh In Motion station.

=method new

create a new parser object.  The required parameters are

                'past_month'=>[0 or 1],
                'file'=>[complete path to input file],
                'year'=>[the year the file applies to]

The status spreadsheets have two months in them.  The first month listed is the previous month, and the second one is the current month.  In a perfect world, both values would be correct and up to date.  In practice, it is occasionally true that one of the two is not up to date.  By setting the "past_month" input parameter to 1, you can extract data from the prior month, to possibly fix some missing data.  The default is zero, but the parameter is required anyway to be explicit about what you want to do.

The file parameter needs to be the fully qualified path to the input file.

The year is not auto-extracted from the file name.  Instead, the user has to manually enter it in.  This is usually done in a script, where the year is known because all of the status spreadsheets are in folders below some higher level year folder.  It is error prone to try to extract the year from the file name, because what if CT decides to change their naming scheme?

=method past_month

Get the value of the past_month variable, which was set on object creation.  Immutable.

=method file

Get the value of the file variable, which was set on object creation.  Immutable.

=method year

Get the value of the year variable, which was set on object creation.  Immutable.

=method ts

Get the value of the ts variable.  This is a string value that is the date stamp added to each record. In theory, it is what will be entered into the database when you write each record into the db.  It should be the first day of the month (whether previous or current, as set by the past_month parameter) and the year.  Immutable.

=method doc

Get the parsed spreadsheet reference.  Immutable.

=method header

Get the value of the header object.  This is the result of processing the first row of the spreadsheet.  In some cases (more recent spreadsheets) the header will contain references to "internal_" variables.  Immutable.

=method data

Get the parsed status rows as an array ref.  You can probably write these to the database, as long as there are no unique key conflicts or whatever.  Immutable.
