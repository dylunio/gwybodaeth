#!/usr/bin/env perl

use warnings;
use strict;

use lib '/home/imp25/urop/perl/gwybodaeth/';

use Test::More qw(no_plan);

BEGIN { use_ok( 'Tokenize' ); }

my $tokenizer = new_ok( 'Tokenize' );

my $list;
my $tok_list;

# Barewords test
$list = [ "foo", "bar", "baz" ];

is_deeply( $tokenizer->tokenize($list), $list, "barewords");

# Strings with spaces tests
$list = [ "foo is a var", "bar is also a var", "but baz is just wierd" ];
$tok_list = [ "foo", "is", "a", "var", "bar", "is", "also", "a", "var", 
              "but", "baz", "is", "just", "wierd" ];

is_deeply( $tokenizer->tokenize($list), $tok_list, "strings with spaces");

# Strings with quotes test
$list = [ 'we love "foo bar"', 'or do "we"' ];
$tok_list = [ 'we', 'love', '"foo bar"', 'or', 'do', '"we"' ];

is_deeply( $tokenizer->tokenize($list), $tok_list, "strings with quotes");

# Strings with angle brackets test
$list = [ 'this is an <angle bracket>' , 'test' ];
$tok_list = [ 'this', 'is', 'an', '<angle bracket>', 'test' ];

is_deeply( $tokenizer->tokenize($list), $tok_list, "strings with < and >");

# Punctuation test
$list = [ '!', '@', '#', '$', '%', '^ ' ];
$tok_list = [ '!', '@', '#', '$', '%', '^' ];

is_deeply( $tokenizer->tokenize($list), $tok_list, "punctuation");
