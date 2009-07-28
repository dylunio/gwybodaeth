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

        my $subject     = shift;
        my $predicate   = shift;
        my $object      = shift; 
        my $attribute   = shift;

        # If this is the first time we've come accross $subject
        # we create a new hash key for it
        if (not defined($self->{$subject})) {
            $self->{$subject} = {
                                'obj' => [],
                                'predicate' => [],
                                'attr' => undef,
                                };
        }

        push @{ $self->{$subject}{'obj'} }, $object;
        push @{ $self->{$subject}{'predicate'} }, $predicate;
        if (defined $attribute) {
            chomp($attribute);
            $self->{$subject}{'attr'} = "$attribute";
        }

        return $self;
    }
}
1;
