#!/usr/bin/env perl

use strict;
use warnings;

use lib '../../lib';

use Test::More qw{no_plan};
use Test::Output;

use Gwybodaeth::Parsers::N3;
use Gwybodaeth::Parsers::GeoNamesXML;

BEGIN { use_ok( 'Gwybodaeth::Write::WriteFromXML' ); }

my $xml_write = new_ok( 'Gwybodaeth::Write::WriteFromXML' );

my $xml_parse = Gwybodaeth::Parsers::GeoNamesXML->new();
my $map_parse = Gwybodaeth::Parsers::N3->new();

# Test which includes functions and nests

my $data_str = <<'EOF';
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<geonames>
<country>
<countryCode>GB</countryCode>
<foo>
<bar>BAR!!</bar>
<bar>Baz!!</bar>
</foo>
<countryName>Prydain Fawr</countryName>
<isoNumeric>826</isoNumeric>
<isoAlpha3>GBR</isoAlpha3>
<fipsCode>UK</fipsCode>
<continent>EU</continent>
<capital>Llundain</capital>
<areaInSqKm>244820.0</areaInSqKm>
<population>60943000</population>
<geonameId>2635167</geonameId>
</country>
</geonames>
EOF

my $map_str = <<'EOF';
@prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix geo:     <http://www.w3.org/2003/01/geo/wgs84_pos# > .
@prefix foo:     <http://foo.org/foo#> .
@prefix :        <#> .

@base <http://www.thisdoc.com> .

[]  a   rdf:Description ;
    foo:captial "Ex:$capital" ;
    foo:country <Ex:$countryName> ;       
    foo:lat "Ex:$lat" ;
    foo:bar "Ex:$foo/bar" ;
    foo:lng "Ex:$lng" .

<Ex:$countryName>
    a rdf:Description ;
    foo:country "Ex:$countryName" ;
    foo:arian "Ex:$currencyCode" .
EOF

my $expected = <<'EOF';
<?xml version="1.0"?>
<rdf:RDF xml:base="http://www.thisdoc.com" xmlns:foo="http://foo.org/foo#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<rdf:Description>
<foo:captial>Llundain</foo:captial>
<foo:country rdf:resource="#Prydain Fawr"/>
<foo:bar>BAR!!</foo:bar>
<foo:bar>Baz!!</foo:bar>
</rdf:Description>
<rdf:Description rdf:about="#Prydain Fawr">
<foo:country>Prydain Fawr</foo:country>
</rdf:Description>
</rdf:RDF>
EOF

my @data = split /\n/x, $data_str;
my @map = split /\n/x, $map_str;

sub write_test {
    return $xml_write->write_rdf($map_parse->parse(@map), $xml_parse->parse(@data));
}

stdout_is(\&write_test, $expected, 'function and nesting');

# ^^ grammar test

@data = ( '<geonames>',
          '<Country>',
          '<name>England</name>',
          '</Country>',
          '</geonames>',
        );

@map = ('[] a foo:country ;',
        'foo:name "Ex:$name^^string" .'
       );

$expected = <<'EOF';
<?xml version="1.0"?>
<rdf:RDF>
<foo:country>
<foo:name rdf:datatype="http://www.w3.org/TR/xmlschema-2/#string">England</foo:name>
</foo:country>
</rdf:RDF>
EOF

$map_parse = $xml_parse = $xml_write = undef;
$xml_write = Gwybodaeth::Write::WriteFromXML->new();
$xml_parse = Gwybodaeth::Parsers::GeoNamesXML->new();
$map_parse = Gwybodaeth::Parsers::N3->new();

sub write_test_2 {
   return $xml_write->write_rdf($map_parse->parse(@map), $xml_parse->parse(@data));
}

stdout_is(\&write_test_2, $expected, '^^ grammar');

# @lang test

@map = ('[] a foo:country ;',
        'foo:name "Ex:$name@en" .'
       );

$expected = <<'EOF';
<?xml version="1.0"?>
<rdf:RDF>
<foo:country>
<foo:name xml:lang="en">England</foo:name>
</foo:country>
</rdf:RDF>
EOF

$map_parse = $xml_parse = $xml_write = undef;
$xml_write = Gwybodaeth::Write::WriteFromXML->new();
$xml_parse = Gwybodaeth::Parsers::GeoNamesXML->new();
$map_parse = Gwybodaeth::Parsers::N3->new();

sub write_test_3 {
    return $xml_write->write_rdf($map_parse->parse(@map), $xml_parse->parse(@data));
}

stdout_is(\&write_test_3, $expected, '@lang grammar');
