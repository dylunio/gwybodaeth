#!/usr/bin/env perl

use warnings;
use strict;

package WriteFromXML;

use base qw(Write);

use Carp qw(croak);

sub write_rdf {
    ref(my $self = shift) or croak "instance variable needed";
    my $triple_data = shift;
    my $data = shift;

    my $triples = $triple_data->[0]; 
    my $functions = $triple_data->[1];

    use YAML;
    #print Dump($functions);

    $self->_write_meta_data();
    for my $child ($data->root->children) {
        $self->_write_triples($child, $triple_data);
    }

    print "</rdf:RDF>\n";

    return 1;
}

# This is a subclass from Write.pm
sub _extract_field {
    my $self = shift;
    my $data = shift;
    my $field = shift;

    my $texts = [];

    # The object is a specific field
    if ($field =~ m/^\"Ex:\$(\w+\/?\w*)\"$/) {
        my $keyword = $1;
        for my $node ($data->findnodes("$keyword")) {
            if (defined($node->text())) {
                push @{ $texts }, $node->text();
            }
        }
        return $texts;
    }
    # The object is a concatination of fields 
    elsif ($field =~ m/^\"Ex:.*\+/) {
        return $self->_cat_field($data, $field);
    } elsif ($field =~ m/^\<Ex:\$(\w\/?\w*)\>$/) {
        my $keyword = $1;
        for my $node ($data->findnodes("$keyword")) {
            if (defined($node->text())) {
                push @{ $texts }, $node->text();
            }
        }
        return $texts;
    }

    # Allow for a bareword field;
    return $field;
}
1;
