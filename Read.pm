#!/usr/bin/env perl

use warnings;
use strict;


package Read;

# Methods for reading in data from either a file or URL;
use LWP::UserAgent;
use HTTP::Request;
use Carp qw(croak);

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
    ref(my $self = shift) or croak "instance variable needed";
    my $file = shift;

    open my $fh, q{<}, $file or die "Couldn't open $file: $!";

    @{ $self->{Data} }= (<$fh>);

    close $fh;
    
    return int $self->{Data};
}

# Open a URL download the body and store it
# Returns length of URL data
sub get_url_data {
    my($self, $url) = @_;

    ref($self) or croak "instance variable needed";

    my $browser = LWP::UserAgent->new(); 
    my $req = HTTP::Request->new(GET => $url);
    my $res = $browser->request($req);

    # split content on line endings - should work with the different formats
    @{ $self->{Data} } = split /\012\015?|\015\012?/, $res->content; 

    return int $self->{Data};
}

# Data return methods:
sub get_input_data {
    ref(my $self = shift) or croak "instance variable needed";
    return @{ $self->{Data} };
}

1; 
# end package Read
