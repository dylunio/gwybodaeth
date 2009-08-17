#!/usr/bin/env perl

use warnings;
use strict;


package Gwybodaeth::Read;

# Methods for reading in data from either a file or URL;
use LWP::UserAgent;
use HTTP::Request;
use Carp qw(croak);

=head1 NAME

Read - input data reader class for gwybodaeth

=head1 SYNOPSIS

    use Read;

    my $r = Read->new();

    $r->get_file_data("/home/foo/bar.csv");
    $r->get_url_data("www.example.org/bar.csv");

    $r->get_input_data();


=head1 DESCRIPTION

This module imports data from the URIs given to it.

=over

=item new()

Create a new instance of Read.

$r = Read->new();

=cut

sub new {
    my $class = shift;
    my $self = {'Data' => [] };
    bless $self, $class;
    return $self;
}

=item get_file_data($filename)

This function gets data from $filename.

=cut

# Open a file and store its contents
# Returns length of file data
sub get_file_data {
    ref(my $self = shift) or croak "instance variable needed";
    my $file = shift;

    # Return if file doesn't exist
    unless ( -e $file ) { return 0 };

    open my $fh, q{<}, $file or die "Couldn't open $file: $!";

    @{ $self->{Data} }= (<$fh>);

    close $fh;
    
    return int $self->{Data};
}

=item get_url_data($url)

This function gets data from $url.

=cut

# Open a URL download the body and store it
# Returns true if successful
sub get_url_data {
    my($self, $url) = @_;

    ref($self) or croak "instance variable needed";

    my $browser = LWP::UserAgent->new(); 
    my $req = HTTP::Request->new(GET => $url);
    my $res = $browser->get($url);

    if ($res->is_success) {
        @{ $self->{Data} } = split /\012\015?|\015\012?/, $res->decoded_content;
    } 

    return $res->is_success;
}

=item get_input_data()

This function returns an array contiaining the ingested data.

=cut

# Data return methods:
sub get_input_data {
    ref(my $self = shift) or croak "instance variable needed";
    return $self->{Data};
}

1; 
__END__

=back

=head1 AUTHOR

Iestyn Pryce, <imp25@cam.ac.uk>
