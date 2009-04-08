# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-Perlinfo.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1};

use HTML::Perlinfo::Modules;
#########################

ok ( test_mods() );

sub test_mods {
  my $html;
  my $m = HTML::Perlinfo::Modules->new( full_page => 0 );
  eval { $html = $m->print_modules( show_only=>['File::Spec'], columns=>['name']); };
  die $@ if $@;
  return 1;
}
