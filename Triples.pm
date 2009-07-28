#!/usr/bin/env perl

use warnings;
use strict;

package Triples;

use Carp qw(croak);
{
    sub new {
        my $class = shift;
        my $self = {};
        bless $self, $class;
        return $self;
    }

    # Stores the triple and returns a reference to itself    
    # Expects ($sbject, $predicate, $object) as parameters
    sub store_triple {
        ref(my $self    = shift) or croak "instance variable needed";

        defined(my $subject     = shift) or croak "must pass a subject";
        defined(my $predicate   = shift) or croak "must pass a predicate";
        defined(my $object      = shift) or croak "must pass an object"; 

        # If this is the first time we've come accross $subject
        # we create a new hash key for it
        if (not defined($self->{$subject})) {
            $self->{$subject} = {
                                'obj' => [],
                                'predicate' => [],
                                };
        }

        push @{ $self->{$subject}{'obj'} }, $object;
        push @{ $self->{$subject}{'predicate'} }, $predicate;

        return $self;
    }
}
1;
