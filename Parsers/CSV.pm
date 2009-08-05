#!/usr/bin/env perl

use warnings;
use strict;

package CSV;

use Carp qw(croak);
use Text::CSV;

sub new {
    my $class = shift;
    my $self = { quote_char => '"',
                 sep_char => ',' };
    bless $self, $class;
    return $self;
}

sub parse {
    my($self, @data) = @_;

    ref($self) or croak "instance variable needed";

    my @rows;
    my $i;
    my $csv = Text::CSV->new( {binary => 1, 
                               quote_char => $self->{quote_char},
                               sep_char => $self->{sep_char} 
                            } );
    
    for my $row (@data) {
        if ($csv->parse($row)) {
            my @fields = $csv->fields();
            $rows[$i++] = \@fields;
        } else {
            croak "unable to parse row: " . $csv->error_input;
        }
    }

    return \@rows;
} 
1;
