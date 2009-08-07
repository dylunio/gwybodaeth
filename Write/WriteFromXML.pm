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

    $self->_write_meta_data();
    for my $child ($data->root->children) {
        $self->_write_triples($child, $triple_data);
    }

    print "</rdf:RDF>\n";

    return 1;
}

sub _write_triples {
    my($self, $row, $triple_data) = @_;

    my($triples, $functions) = @{ $triple_data };

    $self->_really_write_triples($row, $triples);

    for my $key (%{ $functions }) {
        $self->_really_write_triples($row, $functions->{$key},$key);
    }
    return 1;
}

# This is a subclass from Write.pm
sub _cat_field {
    my $self = shift;
    my $data = shift;
    my $field = shift;
    $field =~ s/Ex://;

    my $string = "";
    my $texts = [];

    my @values = split /\+/, $field;

    for my $val (@values) {
        # Extract ${tag} variables from the data
        if ($val =~ m/\$(\w+\/?\w*)/) {
            push @{ $texts }, $self->_get_field($data,$1);
        }
        # Put a space; 
        elsif ($val =~ m/\'\s*\'/) {
            push @{ $texts }, " ";
        } 
        # Print a literal
        else {
            push @{ $texts }, $val;
        }
    }
    return join '', @{ $texts };
}

sub _split_field {
    my($self, $data, $field) = @_;

    my @strings;
    
    if ($field =~ m/\@Split\(Ex:\$(\w+\/?\w*),"(.)"\)/) {
        my $keyword = $1;
        my $delimeter = $2;
        for my $node ($data->findnodes("$keyword")) {
            if (defined($node->text())) {
                push @strings, split /$delimeter/,  $node->text();
            }
        }
        return \@strings;
    }

    return $field;
}

sub _get_field {
    my($self, $data, $keyword) = @_;

    my $texts = [];

    for my $node ($data->findnodes("$keyword")) {
        if (defined($node->text())) {
            push @{ $texts }, $node->text();
        }
    }
    return $texts;
}
1;
