#!/usr/bin/env perl

use warnings;
use strict;

package N3;

sub new {
    my $class = shift;
    my $self = { };
    bless \$self, $class;
}

sub parse {
    my $self = shift;
    my @data = @_;

    my %prefix;
    my %triples;
    
    my $subject;

    foreach my $line (@data) {
        # Create a hash of prefixes to full attributes
        if ($line =~ m/^\@prefix\s+(\S*:)\s+(\S+)\s+./) {
            $prefix{$1} = $2;
            next;
        }
        # Store the subject
        if ($line =~ m/^\[\S*\]\s+a\s+(\S+)\s*;/) {
            $subject = $1;
            my @objs = ();
            my @predicates = ();
            my %subject_data = ( 
                'obj' => \@objs, 
                'predicates' => \@predicates,
            );
            $triples{$subject} = \%subject_data;
            next;
        }
        
        if ($line =~ m/^\s+(\S+)\s+(\S+)\s*[;.]$/) {
            my $predicate = $1;
            my $objects = $2;

            push @{ $triples{$subject}{'obj'} }, $objects;
            push @{ $triples{$subject}{'predicates'} }, $predicate;
        }
    }

    use YAML;

    print Dump(\%prefix);
    print Dump(\%triples);

    return \%triples;

}
1;
