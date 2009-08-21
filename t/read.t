#!/usr/bin/env perl

use strict;

use lib '../lib';

use Test::More qw(no_plan);

BEGIN { use_ok( 'Gwybodaeth::Read' ); }

my $reader = new_ok( 'Gwybodaeth::Read' );

# Check file reading
ok( $reader->get_file_data('t/read.t') > 0, "reads file data");

# Check url reading
ok( $reader->get_url_data('http://www.google.co.uk') == 1,  "reads url data");

# Check if it resturns an array
isa_ok( $reader->get_input_data(), 'ARRAY');

# Check invalid url handling
ok( $reader->get_url_data('foo.bar.cy') == 0, "handles invalid url");

# Check invalid file handling
ok( $reader->get_file_data('./Foo.bar') == 0, "handles invalid file");
