#!/usr/bin/env perl

use strict;
use warnings;

use Test::More qw{no_plan};
use Test::Output;

use Gwybodaeth::Parsers::N3;
use Gwybodaeth::Parsers::GeoNamesXML;

BEGIN { use_ok( 'Gwybodaeth::Write::WriteFromUsgsXML' ); }

my $usgs = new_ok( 'Gwybodaeth::Write::WriteFromUsgsXML' );

my $xml_parse = Gwybodaeth::Parsers::GeoNamesXML->new();
my $map_parse = Gwybodaeth::Parsers::N3->new();

my $data_str = <<'EOF';
<feed>
<entry><title>Title</title></entry>
</feed>
EOF

my $map_str = <<'EOF';
@prefix rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix eqd:    <http://example.com/earth_quake_data#> .
@prefix :       <#> .

[]  a rdf:Description ;
    eqd:title "Ex:$title^^string" .
EOF

my $expected = <<'EOF';
<?xml version="1.0"?>
<rdf:RDF xmlns:eqd="http://example.com/earth_quake_data#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description>
<eqd:title rdf:datatype="http://www.w3.org/TR/xmlschema-2/#string">Title</eqd:title>
</rdf:Description>
</rdf:RDF>
EOF

my @map = split /\n/x, $map_str;
my @data = split /\n/x, $data_str;

sub write_test_1 {
    return $usgs->write_rdf($map_parse->parse(@map),$xml_parse->parse(@data));
}

stdout_is(\&write_test_1, $expected, 'simple feed');
