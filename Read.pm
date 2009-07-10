#!/usr/bin/env perl

use warnings;
use strict;

package Read;

# Methods for reading in data from either a file or URL;
use LWP::UserAgent;
use HTTP::Request;

my @input_data;
my @input_map;

sub new {
    my $class = shift;
    my $self = { };
    my @data;
    $self->{Data} = \@data;
    bless $self, $class;
    return $self;
}

# Open a file and store its contents
# Returns length of file data
sub get_file_data {
    my($self, $file) = @_;

    open my $fh, q{<}, $file or die "Couldn't open $file: $!";

    @{ $self->{Data} }= (<$fh>);

    close $fh;
    
#    use YAML;
#
#    print Dump($self->{Data});

    return int $self->{Data};
}

# Open a URL download the body and store it
# Returns length of URL data
sub get_url_data {
    my($self, $url) = @_;

    my $browser = LWP::UserAgent->new(); 
    my $req = HTTP::Request->new(GET => $url);
    my $res = $browser->request($req);

    # split content on line endings - should work with the different formats
    @{ $self->{Data} } = split /\012\015?|\015\012?/, $res->content; 

    return int $self->{Data};
}

# Data return methods:
sub get_input_data {
    my $self = shift;
    return @{ $self->{Data} };
}

1; 
# end package Read
