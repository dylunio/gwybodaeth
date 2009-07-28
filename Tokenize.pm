#!/usr/bin/env perl

use warnings;
use strict;

package Tokenize;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

# Takes a reference to the input data as a parameter.
sub tokenize {
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
            # partial token. We add a space inbetween to repair from
            # the split operation. 
            ${ $data }[$i] .= " ${ $data }[$i+1]";

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
1;
