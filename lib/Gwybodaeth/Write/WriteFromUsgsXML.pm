#!/usr/bin/env perl

use warnings;
use strict;

package Gwybodaeth::Write::WriteFromUsgsXML;

=head1 NAME

Gwybodaeth::Write::WriteFromUsgsXML - Writes data into RDF/XML from USGS XML
feeds.

=head1 SYNOPSIS

    use Gwybodaeth::Write::WriteFromeUsgsXML;

    my $w = Gwybodaeth::Write::WriteFromUsgsXML;
    
    $w->write_rdf($map_data,$data);

=head1 DESCRIPTION

This module is subclassed from Gwybodaeth::Write::WriteFromXML and applies
mapping to USGS XML feed data.

=cut

use base qw(Gwybodaeth::Write::WriteFromXML);

use Carp qw(croak);

sub write_rdf {
    ref(my $self = shift) or croak "instance variable needed";
    my $triple_data = shift;
    my $data = shift;

    my $triples = $triple_data->[0]; 
    my $functions = $triple_data->[1];

    $self->_write_meta_data();
    for my $child ($data->root->children('entry')) {
        $self->_write_triples($child, $triple_data);
    }

    $self->_print2str("</rdf:RDF>\n");

    my $xml = $self->_structurize();

    $xml->print();

    return 1;
}
1;
__END__

=back

=head1 AUTHOR

Iestyn Pryce, <imp25@cam.ac.uk>