#!/usr/bin/env perl

use warnings;
use strict;

package NamespaceManager;

# A hash to store all the namespaces
my %namespace;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub map_namespace {
    my $self = shift;
    my $data = shift;   # A referece to the data

    for my $line (@{ $data }) {
        if ($line =~ m/^\@prefix\s+(\S*:)\s+<(\S+)>\s+./) {
            $namespace{$1} = $2;
        }
    }
}

sub get_namespace_hash {
    my $self = shift;

    return \%namespace;
}
1;
