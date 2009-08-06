#!/usr/bin/env perl

use strict;

use lib '..';
use lib '../Write';
use lib '../Parsers';

use Test::More qw{no_plan};
use Test::Output;

use N3;
use GeoNamesXML;

BEGIN { use_ok( 'WriteFromXML' ); }

my $xml_write = new_ok( 'WriteFromXML' );

my $xml_parse = GeoNamesXML->new();
my $map_parse = N3->new();

# Test which includes functions and nests

my $data_str = <<EOF
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
;

my $map_str = <<EOF
\@prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
\@prefix geo:     <http://www.w3.org/2003/01/geo/wgs84_pos# > .
\@prefix foo:     <http://foo.org/foo#> .
\@prefix :        <#> .

[]  a   rdf:Description ;
    foo:captial "Ex:\$capital" ;
    foo:country <Ex:\$countryName> ;       
    foo:lat "Ex:\$lat" ;
    foo:bar "Ex:\$foo/bar" ;
    foo:lng "Ex:\$lng" .

<Ex:\$countryName>
    a rdf:Description ;
    foo:country "Ex:\$countryName" ;
    foo:arian "Ex:\$currencyCode" .
EOF
;

my $expected = <<EOF
<?xml version="1.0"?>
<rdf:RDF
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:foo="http://foo.org/foo#"
>
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
;

my @data = split /\n/, $data_str;

my @map = split /\n/, $map_str;

sub write_test {
    $xml_write->write_rdf($map_parse->parse(@map), $xml_parse->parse(@data));
}

stdout_is(\&write_test, $expected, 'function and nesting');
