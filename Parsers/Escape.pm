#!/usr/bin/env perl

use warnings;
use strict;

package Escape;
{

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub escape {
    my $self = shift;
    my $string = shift;

    # escape '&' chars.
    $string =~ s/\s&\s/ &amp; /g;

    return $string;
}

}
1;
