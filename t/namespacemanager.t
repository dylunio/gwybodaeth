#!/usr/bin/env perl

use strict;

use lib '../lib';

use Test::More qw{no_plan};

BEGIN { use_ok( 'Gwybodaeth::NamespaceManager' ); }

my $nm = new_ok( 'Gwybodaeth::NamespaceManager' );
my $data;
my $struct;

# set namespace
$data = [ '@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .' ];
$struct = { 'rdf:' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' };

is_deeply($nm->map_namespace($data), $struct, 'simple @prefix');

# get namespace
is_deeply($nm->get_namespace_hash(), $struct, 'get namespace');
