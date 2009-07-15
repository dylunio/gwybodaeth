#!/usr/bin/env perl

use warnings;
use strict;

package CSV;

use Carp qw(croak);

sub new {
    my $class = shift;
    my $self = { };
    bless $self, $class;
    return $self;
}

sub parse {
    my($self, @data) = @_;

    ref($self) or croak "instance variable needed";

    my @rows;
    my $i;
    
    for (@data) {
        my @fields = split ',', $_;
        $rows[$i++] = \@fields;
    }

    return \@rows;
} 
1;
