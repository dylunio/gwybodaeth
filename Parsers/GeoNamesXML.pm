#!/usr/bin/env perl

use warnings;
use strict;

package GeoNamesXML;

use Carp qw{croak};
use XML::Twig;

# Inherit from XML class
use base qw( XML );

my %types;

sub parse {
    my($self, @data) = @_;
   
    ref($self) or croak "instance variable expected";

    my $xml = XML::Twig->new();

    my $string;
    for my $line (@data) {
        $string .= $line;
    }

    if($xml->safe_parse($string)) {
        return $xml;
    }

    # if we've reached here something has gone wrong, return a fail
    return 0;
}
1;
