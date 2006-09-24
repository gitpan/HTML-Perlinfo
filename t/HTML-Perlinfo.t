# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-Perlinfo.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
use strict;
use warnings;
BEGIN { plan tests => 5};

use HTML::Perlinfo;
use HTML::Perlinfo::Modules;
#########################

ok ( test('VARIABLES') );
ok ( test('APACHE') );
ok ( test('CREDITS') );
ok ( test('LICENSE') );
ok ( test_mods() );

sub test {
  my $html;
  my $p = HTML::Perlinfo->new();
  eval {
    my $option = 'info_' . lc $_[0];
    $html = $p->$option;
    $html = perlinfo("INFO_$_[0]");
  };
  die $@ if $@;
  return 1;
}
sub test_mods {
  my $html;
  my $m = HTML::Perlinfo::Modules->new( full_page => 0 );
  eval { $html = $m->print_modules( show_only=>qr/File::Spec/i, columns=>['name']); };
  die $@ if $@;
  return 1;
}
