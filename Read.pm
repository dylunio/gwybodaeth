#!/usr/bin/env perl

use warnings;
use strict;

package Read;

# Methods for reading in data from either a file or URL;

use HTTP::Lite;

my @input_data;
my @input_map;

sub new {
    my $class = shift;
    my $self = { };
    bless \$self, $class;
}

# Open a file and store its contents
# Returns length of data
sub get_file {
    my($self, $file) = @_;

    open my $fh, q{<}, $file or die "Couldn't open $file: $!";
    my @data;

    @data = <$fh>;

    close $fh;

    return @data;
}

# Open a URL download the body and store it
# Returns length of URL
sub get_url {
    my($self, $url) = @_;

    # Make sure we have a '/' at the end of the URL.
    # Without this HTTP::Lite doesn't work
    unless ($url =~ m|/$|) {
        $url =~ s|(\S+)$|$1/|;
    }
   
    my $http = new HTTP::Lite;
    my $req = $http->request("$url")
        or die "Unable to get document: $!";

    return split /\n/, $http->body();
}

sub get_file_data {
    my $self = shift;
    my $file = shift;

    @input_data = $self->get_file($file);

    return int @input_data;
}

sub get_url_data {
    my $self = shift;
    my $url = shift;

    @input_data = $self->get_url($url);

    return int @input_data;
}

sub get_file_map {
    my $self = shift;
    my $file = shift;

    @input_map = $self->get_file($file);
    
    return int @input_map;
}

sub get_url_map {
    my $self = shift;
    my $url = shift;

    @input_map = $self->get_url($url);

    return int @input_map;
}

# Data return methods:
sub get_input_data {
    my $obj = shift;
    return @input_data;
}

sub get_input_map {
    my $self = shift;
    return @input_map;
}
1; 
# end package Read
