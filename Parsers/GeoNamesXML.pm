#!/usr/bin/env perl

use warnings;
use strict;

package GeoNamesXML;

use Carp qw{croak};
use XML::Twig;

# Inherit from XML class
use base qw( XML );

my %types;

sub parse {
    my($self, @data) = @_;
   
    ref($self) or croak "instance variable expected";

    my $xml = XML::Twig->new();

    my $string;
    for my $line (@data) {
        $string .= $line;
    }
    $xml->parse($string);

#    my @tokens;
#    foreach my $line (@data) {
#        push @tokens, split /[><]/, $line;
#    }


    use YAML;

#    print Dump($xml);
#    return \@tokens;
    return $xml;
}

sub _char_parse {
    ref(my $self = shift) or croak "instance variable expected";
    my $chars = shift;
    my $index_start = shift || 0;
    my $types = shift || {};

    for my $i ($index_start..$#{ $chars }) {
        if ($chars->[$i] eq '<') {
            $self->_tag($chars,$i);
        }
    }

    return $types;
}

sub _tag {
    ref(my $self = shift) or croak "instance variable expected";
    my $chars = shift;
    my $index = shift;

    my $type = undef;
    my $i = $index;
    
    # add 1 to get over the < char which got us to this method.
    for $i ($index..$#{ $chars }) {

        if ($chars->[$i] =~ /[\>\?]/) { # closing tag
            last;
        }
        if ($chars->[$i] =~ /\s/) { # whitespace
            $self->_attribute($chars, $i);
        } else {
            $type .= $chars->[$i];
        }
    
    }

    if ( defined $type ) {
        $type =~ s#[<>/]##g;
        $types{$type} = { attribute => undef, data => undef };
    }

    return $i;
}

sub _attribute {
    ref(my $self = shift) or croak "instance variable expected";
    my $chars = shift;
    my $index = shift;
    
    return 1;
}
1;
