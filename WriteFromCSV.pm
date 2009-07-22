#!/usr/bin/env perl

use warnings;
use strict;

use lib ('.');

package WriteFromCSV;

use base qw(Write);

use Carp qw(croak);

sub write_rdf {
    ref(my $self = shift) or croak "instance variable needed";
    my $triples = shift;
    my $data = shift; 

    # This loop makes sure that we give the data
    # interpreter only the data we want and not 
    # any metadata.
    my @pure_data;
    for my $row (0..$#{ $data }) {
        if (@{$data}[$row]->[0] =~ /start\s+row/i) {
            my $start = int @{$data}[$row]->[1];
            for ($start..$#{ $data }) {
                push @pure_data, @{ $data }[$_];
            }
            last;
        }
    }       

    if (!@pure_data) { # Always make sure the first line is skipped
        for (1..$#{ $data }) {
            push @pure_data, @{ $data }[$_];
        }
    } 

    $self->_write_meta_data();

    for my $row (@pure_data) {
        $self->_write_triples($row, $triples);
    }
    print "</rdf:RDF>\n";

    return 1;
}
1;
