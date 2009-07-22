#!/usr/bin/env perl

use warnings;
use strict;

package WriteFromXML;

use base qw(Write);

use Carp qw(croak);

sub write_rdf {
    ref(my $self = shift) or croak "instance variable needed";
    my $triples = shift;
    my $data = shift; 

    $self->_write_meta_data();

    #for my $row (@{ $data }) {
        $self->_write_triples($data, $triples);
    #}
    print "</rdf:RDF>\n";

    return 1;
}

# This is a subclass from Write.pm
sub _extract_field {
    my $self = shift;
    my $data = shift;
    my $field = shift;

    # The object is a specific field
    if ($field =~ m/^\"Ex:\$(\w+)\"$/) {
        my $keyword = $1;
        for my $i (0..$#{ $data }) {
            if (@{ $data }[$i] =~ /^$keyword$/) {
                return @{ $data }[$i+1];
            }
        }
        return $data;
    }

    # Allow for a bareword field;
    return "$field";
}
1;
