#!/usr/bin/env perl

use warnings;
use strict;

use lib 'Parsers';

use Escape;

package Write;

use Carp qw(croak);

sub new {
    my $class = shift;
    my $self = { };
    bless $self, $class;
    return $self;
}


sub _extract_field {
    my $self = shift;
    my $data = shift;
    my $field = shift;

    # The object is a specific field
    if ($field =~ m/^\"Ex:\$(\d+)\"$/) {
        my $field_num = int ($1 -1); # we subtract 1 as arrays start at 0 not 1
        if( @{$data}[$field_num] ) {
            return @{ $data }[$field_num];
        }
    
    }
    # The object is a concatination of fields 
    elsif ($field =~ m/^\"Ex:.*\+/) {
        return $self->_cat_field($data, $field);
    }
    elsif ($field =~ m/^\$(\d+)$/) {
        my $field_num = int ($1 -1);
        if( @{$data}[$field_num] ) {
            return @{ $data }[$field_num];
        }
    }
    
    # If it doesn't match either of the above, allow it to be a bareword field
    return "$field";
}

# Concatinate fields
sub _cat_field {
    my $self = shift;
    my $data = shift;
    (my $field = shift) =~ s/Ex://;

    my $string = "";

    my @values = split /\+/, $field;

    for my $val (@values) {
        # Extract ${num} variables from data
        if ($val =~ m/\$(\d+)/) {
            my $field_num = int ($1 -1);
            if (@{ $data }[$field_num]) {
                $string .= @{ $data }[$field_num];
            }
        }
        # Put a space; 
        elsif ($val =~ m/\'\s*\'/) {
            $string .= " ";
        } 
        # Print a literal
        else {
            $string .= $val;
        }
    }
    return $string;
}

sub _write_meta_data {
    my $self = shift;

    my $namespace = NamespaceManager->new();
    my $name_hash = $namespace->get_namespace_hash();
    

    print "<?xml version=\"1.0\"?>\n<rdf:RDF\n";
    for my $keys (keys %{ $name_hash }) {
        (my $key = $keys) =~ s/:$//;
        next if ($key eq "");
        print "xmlns:$key=\"" . $name_hash->{$keys} . "\"\n";
    }
    print ">\n";
    
    return 1;
}

sub _write_triples {
    my($self, $row, $triples) = @_;
    
    my $esc = Escape->new();

    for my $triple_key ( keys %{ $triples } ) {
        print "<".$self->_if_parse($triple_key,$row).">\n";
        my @verbs = @{ $triples->{$triple_key}{'predicate'} };
        for my $indx (0..$#verbs ) {
            print "<".$self->_if_parse($verbs[$indx],$row).">";
            $self->_get_object($row,
                               $triples->{$triple_key}{'obj'}[$indx]);
            print "</".$self->_if_parse($verbs[$indx],$row) .">\n";
        }
        print "</".$self->_if_parse($triple_key,$row).">\n";
    }
}

sub _get_object {
    my($self, $row, $object) = @_;

    if (eval {$object->isa('Triples')}) {
        print "\n";
        $self->_write_triples($row, $object);
    } else {
        my $esc = Escape->new();
        print $esc->escape($self->_extract_field($row, $object));
    }
} 

# Parse the token to evaluate any if statements
sub _if_parse {
    my($self, $token, $row) = @_;

    #print "@{ $row }";

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
