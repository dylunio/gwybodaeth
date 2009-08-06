#!/usr/bin/env perl

use strict;

use lib '..';
use lib '../Parsers';

use XML::Twig;
use Test::More qw{no_plan};

my $twig = XML::Twig->new();

BEGIN{ use_ok( 'GeoNamesXML' ); }

my $gnx = new_ok( 'GeoNamesXML' );

my $xml = [ '<root>',
            '<child1>foo</child1>',
            '<child2>bar</child2>',
            '</root>'
          ];

$twig = $gnx->parse(@{ $xml });

ok( eval{ $twig->isa('XML::Twig') }, 'returns twig' );

# Garbage input test
my $cruft = [ 'this is some', '<a href="cruft">', 'to trip',
              'up the', 'PaRsEr!!' ];

$twig = $gnx->parse(@{ $cruft });

is( $twig, 0, 'returns 0 on cruft' );

