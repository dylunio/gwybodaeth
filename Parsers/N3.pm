#!/usr/bin/env perl

use warnings;
use strict;

use lib './Parsers';
use lib '.';

use NamespaceManager;
use Triples;

package N3;

sub new {
    my $class = shift;
    my $self = { };
    bless $self, $class;
    return $self;
}

sub parse {
    my($self, @data) = @_;

#    my %prefix;
    my $triples = Triples->new();
    
    my $subject;

    my $namespace = NamespaceManager->new();
    $namespace->map_namespace(\@data);

    foreach my $line (@data) {
    
        # If prefix line
        if ($line =~ m/^\@prefix\s+(\S*:)\s+<(\S+)>\s+./) {
            # Skip to the next line
            next;
        }
        # Store the subject
        if ($line =~ m/^\[?\S*\]?\s+a\s+(\S+)\s*;/) {
            $subject = $1;
            next;
        }
        
        if ($line =~ m/^\s+(\S+)\s+(\S+)\s*[;.]$/) {
            my $predicate = $1;
            my $object = $2;

            $triples->store_triple($subject, $predicate, $object);
        }
    }

    return $triples;
}
1;
