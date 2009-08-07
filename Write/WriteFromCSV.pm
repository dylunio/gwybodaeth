#!/usr/bin/env perl

use warnings;
use strict;

use lib ('.');

package WriteFromCSV;

use base qw(Write);

use Carp qw(croak);

sub write_rdf {
    ref(my $self = shift) or croak "instance variable needed";
    my $triple_data = shift;
    my $data = shift;

    my $triples = ${ $triple_data }[0];
    my $functions = ${ $triple_data }[1]; 

    # This loop makes sure that we give the data
    # interpreter only the data we want and not 
    # any metadata.
    my @pure_data;
    for my $row (0..$#{ $data }) {
        if (@{$data}[$row]->[0] =~ /start\s+row/i) {
            my $start = int @{$data}[$row]->[1];
            for ($start..$#{ $data }) {
                push @pure_data, @{ $data }[$_];
            }
            last;
        }
    }       

    if (!@pure_data) { # Always make sure the first line is skipped
        for (1..$#{ $data }) {
            push @pure_data, @{ $data }[$_];
        }
    } 

    $self->_write_meta_data();

    for my $row (@pure_data) {
        #$self->_write_triples($row, $triple_data);
        $self->_really_write_triples($row,$triples);
    }
    my %ids;
    for my $key (reverse keys %{ $functions }) {
        for my $row (@pure_data) {
            my $id = $self->_extract_field($row,$key);
            next if (exists $ids{$id});
            $ids{$id} = "";
            $self->_really_write_triples($row, $functions->{$key},$key);
        }
    }

    print "</rdf:RDF>\n";

    return 1;
}

# Parse the token to evaluate any if statements
sub _if_parse {
    my($self, $token, $row) = @_;

    if ($token =~ m/\@If\((.+)\;(.+)\;(.+)\)/i) {
        my($question,$true,$false) = ($1, $2, $3);

        $true =~ s/\'//g;
        $false =~ s/\'//g;

        my @q_split = split '=', $question;

        $q_split[0] =~ s/\'//g;
        $q_split[1] =~ s/\'//g;

        my $ans = "";
        if ($token =~ m/\<Ex\:(.+\+)\@If/i ) {
            ($ans .= $1) =~ s/\+//g;
            $ans .= ":";
        }

        if ($q_split[0] =~ m/^\$(\d+)/) {
            $q_split[0] = @{ $row }[$1-1];
        }

        if ($q_split[0] eq $q_split[1]) {
            $ans .= $true;
        } else {
            $ans .= $false;
        }
        $token = $ans;
    }

    return $token
}
1;
