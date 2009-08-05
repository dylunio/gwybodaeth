#!/usr/bin/env perl

use strict;

use lib '..';
use lib '../Parsers';

use Test::More qw{no_plan};

BEGIN { use_ok( 'XML' ); }

my $xml = new_ok( 'XML' );
