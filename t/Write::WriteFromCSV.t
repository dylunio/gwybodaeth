#!/usr/bin/env perl

use strict;

use lib '..';
use lib '../Write';
use lib '../Parsers';

use Test::More qw{no_plan};
use Test::Output;

use CSV;
use N3;

BEGIN { use_ok ( 'WriteFromCSV' ) };

my $csv_write = new_ok( 'WriteFromCSV' ); 

my $csv_parse = CSV->new();
my $map_parse = N3->new();

my @data;
my @map;

# Nested function test
@data = ( 'name', 'John' );

@map = ( '[] a foaf:Person ;',
          'foaf:office',
          '     [ a foaf:Place ;',
          '         foaf:addy "Ex:$1"',
          '     ] .' );

my $str = <<EOF
<?xml version="1.0"?>
<rdf:RDF
>
<foaf:Person>
<foaf:office><foaf:Place>
<foaf:addy>John</foaf:addy>
</foaf:Place>
</foaf:office>
</foaf:Person>
</rdf:RDF>
EOF
;

sub write_test {
    $csv_write->write_rdf($map_parse->parse(@map), 
                          $csv_parse->parse(@data));
}

stdout_is(\&write_test, $str, 'nested function' );