#!/usr/bin/env perl

package Gwybodaeth;

our $VERSION = "0.1";

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

head1 NAME

Gwybodaeth - a set of classes and scripts to RDF-ize data


