# ABSTRACT: turns baubles into trinkets
use strict;
use warnings;
package CalVAD::WIM::ParseStatusSpreadsheeets;

use namespace::autoclean;
use Moose;

use Spreadsheet::Read;
use Data::Dumper;
use DateTime::Format::Pg;
use DateTime::Format::Strptime;
use Carp;


has 'write_undefined' => (
    is => 'ro',
    isa => 'Bool',
    required => 1,
    );

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

has 'site_cell' =>(
    is=>'ro',
    isa=>'Str',
    lazy=>1,
    builder=>'_build_site_cell',
    );

has 'first_data_row' => (
    is  => 'ro',
    isa => 'Int',
    lazy=>1,
    builder=>'_build_first_data_row',
              );

has 'month_cells' =>(
    is=>'ro',
    isa=>'ArrayRef',
    lazy=>1,
    builder=>'_build_month_cells',
    );

has 'notes_cells' =>(
    is=>'ro',
    isa=>'ArrayRef',
    lazy=>1,
    builder=>'_build_notes_cells',
    );

my $strp = DateTime::Format::Strptime->new(
    pattern   => '%Y %B %d',
    );

sub _build_doc {
  my $self = shift;
  my $file = $self->file;
  #carp $file;

  my $ref;
  eval {$ref = ReadData ($file,'strip'=>3,'attr'=>1);};
  if( $@ ){
    croak $@ ;
  }
  return $ref;
}


sub _build_header {
    my $self  = shift;
    my $sheet = $self->doc->[1];

    # use other elements to build up the header

    my $header = {
        'site_no'      => ( cell2cr( $self->site_cell ) )[0],
        'class_notes'  => $self->notes_cells->[0],
        'weight_notes' => $self->notes_cells->[2],
    };

    # test for prior month choice to pick off correct status columns
    if ( $self->past_month ) {
        $header->{'class_status'}  = ( cell2cr( $self->month_cells->[0] ) )[0];
        $header->{'weight_status'} = ( cell2cr( $self->month_cells->[2] ) )[0];
    }
    else {
        $header->{'class_status'}  = ( cell2cr( $self->month_cells->[1] ) )[0];
        $header->{'weight_status'} = ( cell2cr( $self->month_cells->[3] ) )[0];
    }

    # are there internal notes on this spreadsheet?
    if ( $self->notes_cells->[1] ) {
        $header->{'internal_class_notes'} = $self->notes_cells->[1];
    }
    if ( $self->notes_cells->[3] ) {
        $header->{'internal_weight_notes'} = $self->notes_cells->[3];
    }

    return $header;
}

sub _build_site_cell{
    my $self=shift;
    # scan for first instance of "^site" and figure out the column for
    # site, then scan rows and find the first row that has site
    # number, and then the rows before that are header rows.
    my $site_column = 0;
    my $site_row = 0;

    my $sheet = $self->doc->[1];
  OUTER: for my $column (@{$sheet->{'cell'}}) {
    INNER: for my $cell (@{$column}) {
        # carp "cell is $cell, looking for site";
        if($cell && $cell =~ /^site/i ){
            last OUTER ;
        }
        $site_row++;
    }
      $site_column++;

  }
    return cr2cell($site_column,$site_row);
}

sub _build_first_data_row {

    # know which column the site is defined, look for the first row
    # with a numeric value.  back up one.  those are the header rows.
    my $self = shift;
    my ( $col, $row ) = cell2cr( $self->site_cell );
    my $sheet      = $self->doc->[1];
    my $header_end = 0;
    my $column     = $sheet->{'cell'}[$col];
  OUTER: for my $cell ( @{$column} ) {
        if ( $header_end <= $row ) {
            $header_end++;
            next OUTER;

        }
        if ( $cell && $cell =~ /^\d+$/ ) {
            last OUTER;

        }
        $header_end++;
    }

    # we've found the first number
    return $header_end;

}

#
# in the first two rows, somewhere month is defined.  **usually** it
# is prior month and current month, and they are next to each other.
# 2011 november it is broken, just one month, and with 1 to 14, 15 to
# 30.  So that means I have to hunt around for which column has the
# month, and in that case, which day it represents.
#
sub _build_month_cells{
    my $self=shift;
    my $sheet = $self->doc->[1];             # first datasheet

    # scan the first row and the second row for "month-alike" character strings
    my $data_row = $self->first_data_row;
    my $header_end = $data_row - 1;
    my ( $site_col, $site_row ) = cell2cr( $self->site_cell );
    # placeholders for month columns
    my $months = [0,0,0,0];
    my $idx = 0;
    my $current_column = 0;
    # the month can be in any row from 1 to $data_row
    # the month can be in any column from site_col to end.
  OUTER: for my $column (@{$sheet->{'cell'}}){
      if($current_column  <= $site_col){
          $current_column++;
          next OUTER;
      }
      # test current cell for a month-alike string
    INNER: for my $row(1..$header_end){
        my $candidate = $column->[$row];
        if($candidate){
            # carp $candidate;
            my $three = substr($candidate,0,3);
            my $dt = $strp->parse_datetime("1970 $three 1");
            if($dt){
                $months->[$idx]=cr2cell($current_column,$row);
                $idx++;
                # carp "added a month, next index is $idx";
                if($idx >= scalar @{$months}){
                    last OUTER;
                }
            }else{
                # carp "date time didn't recognize 1970 $candidate 1";
            }
        }
    }
      $current_column++;
  }

    return $months;

}

#
# in the header rows, somewhere "class notes" and "weight notes" are
# defined
#
sub _build_notes_cells {
    my $self  = shift;
    my $sheet = $self->doc->[1];    # first datasheet

    # scan the first row and the second row for "month-alike" character strings
    my $data_row   = $self->first_data_row;
    my $header_end = $data_row - 1;
    my ( $site_col, $site_row ) = cell2cr( $self->site_cell );

    # placeholders for month columns
    my $months          = $self->month_cells;
    my $first_month_col = ( cell2cr( $months->[0] ) )[0];
    my $notes           = [ 0, 0, 0, 0 ];
    my $idx             = 0;
    my $current_column  = 0;

    ## and finally, know whether this is the dreaded "split month" case
    my $split_month = $self->_split_month_check();
    my $firstrow = [Spreadsheet::Read::cellrow($sheet,1)];
    my $secondrow = [Spreadsheet::Read::cellrow($sheet,2)];
    # carp Dumper {'1'=>$firstrow,'2',$secondrow};
    # the class/weight notes can be in any row from 1 to $data_row
    # and any column, but typically greater or equal to month
  OUTER: for my $column_number ( $first_month_col .. scalar @{ $sheet->{'cell'} } -1 ) {
      if ( $idx >= scalar @{$notes} ) {

            last OUTER;
      }

      my $column = $sheet->{'cell'}[$column_number];
      # carp "continuing, index = $idx, $column_number";

        # test current cell for "class notes" or "weight notes"
      INNER: for my $row ( 1 .. $header_end ) {
          my $candidate = $column->[$row];
          # carp "col=$column_number, candidate=$candidate";
            if ( $candidate && $candidate =~ /notes/i ) {
                # carp 'matched notes';
                # make sure on right index
                if ( $candidate =~ /weight/i && $idx < 2 ) {
                    # carp 'matched weight';
                    $idx = 2;
                }

                # at this point, logic is same for weight and class.
                # Using $idx as a pointer to the correct point in the
                # $notes arrayref
                if ($split_month) {
                    # carp 'split month';
                    # split month, 1 to 14, then 15 to 30

                    # in the split month case that I've seen then the
                    # class notes cell is merge of 4 columns, with
                    # status in +0 and +2, note data in +1 and +3
                    # carp "writing to $idx, $column_number";
                    $notes->[$idx] =
                        $self->past_month
                      ? $column_number + 1
                      : $column_number + 3;
                    $idx += 2;              #skip internal class notes slot
                    $column_number += 4;
                    # carp Dumper {'notes'=>$notes};
                    next OUTER;
                }
                else {
                    # carp 'not split month case';
                    # in the not split month case, we either have a
                    # single column for class notes, or it extends
                    # over two columns and the second is the internal
                    # class notes.

                    # so check if cell is merged right
                    if (
                        $self->_is_merged_right_check(
                            {
                                'col' => $column_number,
                                'row' => $row,
                            }
                        )
                      )
                    {
                        # is merged right, so second col is "internal notes"
                        $notes->[$idx] = $column_number;
                        $idx++;

                        # internal notes
                        $notes->[$idx] = $column_number + 1;
                        $idx++;
                        $column_number += 2;
                        next OUTER;
                    }
                    else {
                        # cell is not merged right, just stash current indexed
                        $notes->[$idx] = $column_number;
                        $idx++;
                        $column_number++;
                        next OUTER;
                    }

                }
            }
        }
        $column_number++;
    }
    # carp Dumper {'notes'=>$notes};
    return $notes;

}

sub _split_month_check {
    my $self = shift;
    my $sheet = $self->doc->[1];             # f1irst datasheet
    my $prior_month = $sheet->{$self->month_cells->[0]};
    $prior_month = substr($prior_month,0,3);
    my $curr_month = $sheet->{$self->month_cells->[1]};
    $curr_month = substr($curr_month,0,3);
    my $prior_dt = $strp->parse_datetime("1970 $prior_month 1");
    my $curr_dt  = $strp->parse_datetime("1970 $curr_month 1");
    return $prior_dt eq $curr_dt;
}

sub _is_merged_right_check {
    my $self = shift;
    my $args = shift;
    my $col = $args->{'col'};
    my $row = $args->{'row'};
    my $sheet = $self->doc->[1];

    # basically, check if col,row is merged, and if col+1, row is both
    # empty and merged.  If so, the assumption is that we're merged
    # together
    #
    # this is not forever true, because there are several degenerate
    # cases.  However, I don't have those (yet) in practice, so I'll
    # ignore them for now and pop up a new test case if I ever hit
    # them
    #
    my $merged = $sheet->{'attr'}->[$col][$row]->{'merged'};
    my $right_value = $sheet->{cr2cell($col+1,$row)};
    my $right_merged = $sheet->{'attr'}->[$col+1][$row]->{'merged'};
    #
    # if all are true
    #

    return $merged && !$right_value && $right_merged;
}

sub _build_ts {
  my $self = shift;

  my $sheet = $self->doc->[1];             # first datasheet

  my $prior_month = $sheet->{$self->month_cells->[0]};
  $prior_month = substr($prior_month,0,3);
  my $curr_month = $sheet->{$self->month_cells->[1]};
  $curr_month = substr($curr_month,0,3);
  my $year = $self->year;

  # two cases.
  #
  # First case there is a prior month and a past month
  #
  my $prior_dt = $strp->parse_datetime("$year $prior_month 1");
  my $curr_dt  = $strp->parse_datetime("$year $curr_month 1");

  if($prior_dt eq $curr_dt){
      # the same date means the same month.  So past_month flag means
      # use the first, and the current_month flag means use the 15th
      if(!$self->past_month){
          $curr_dt  = $strp->parse_datetime("$year $curr_month 15");
      }
  }

  if($self->past_month){
      return DateTime::Format::Pg->format_date($prior_dt);
  }else{
      return DateTime::Format::Pg->format_date($curr_dt);
  }
  return; # error to get here, by the way
}

sub expand_abbrev {
    my $self    = shift;
    my $record  = shift;
    my $lookups = [
        [ 'cl[^a]', 'class' ],
        [ 'lc',     'low counts', ],
        [ 'ln',     'lane' ],
        [ 'w/o',    'weight over' ],
        [ 'w/d',    'weight diff' ],
        [ 'h/c',    'high class' ],
    ];
    for my $pair ( @{$lookups} ) {
        my $match = $pair->[0];
        my $value = $pair->[1];
        $record =~ s/$match/$value/i;
    }
    return $record;
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
      if($record->{$_}){
          $record->{$_} =~ s/\s*\/\s*/\//g;
      }
      if($_ =~ /notes/ &&  $record->{$_}){
          $record->{$_} = $self->expand_abbrev($record->{$_});
      }
    }
    $record->{'ts'}=$self->ts;

    # check for a possible error
    if ( (!$record->{'class_status'}  || $record->{'class_status'} eq '?') ||
         (!$record->{'weight_status'} || $record->{'weight_status'} eq '?')) {
      # possible mistake
        if ( (!$record->{'class_status'} || $record->{'class_status'} eq '?') &&
  $record->{'class_notes'} ){
            # have a class note, but no class status
            # try using the color of the note
            my $cl = $sheet->{'cell'}->[$header->{'class_notes'}][$row];
            my $attr = $sheet->{'attr'}->[$header->{'class_notes'}][$row];
            my $fgcolor = $attr->{'fgcolor'};
            # carp Dumper [$record,$cl,$attr,$fgcolor];
            if(! defined $fgcolor && $record->{'class_notes'} ){
                $record->{'class_status'}='G';
                carp 'fgcolor of note is undefined but the note exists; assuming good class status for row ',$row,' file ',$self->file;
                $record->{'parser_decisions_notes'} .= 'Setting UNDEFINED or ? class status to G based on black or undefined class note color.  ';
            }elsif($fgcolor =~ /ff/){
                $record->{'class_status'}='B';
                $record->{'parser_decisions_notes'} .= "Setting UNDEFINED or ? class status to B based on RED ($fgcolor) class note color.  ";
            }else{
                carp 'color of entry unhelpful', $fgcolor;
                $record->{'parser_decisions_notes'} .= "Color $fgcolor for class note color not yet related to a status.  ";

            }

        }elsif( (!$record->{'weight_status'} || $record->{'weight_status'} eq '?') &&
                $record->{'weight_notes'} ){
            # have a weight note, but no weight status
            # try using the color of the note
            my $cl = $sheet->{'cell'}->[$header->{'weight_notes'}][$row];
            my $attr = $sheet->{'attr'}->[$header->{'weight_notes'}][$row];
            my $fgcolor = $attr->{'fgcolor'};
            # carp Dumper [$record,$cl,$attr,$fgcolor];
            if(! defined $fgcolor && $record->{'weight_notes'} ){
                $record->{'weight_status'}='G';
                carp 'fgcolor of note is undefined but the note exists; assuming good weight status for row ',$row,' file ',$self->file;
                $record->{'parser_decisions_notes'} .= 'Setting UNDEFINED or ? weight status to G based on black or undefined weight note color.  ';

            }elsif($fgcolor =~ /^#ff/){
                $record->{'weight_status'}='B';
                $record->{'parser_decisions_notes'} .= "Setting UNDEFINED or ? weight status to B based on RED ($fgcolor) weight note color.  ";
            }else{
                carp 'color of entry unhelpful', $fgcolor;
                $record->{'parser_decisions_notes'} .= "Color $fgcolor for weight note color not yet related to a status.  ";
            }
        }
    }
    ## check again, inserting "undefined" to flag the need for manual checking in DB

    if ( (!$record->{'class_status'}  || $record->{'class_status'} eq '?') &&
         $self->write_undefined ) {
        $record->{'class_status'} = 'UNDEFINED';
        $record->{'parser_decisions_notes'} .= 'Forcing UNDEFINED on blank class status.  ';
        # if ( $record->{'class_notes'} ){
        #     carp Dumper $record;
        #     carp 'Inconsistent data.  Check '
        # }

    }
    if((!$record->{'weight_status'} || $record->{'weight_status'} eq '?')
        && $self->write_undefined ) {
        $record->{'weight_status'} = 'UNDEFINED';
        $record->{'parser_decisions_notes'} .= 'Forcing UNDEFINED on blank weight status.  ';
        # if ( $record->{'weight_notes'} ){
        #     carp Dumper $record;
        #     carp 'Inconsistent data.  Check '
        # }
    }
    if ($record->{'class_status'} eq 'UNDEFINED' ||
        $record->{'weight_status'} eq 'UNDEFINED'){
        carp 'Setting at least one status to undefined.  Needs check: ',$self->file, Dumper $record;
    }
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
