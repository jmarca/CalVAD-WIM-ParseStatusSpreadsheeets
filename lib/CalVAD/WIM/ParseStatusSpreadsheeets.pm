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
