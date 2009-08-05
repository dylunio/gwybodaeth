#!/usr/bin/env perl

use warnings;
use strict;

use lib '../Parsers';

use Escape;

package Write;

use Carp qw(croak);

sub new {
    my $class = shift;
    my $self = { ids => {} };
    bless $self, $class;
    return $self;
}


sub _extract_field {
    my $self = shift;
    my $data = shift;
    my $field = shift;

    # The object is a specific field
    if ($field =~ m/^\"Ex:\$(\d+)\"$/) { 
        my $field_num = int ($1-1); # we subtract 1 as arrays start at 0 not 1
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
    elsif ($field =~ m/^\<Ex:\$(\d+)\>$/) {
        my $field_num = int ($1-1);
        if( @{$data}[$field_num] ) {
            chomp(my $field_text = @{ $data }[$field_num]);
            return $field_text;
        }
    }
    
    # If it doesn't match any of the above, allow it to be a bareword field
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
    my $self = shift;
    $self->_really_write_triples(@_);
}

sub _really_write_triples {
    my ($self, $row, $triples, $id) = @_;

    for my $triple_key ( keys %{ $triples } ) {

        print "<".$self->_if_parse($triple_key,$row);
        if ($id) {
            chomp(my $id_text = $self->_extract_field($row,$id));
            if (ref($id_text) eq 'ARRAY') {
                for my $obj (@{ $id_text }) {
                    print $self->_about_or_id($obj);
                }
            } else {
                print $self->_about_or_id($id_text);
            }
            print '"';
        } 
        print ">\n";

        my @verbs = @{ $triples->{$triple_key}{'predicate'} };
        for my $indx (0..$#verbs ) {
            $self->_get_verb_and_object(
                                $verbs[$indx],
                                $triples->{$triple_key}{'obj'}[$indx],
                                $row);
        }
        print "</".$self->_if_parse($triple_key,$row).">\n";
    }
}

sub _get_verb_and_object {
    my($self, $verb, $object, $row) = @_;

    my $obj_text = "";
    unless ( eval{ $object->isa('Triples') } ) {
        $obj_text = $self->_get_object($row, $object);
    }

    if (ref($obj_text) eq 'ARRAY') {
        for my $obj (@{ $obj_text }) {
            $self->_print_verb_and_object($verb, $obj, $row, $object);
        }
    } else {
        $self->_print_verb_and_object($verb, $obj_text, $row, $object);
    }
}

sub _print_verb_and_object {
    my ($self, $verb, $object, $row, $unparsed_obj) = @_;
    my $esc = Escape->new();

    print "<" . $self->_if_parse($verb,$row);

    if ( $unparsed_obj =~ m/\<Ex:\$\w+\/?\w*\>$/ ) {
        # We have a reference
        print ' rdf:resource="#';
        my $parsed_obj = $self->_get_object($row,$unparsed_obj);
        if (ref($parsed_obj) eq 'ARRAY') {
            for my $obj (@{ $parsed_obj }) {
                print $esc->escape($obj);
            }
        } else {
            print $esc->escape($parsed_obj);
        }
        print "\"/>\n";
    } else {
        print ">";
        if (eval{$unparsed_obj->isa('Triples')}) {
            print $esc->escape($self->_get_object($row,$unparsed_obj));
        } else {
            print $esc->escape($self->_get_object($row,$object));
        }
        print "</" . $self->_if_parse($verb,$row) . ">\n";
    }
}

sub _get_object {
    my($self, $row, $object) = @_;

    if (eval {$object->isa('Triples')}) {
        $self->_write_triples($row, $object);
    } else {
        return $self->_extract_field($row, $object);
    }
}

sub _about_or_id {
    my($self, $text) = @_;

    if ($text =~ /\s/) { 
        print ' rdf:about="#';
    } else {
        print ' rdf:ID="';
    }
    return $text;
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
