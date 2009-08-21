#!/usr/bin/env perl

use strict;
use warnings;

use lib '../../lib';

use Test::More qw{no_plan};
use Test::Output;

use Gwybodaeth::Parsers::CSV;
use Gwybodaeth::Parsers::N3;

BEGIN { use_ok ( 'Gwybodaeth::Write::WriteFromCSV' ) };

my $csv_write = new_ok( 'Gwybodaeth::Write::WriteFromCSV' ); 

my $csv_parse = Gwybodaeth::Parsers::CSV->new();
my $map_parse = Gwybodaeth::Parsers::N3->new();

my @data;
my @map;

# Nested function test
@data = ( 'name', 'John' );

@map = ( '[] a foaf:Person ;',
          'foaf:office',
          '     [ a foaf:Place ;',
          '         foaf:addy "Ex:$1"',
          '     ] .' );

my $str = <<'EOF'
<?xml version="1.0"?>
<rdf:RDF>
<foaf:Person>
<foaf:office>
<foaf:Place>
<foaf:addy>John</foaf:addy>
</foaf:Place>
</foaf:office>
</foaf:Person>
</rdf:RDF>
EOF
;

sub write_test_1 {
    return $csv_write->write_rdf($map_parse->parse(@map), 
                                 $csv_parse->parse(@data));
}

stdout_is(\&write_test_1, $str, 'nested function' );

@data = @map = undef;

# @If grammar test
@data = ('name,sex', 'John,male', 'Sarah,female');

@map = ( "[] a <Ex:foo+\@If(\$2='male';'Man';'Woman')> ;",
         'foaf:name "Ex:$1" .' );

$str = <<'EOF'
<?xml version="1.0"?>
<rdf:RDF>
<foo:Man>
<foaf:name>John</foaf:name>
</foo:Man>
<foo:Woman>
<foaf:name>Sarah</foaf:name>
</foo:Woman>
</rdf:RDF>
EOF
;

$csv_write = $map_parse = $csv_parse = undef;
$csv_write = Gwybodaeth::Write::WriteFromCSV->new();
$map_parse = Gwybodaeth::Parsers::N3->new();
$csv_parse = Gwybodaeth::Parsers::CSV->new();


sub write_test_2 {
    return $csv_write->write_rdf($map_parse->parse(@map), 
                                 $csv_parse->parse(@data));
}

stdout_is(\&write_test_2, $str, '@If grammar');

# ^^ grammar test

@data = ( 'name,num', 'John,20391' );

@map = (  "[] a foaf:Person ;",
          'foaf:name "Ex:$1^^string" ;',
          'foo:id "Ex:$2^^int" .',
       );

$str = <<'EOF'
<?xml version="1.0"?>
<rdf:RDF>
<foaf:Person>
<foaf:name rdf:datatype="http://www.w3.org/TR/xmlschema-2/#string">John</foaf:name>
<foo:id rdf:datatype="http://www.w3.org/TR/xmlschema-2/#int">20391</foo:id>
</foaf:Person>
</rdf:RDF>
EOF
;

$csv_write = $map_parse = $csv_parse = undef;
$csv_write = Gwybodaeth::Write::WriteFromCSV->new();
$map_parse = Gwybodaeth::Parsers::N3->new();
$csv_parse = Gwybodaeth::Parsers::CSV->new();

sub write_test_3 {
    return $csv_write->write_rdf($map_parse->parse(@map),
                                 $csv_parse->parse(@data));
}

stdout_is(\&write_test_3, $str, '^^ grammar');

# @lang test

@data = ( 'country,capital', 'Wales,Caerdydd');

@map  = ( '[] a foo:country ;',
          'foo:name "Ex:$1@en" ;',
          'foo:capital "Ex:$2@cy" .',
        );

$str = <<'EOF'
<?xml version="1.0"?>
<rdf:RDF>
<foo:country>
<foo:name xml:lang="en">Wales</foo:name>
<foo:capital xml:lang="cy">Caerdydd</foo:capital>
</foo:country>
</rdf:RDF>
EOF
;

$csv_write = $map_parse = $csv_parse = undef;
$csv_write = Gwybodaeth::Write::WriteFromCSV->new();
$map_parse = Gwybodaeth::Parsers::N3->new();
$csv_parse = Gwybodaeth::Parsers::CSV->new();

sub write_test_4 {
    return $csv_write->write_rdf($map_parse->parse(@map),
                                 $csv_parse->parse(@data));
}

stdout_is(\&write_test_4, $str, '@lang grammar');
