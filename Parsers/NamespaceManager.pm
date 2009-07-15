#!/usr/bin/env perl

use warnings;
use strict;


package NamespaceManager;

use Carp qw(croak);

# A hash to store all the namespaces
my %namespace;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub map_namespace {
    ref(my $self = shift) or croak "instance variable needed";
    my $data = shift;   # A referece to the data

    for my $line (@{ $data }) {
        if ($line =~ m/^\@prefix\s+(\S*:)\s+<(\S+)>\s+./) {
            $namespace{$1} = $2;
        }
    }
    return $self->get_namespace_hash();
}

sub get_namespace_hash {
    ref(my $self = shift) or croak "instance variable needed";

    return \%namespace;
}
1;
