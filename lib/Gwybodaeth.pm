#!/usr/bin/env perl

use strict;
use warnings;

package Gwybodaeth;

our $VERSION = "0.02";

require Gwybodaeth::Write;
require Gwybodaeth::Write::WriteFromCSV;
require Gwybodaeth::Write::WriteFromXML;

require Gwybodaeth::Parsers::CSV;
require Gwybodaeth::Parsers::GeoNamesXML;
require Gwybodaeth::Parsers::N3;
require Gwybodaeth::Parsers::XML;

require Gwybodaeth::Escape;
require Gwybodaeth::NamespaceManager;
require Gwybodaeth::Read;
require Gwybodaeth::Tokenize;
require Gwybodaeth::Triples;

__END__

=head1 NAME

Gwybodaeth - a set of classes and scripts to RDF-ize data

=head1 SYNOPSIS

    #This will load all the distributed Gwybodaeth modules:
    use Gwybodaeth;

    # Script inteface:
    gwybodaeth --src=data --map=map.N3 --in=input_data_type

=head1 DESCRIPTION

The gwybodaeth collection of classes and scripts are aimed to help in the
RDFizing of data. The modules provide an object orientated API and are
designed to be easily extended and customized.

Gwybodaeth's main features are:

=over 3

=item *

Ability to map data from an input into RDF.

=item *

Extendible so that more more input data types can be handled while using
gwybodaeth's mapping functionality.

=item *

Gwybodaeth can be used either as a command line script or as a CGI based web
service.

=back

=head1 CLASSES

The most important classes are in the C<Gwybodaeth::Parsers> and
C<Gwybodaeth::Write> namespaces. These are the classes which parse the input
format and write out the data in RDF according to the mapping.

=over 3

=item L<Gwybodaeth::Escape>

A class which provides escaping functionality for RDF/XML output.

=item L<Gwybodaeth::NamespaceManager>

A class which extracts and managed namespace information.

=item C<Gwybodaeth::Parsers::*>

Classes for parsing input data into data structures for use by the rest of
gwybodaeth based programs.

=item L<Gwybodaeth::Read>

A class for slurping data from either local files or over http.

=item L<Gwybodaeth::Tokenize>

A class for tokenizing data on white space.

=item L<Gwybodaeth::Triples>

A class which takes care of gwybodaeth's triples data structure.

=item L<Gwybodaeth::Write>

A class meant for subclassing to create bespoke map appliers for custom inputs.
It contains most of the map application logic.

=item C<Gwybodaeth::Write::*>

Classes subclassed from C<Gwybodaeth::Write> or eachother which offer map
application and writing to different input types.

=back

=head1 EXAMPLES

=head2 USAGE

Applying a local map to a publically available CSV source:

gwybodaeth --src=http://www.example.org/data.csv --map=my_data_map.N3 --in=csv

Applying a local map to XML data from GeoNames:

gwybodaeth --source=http://ws.geonames.org/countryInfo?country=GB
--map=my_geo_map.N3 --in=geonames

=head2 MAPS

Maps are written in a dialect of N3 (L<http://www.w3.org/DesignIssues/Notation3>). The maps generally correspond
to the maps in use by RDF123 (L<http://rdf123.umbc.edu/>).

=head3 CSV

This is an example of a simple mapping for a CSV file:

    @prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix :        <#> .

    [] a rdf:Description ;
       rdfs:seeAlso "Ex:$1" . 

For every row of the CSV file it will create a triple:

    rdf:Description => rdfs:seeAlso => Ex:$1

where Ex:$1 will be replaced by the content of the first column of the row.

=head3 XML

This is an example of a simple mapping for a XML file:

    @prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
    @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
    @prefix :        <#> .

    [] a rdf:Description ;
       rdfs:seeAlso "Ex:$entity" .

For every block of data in the XML file it will create a triple:

    rdf:description => rdfs:seeAlso => Ex:$entity

where Ex:$entity will be replaced by the content of the tag with the entity
$entity.

=head3 Syntax

Gwybodaeth supports the following syntax in the mapping files:

"Ex:$var"   The value of the data described by I<var> is placed here as the object.

<Ex:$var>   This is a function. On its own line it defines the following block as the contents of the function with rdf:ID or rdf:about. As an object it references the defined function with rdf:resource.

[ a ... ] . Define an inline function.

+           Allows for concatinanion within the field.

@Split(field,"delimiter")
            Splits up I<field> on the I<delimiter> so that one field can be RDFized into many predicate->object pairs.

@If(condition,true,false)
            Evaluates I<condition> and returns I<true> if the condition is
true, otherwise it returns I<false>.

=head1 AUTHORS

Iestyn Pryce, <imp25@cam.ac.uk>

=head1 ACKNOWLEDGEMENTS

I'd like to thank the Ensemble project (L<www.ensemble.ac.uk>) for funding me to work on this project in the summer of 2009.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Iestyn Pryce <imp25@cam.ac.uk>

This library is free software; you can redistribute it and/or modify it under
the terms of the BSD license.
