#!/usr/bin/perl -w

use strict;
use Test;

BEGIN 
  {
  chdir 't' if -d 't';
  unshift @INC, '../lib';
  plan tests => 22;
  }

use Math::String::Sequence;
use Math::String;
use Math::BigInt;

my ($seq,$first,$last);

##############################################################################
# check new()

$seq = Math::String::Sequence->new( 'a', 'z' );

ok (ref($seq),'Math::String::Sequence');
ok ($seq->first(),'a');
ok ($seq->last(),'z');
ok ($seq->string(2),'c');
ok ($seq->string(0),'a');
ok ($seq->string(-1),'z');
ok ($seq->string(-2),'y');

my @set = split //,reverse 'abcdefghijklmnopqrstuvwxyz';

$seq = Math::String::Sequence->new( 'z', 'a', \@set );
ok (ref($seq),'Math::String::Sequence');
ok ($seq->first(),'z');
ok ($seq->last(),'a');
ok ($seq->string(24),'b');
ok ($seq->string(-1),'a');
ok ($seq->string(-2),'b');

##############################################################################
# check is_reversed() and reversed sequences

$seq = Math::String::Sequence->new( 'a', 'z' );
ok ($seq->is_reversed(),0);

$seq = Math::String::Sequence->new( 'z', 'a' );
ok ($seq->is_reversed(),1);

$seq = Math::String::Sequence->new( 'z', 'a' );
ok ($seq->first(), 'z');
ok ($seq->last(), 'a');
ok ($seq->length(),26);
ok ($seq->string(0),'z');
ok ($seq->string(1),'y');
ok ($seq->string(-1),'a');
ok ($seq->string(-2),'b');

