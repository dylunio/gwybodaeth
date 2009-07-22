#!/usr/bin/env perl

use warnings;
use strict;

package XML;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub parse {
    my $self = shift;

    return 1;
}
1;
