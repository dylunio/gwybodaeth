#!/usr/bin/env perl

use warnings;
use strict;

use lib 'Parsers';
use lib '.';

use NamespaceManager;
use Triples;

package N3;

use Carp qw(croak);

my $triples = Triples->new();
my $functions = {};

sub new {
    my $class = shift;
    my $self = { };
    bless $self, $class;
    return $self;
}

sub parse {
    my($self, @data) = @_;

    ref($self) or croak "instance variable needed";

    my $subject;

    # Record the namespaces
    my $namespace = NamespaceManager->new();
    $namespace->map_namespace(\@data);

    my $tokenized = $self->_tokenize(\@data);

    $self->_parse_n3($tokenized);

    #$self->_populate_func($triples) or croak "function population went wrong!";
    $self->_parse_triplestore($triples) 
        or croak "function population went wrong";

    return $triples;
}

# Expects a reference to the tokenized data as a parameter
sub _parse_n3 {
    my $self = shift;
    my $data = shift;
    my $index_start = shift || 0;

    for my $indx ($index_start..$#{ $data } ) {
        my $token = ${ $data }[$indx];
        my $next_token = ${ $data }[$indx+1 % $#{ $data }];

        my $subject;

        if ($token =~ m/^\@prefix$/) {
            # logic
            next;
        }

        if ($token =~ m/^\@base$/) {
            #logic
            next;
        }

        # Shorthands for common predicates
        if ($token =~ m/^a$/) {
            # Should return a reference to a Triples type
            $self->_parse_triple($data, $indx);
            next;
        }
    
        if ($token =~ m/^\=$/) {
            #logic
            next;
        }

        if ($token =~ m/^\<\=$/) {
            # logic
            next;
        }

        if ($token =~ m/^\=\>$/) {
            #logic
            next;
        }
        # end of predicate shorthands

        if ($token =~ m/\<\s*Ex:.*\>/) {
            # record the next block as a 'function'
            if ($next_token =~ m/[.;]/) {
                # This is the call to the function
                # not its defenition
                next;
            } else {
                $self->_record_func($data, $indx);
                while((my $tok=$self->_next_token($data,$indx)) =~ /[^\.]/) {
                    ++$indx;
                } 
                return $self->_parse_n3($data,$indx);
            }
        }        

        if ($token =~ m/\[/) {
            if ($token =~ m/\[\]/) {
                #logic specific to 'something' bracket operator
                next;
            }
            # logic
            while((my $tok=$self->_next_token($data,$indx)) =~ /[^\]]/) {
                ++$indx;
            } 
            return $self->_parse_n3($data,$indx);
        }

        if ($token =~ m/\]/) {
            # logic
            next;
        }

        if ($token =~ m/\./) {
            #logic
            next;
        }

        if ($token =~ m/\;/) {
            #logic
            next;
        }
         
    }
    return $triples;
}

# Takes a reference to the input data as a parameter.
sub _tokenize {
    my($self, $data) = @_;

    my @tokenized;

    for (@{ $data }) {
        for (split /\s+/) {
            next if /^\s*$/;
            push @tokenized, $_;
        }
    }

    return $self->_tokenize_clean(\@tokenized);
}

# Takes a reference to the data which needs to be cleaned
sub _tokenize_clean {
    my($self, $data) = @_;

    for my $i (0..$#{ $data }) {
        
        next if (not defined ${ $data }[$i]);
        
            # If a token begins with '<' but doesn't end with '>'
            # then the token has been split up.
        if ((${$data}[$i] =~ /^\</ && ${$data}[$i] =~ /[^\>]$/)||
            # If the token begins but doesn't end with " the token may
            # have been split up 
            (${$data}[$i] =~ /^\"/ && ${$data}[$i] =~ /[^\"]$/)) {
            
            # Concatinate the next line to the current
            # partial token. 
            (${ $data }[$i] .= ${ $data }[$i+1]) =~ s/\s+//g;

            # Re-index the token list to take into account the last
            # concatination.
            for my $j (($i+1)..($#{ $data }-1)) {
                ${ $data }[$j] = ${ $data }[$j + 1];
            }
            
            # The last data element should now be deleted
            # as the data has been shifted up one in the 
            # list.
            delete ${ $data }[$#{ $data }];

            redo; # try again in case the token is split onto more than 2 lines
        }
    }
    return $data;
}

sub _next_token {
    my $self = shift;
    my $data = shift;
    my $index = shift;
    my $offset = shift || 1;

    return ${ $data }[$index+$offset];
}

# Takes a reference to the data and pointer to the start
# of relevent data as a parameter
sub _parse_triple {
    my $self = shift;
    my $data = shift;
    my $index = shift;

    ++$index;
    
    my $subject = ${ $data }[$index];

    if ($self->_next_token($data, $index) eq ';') {
        $self->_get_verb_and_object($data, $index, $subject, $triples)
    }
    return 1;
}

sub _get_verb_and_object {
    my($self, $data, $index, $subject, $triple) = @_;

    ++$index; # to get past the ';' char

    my $verb = ${ $data }[++$index];
    my $object = $self->_get_object($data, ++$index);

    $triple->store_triple($subject, $verb, $object);
    
    my $next_token = $self->_next_token($data, $index);

    if ($next_token eq ';') {
        $self->_get_verb_and_object($data, $index, $subject, $triple);
    } elsif ( $next_token eq '.') {
        # end of section;
        return $index;
    } else {
        # something went wrong?
        return 0;
    }
    return 1;
}

sub _get_object {
    my($self, $data, $index) = @_;

    if ((${ $data }[$index] eq '[') 
        and
        ($self->_next_token($data, $index) eq 'a')) 
    {
        return $self->_get_nested_triple($data, $index);
    } else {
        return ${ $data }[$index];
    }
}

sub _get_nested_triple {
    my($self, $data, $index) = @_;

    $index += 1; # to get over the ';' and 'a'

    my $nest_triple = Triples->new();

    my $subject = ${ $data }[++$index];

    my $next_token = $self->_next_token($data, $index);

    if ($next_token eq ';') {
        $self->_get_verb_and_object($data, 
                                    $index, 
                                    $subject, 
                                    $nest_triple);
    }
    return $nest_triple;
}

# Store a defined function in a hash
sub _record_func {
    my($self, $data, $index) = @_;

    my $func_name = ${ $data }[$index];

    my $func_triple = $self->_get_nested_triple($data, $index);

    $functions->{$func_name} = $func_triple;
    return $index;
}

# Parse the main triples hash so that functions are
# placed where they are called.
sub _parse_triplestore {
    my $self = shift;
    my $triple = shift;

    if (defined($functions)) {
        $self->_parse_functions($functions) 
            or croak "Unable to parse functions";
    }

    return $self->_populate_func($triple);
}

# Interface to _populate_func for the hash of functions
sub _parse_functions {
    my $self = shift;
    my $func_hash = shift; # a reference to the function hash

    for my $key (%{ $func_hash }) {
        $self->_populate_func($func_hash->{$key});
    }
    return 1;
}

# Populate any function calls with the triple store they define.
sub _populate_func {
    my $self = shift;
    my $triple = shift;

    for my $tkey (keys %{ $triple }) {
        for my $fkey ( keys %{ $functions } ) {
            for my $i (0..$#{ $triple->{$tkey}{'obj'} }) {
                my $obj = $triple->{$tkey}{'obj'}[$i];
                if ($obj eq $fkey) {
                    $triple->{$tkey}{'obj'}[$i] = $functions->{$fkey};
                    $self->_populate_func($triple);
                }
            }
        }
    }
    return 1;
}
1;
