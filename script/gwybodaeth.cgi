#!/usr/bin/env perl

use warnings;
use strict;
use lib '../lib';
use lib 'lib';

use CGI::Carp qw(fatalsToBrowser set_message);
use CGI;
use XML::Twig;

# gwybodaeth specific modules
use Gwybodaeth::Parsers::N3;
use Gwybodaeth::Read;

BEGIN {
    sub handle_errors {
        my $msg = shift;
        if ($msg =~ m!Empty [map|source]!) { $msg =~ s/at\s.+$//g; }
        my $q = new CGI;
        print $q->start_html( "Problem" ),
              $q->h1( "Problem" ),
              $q->p( "Sorry, the following problem has occurred: " ),
              $q->p( "$msg" ),
              $q->end_html;
    }
    set_message(\&handle_errors);
}

# Load configuration
my $conf_file = '/etc/gwybodaeth/gwybodaeth.conf';
-e $conf_file or croak "you need a configuration file $conf_file: $!";

my $twig = XML::Twig->new();
$twig->parsefile($conf_file);

my @converters = $twig->root->children( 'converter' );
my %convert = ();

for my $conv (@converters) {
    my $name = $conv->first_child_text('name');
    my $parser = $conv->first_child_text('parser');
    my $writer = $conv->first_child_text('writer');
    
    $convert{$name} = { parser => $parser, writer => $writer };
}

my $cgi = CGI->new();

my $data = $cgi->param('src');
my $map = $cgi->param('map');
my $in_type = $cgi->param('in');

my @undef;
for ('src', 'map', 'in') {
    unless ( defined( $cgi->param($_) ) ) {
        push @undef, $_;
    }
}
if (@undef) {
    @undef = map { "<li>$_</li>" }  @undef;
    my $err = join("\n", @undef);
    print $cgi->header('text/html'),
          $cgi->start_html('Problems'),
          $cgi->h3('Undefined Parameters'),
          ("The following parameters need to be defined in the URL:
            <br />\n<ul>\n$err\n</ul>"),
          $cgi->end_html;
    exit 0;
}


my $input = Gwybodaeth::Read->new();

my $len;
if (-f $data) {
    $len = $input->get_file_data($data);
} else {
    $len = $input->get_url_data($data);
}

croak "Empty source: $data" if ($len < 1);

my $mapping = Gwybodaeth::Read->new();

if (-f $map) {
    $len = $mapping->get_file_data($map);
} else {
    $len = $mapping->get_url_data($map);
}

croak "Empty map: $map" if ($len < 1);

my @data = @{$mapping->get_input_data};

my $map_parser = Gwybodaeth::Parsers::N3->new();

my $map_triples = $map_parser->parse(@data);

my $parser;
my $writer;
my $write_mod;
my $parse_mod;
if (defined($convert{$in_type})) {
    $write_mod = $convert{$in_type}->{'writer'};
    $parse_mod = $convert{$in_type}->{'parser'};
    eval {
        (my $wpkg = $write_mod) =~ s!::!/!g;
        (my $ppkg = $parse_mod) =~ s!::!/!g;
        require "$wpkg.pm";
        require "$ppkg.pm";
        import $parse_mod; 
        import $write_mod;
    };
    $parser = $parse_mod->new();
    $writer = $write_mod->new();
} else {
    croak "$in_type is not defined in the config file";
}
my $parsed_data_ref = $parser->parse(@{ $input->get_input_data });

print $cgi->header('Content-type: application/rdf+xml');

$writer->write_rdf($map_triples,$parsed_data_ref);