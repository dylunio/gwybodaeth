#!/usr/bin/env perl

use warnings;
use strict;

use lib './Parsers';
use lib '.';

use NamespaceManager;
use Triples;

package N3;

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

    my $subject;

    # Record the namespaces
    my $namespace = NamespaceManager->new();
    $namespace->map_namespace(\@data);

    my $tokenized = $self->_tokenize(\@data);

    $self->_parse_n3($tokenized);

    use YAML;
    #print Dump($triples);    

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
                use YAML;
                #print Dump($functions);
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
            next;
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

            redo; # try again incase the token is split onto more than 2 lines
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

    # Substitute any calls to functions with the function
    # itself.
    for my $key (keys %{ $functions }) {
        if ($key eq $object) {
            $object = $functions->{$key};
        }
    }

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

sub _record_func {
    my($self, $data, $index) = @_;

    my $func_name = ${ $data }[$index];

    my $func_triple = $self->_get_nested_triple($data, $index);

    $functions->{$func_name} = $func_triple;
    return $index;
}
1;
