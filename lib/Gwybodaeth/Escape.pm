#!/usr/bin/env perl

use strict;
use warnings;

package Gwybodaeth::Escape;

=head1 NAME

Escape - Escape characters with XML escapes

=head1 SYNOPSIS

    use Escape;

    my $e = Escape->new();

    $e->escape($string);

=head1 DESCRIPTION

This module escapes strings in preperation for putting in XML.

=over

=cut

use Carp qw(croak);
{

=item new()
    Returns an instance of the Escape class.

=cut

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

=item escape()
    Escapes strings with XML escapes.

=cut

sub escape {
    ref(my $self = shift) or croak "instance variable needed";
    my $string = shift;

    # escape '&' chars.
    $string =~ s/&amp;/\&/g;
    $string =~ s/&/&amp;/g;
    
    chomp($string);

    return $string;
}

}
1;
__END__

=back

=head1 AUTHOR

Iestyn Pryce, <imp25@cam.ac.uk>
