#!/usr/bin/env perl

use warnings;
use strict;

package RDFWriter;

my @open_tags = ();

# Opens a tag with a descriptor $tag
sub open_tag {
    my($class, $tag) = @_;

    print "<$tag>\n";
    push @open_tags, $tag;
}

# Closes the stated tag or the last tag added to @open_tags
sub close_tag {
    my ($class, $tag) = @_;

    unless (defined($tag)) {
        $tag = pop @open_tags;
    }

    print "</$tag>\n"
}

# Goes through the @open_tags array closing tags in the right order
sub close_all_tags {
    my($class) = @_;

    while (@open_tags) {
        my $tag = pop @open_tags;
        print "</$tag>";
    }
}

1; 
