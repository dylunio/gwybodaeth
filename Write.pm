#!/usr/bin/env perl

use warnings;
use strict;

package Write;

sub new {
    my $class = shift;
    my $self = { };
    bless \$self, $class;
}

sub write_rdf {
    my $self = shift;
    my $triples = shift;
    my $data = shift; 

    use YAML;

    print Dump($triples);
    print Dump($data);

    for my $row (@$data) {
        for my $triple_key ( keys %{ $triples } ) {
            print "<$triple_key>\n";
            for my $verb_key ( @{ $triples->{$triple_key}{'predicates'} } ) {
                print "<$verb_key>";
                print $self->extract_field(@{$row}[1], $triples->{$triple_key}{'obj'}[1]);
                print "</$verb_key>\n";
            }
            print "</$triple_key>\n";
        }
    }
}

sub extract_field {
    my $self = shift;
    my $data = shift;
    my $field = shift;

    if ($field =~ m/ex:\$(\d+)/) {
        my $field_num = int ($1 -1); # we subtract 1 as arrays start at 0 not 1
        return @{$data}[$field_num];
    }
}
1;
