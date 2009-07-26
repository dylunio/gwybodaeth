#!/usr/bin/env perl

use lib '/home/imp25/urop/perl/gwybodaeth/';

use Test::More qw(no_plan);

BEGIN { use_ok( 'Read' ); }

my $reader = new_ok( 'Read' );

# Check file reading
ok( $reader->get_file_data('./Read.t') > 0, "reads file data");

# Check url reading
ok( $reader->get_url_data('http://www.google.co.uk') > 0,  "reads url data");

# Check if it resturns an array
isa_ok( $reader->get_input_data(), 'ARRAY')
