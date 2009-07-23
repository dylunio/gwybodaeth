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
    for my $child ($data->root->children) {
        $self->_write_triples($child, $triples);
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
    }

    push @{ $texts }, "$field";

    # Allow for a bareword field;
    return $texts;
}

# This is subclassed from Write.pm
sub _write_triples {
    my($self, $row, $triples) = @_;
    
    my $esc = Escape->new();

    for my $triple_key ( keys %{ $triples } ) {
        print "<".$self->_if_parse($triple_key,$row).">\n";
        my @verbs = @{ $triples->{$triple_key}{'predicate'} };
        for my $indx (0..$#verbs ) {
            my $objects = $self->_get_object($row,
                                             $triples->{$triple_key}{'obj'}[$indx]);

            # Some times _get_object may not return an array, so we should skip
            # any output which isn't an array.
            # TODO Find out why this is so.
            next unless (ref($objects) eq 'ARRAY');

            for my $object (@{ $objects }) 
            {
                print "<".$self->_if_parse($verbs[$indx],$row).">";
                print $esc->escape($object);
                print "</".$self->_if_parse($verbs[$indx],$row) .">\n";
            }
        }
        print "</".$self->_if_parse($triple_key,$row).">\n";
    }
}
1;
