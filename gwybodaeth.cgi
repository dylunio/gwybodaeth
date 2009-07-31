#!/usr/bin/env perl

use warnings;
use strict;

use lib '.';
use lib 'Parsers/';
use lib 'Write/';

use Carp qw(croak);
use CGI;

# gwybodaeth specific modules
use Read;

# Load possible writers
opendir(my $dh, 'Write/') or croak "cannot open Write directory: $!";
for my $file (readdir($dh)) {
    if ($file =~ m/^(Write.+)\.pm$/) {
        eval "use $1";
    }
}
closedir($dh);

# Load possible parsers
opendir($dh, 'Parsers/') or croak "cannot open Parsers director: $!";
for my $file (readdir($dh)) {
    if ($file =~ m/^(.+)\.pm$/) {
        eval "use $1";
    }
}
closedir($dh);

my $cgi = CGI->new();
print $cgi->header('Content-type: application/rdf+xml');

my $data = $cgi->param('src');
my $map = $cgi->param('map');
my $in_type = $cgi->param('in');


my $input = Read->new();

my $len;
if (-f $data) {
    $len = $input->get_file_data($data);
} else {
    $len = $input->get_url_data($data);
}

die "Empty file." if ($len < 1);

my $mapping = Read->new();

if (-f $map) {
    $len = $mapping->get_file_data($map);
} else {
    $len = $mapping->get_url_data($map);
}

die "Empty site." if ($len < 1);

my @data = @{$mapping->get_input_data};

my $map_parser = N3->new();

my $map_triples = $map_parser->parse(@data);

my $parser;
my $writer;
if ($in_type =~ m/^csv$/i) {
    $parser = CSV->new();
    $writer = WriteFromCSV->new();
} elsif ($in_type =~ m/geonames/i) {
    $parser = GeoNamesXML->new();
    $writer = WriteFromXML->new();
}

my $parsed_data_ref = $parser->parse(@{ $input->get_input_data });

$writer->write_rdf($map_triples,$parsed_data_ref);
