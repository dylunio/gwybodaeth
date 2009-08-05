#!/usr/bin/env perl

use strict;

use lib '..';
use lib '../Write';

use Test::More qw{no_plan};

# Write.pm is meant to be subclassed.
# The only public method is new().

BEGIN { use_ok( 'Write' ); }

my $write = new_ok( 'Write' );
