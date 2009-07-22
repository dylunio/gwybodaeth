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

    $self->_write_triples($data->root, $triples);

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
        return $data->child( $keyword )->first_child_text( $keyword );
    }

    # Allow for a bareword field;
    return "$field";
}
1;
