#!/usr/bin/env perl

use warnings;
use strict;

package CSV;

sub new {
    my $class = shift;
    my $self = { };
    bless \$self, $class;
}

sub parse {
    my $self = shift;
    my @data = @_;

    my @rows;
    my $i;
    
    for (@data) {
        my @fields = split ',', $_;
        $rows[$i++] = \@fields;
    }

    use YAML;

    #print Dump(@rows);

    return \@rows;
} 
1;
