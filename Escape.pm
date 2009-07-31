#!/usr/bin/env perl

use warnings;
use strict;

package Escape;

use Carp qw(croak);
{

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub escape {
    ref(my $self = shift) or croak "instance variable needed";
    my $string = shift;

    # escape '&' chars.
    $string =~ s/\s&\s/ &amp; /g;
    chomp($string);

    return $string;
}

}
1;
