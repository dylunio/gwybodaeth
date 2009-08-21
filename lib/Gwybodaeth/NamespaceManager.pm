#!/usr/bin/env perl

use warnings;
use strict;

package Gwybodaeth::NamespaceManager;

=head1 NAME

NamespaceManager - parses and stores namespaces for gwybodaeth

=head1 SYNOPSIS

    use NamespaceManager;

    my $nm = NamespaceManager->new();

    $nm->map_namespace($data);
    $nm->get_namspace_hash();

=head1 DESCRIPTION

This module stores namespace data and makes these available as a hash.

=over

=cut 

use Carp qw(croak);

# A hash to store all the namespaces
my %namespace;
# Default for $base set to an empty string.
# This will be interpreted as 'this document'.
my $base = "";

=item new()

Returns an instance of the NamespaceManager class.

=cut

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

=item map_namespace($data)

Takes an array reference $data, and maps any namespaces declared into a hash.
Returns a refence to this hash. It also stores any @base elements found.

=cut

sub map_namespace {
    ref(my $self = shift) or croak "instance variable needed";
    my $data = shift;   # A referece to the data

    # Clear what may already be in %namespace from a previous run
    for (keys %namespace) { delete $namespace{$_}; };
    # Clear what may have been in $base from a previous run
    $base = "";

    for my $line (@{ $data }) {
        if ($line =~ m/^\@prefix\s+(\S*:)\s+<(\S+)>\s+./) {
            $namespace{$1} = $2;
        }
        if ($line =~ m/^\@base\s+<([^>]*)>\s+.\s*$/) {
            $base = $1;
        }
    }
    return $self->get_namespace_hash();
}

=item get_namespace_hash()

Returns a hash reference to a hash containing mapped namespaces.

=cut

sub get_namespace_hash {
    ref(my $self = shift) or croak "instance variable needed";

    return \%namespace;
}

=item get_base()

Returns a reference to the base of the document.

=cut

sub get_base {
    ref(my $self = shift) or croak "instance variable needed";

    return \$base;
}
1;
__END__

=back

=head1 AUTHOR

Iestyn Pryce, <imp25@cam.ac.uk>
