#!/usr/bin/env perl

use warnings;
use strict;

package TranslatorLoader;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}
1;
