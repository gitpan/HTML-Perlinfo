# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-Perlinfo.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 5};

use HTML::Perlinfo;
#########################

ok ( test(VARIABLES) );
ok ( test(APACHE) );
ok ( test(MODULES) );
ok ( test(CREDITS) );
ok ( test(LICENSE) );

sub test {

my $html;
$p = new HTML::Perlinfo;
        eval {
		my $option = info_ . lc $_[0];
		$html = $p->$option;
                $html = perlinfo("INFO_$_[0]");
        };
        die $@ if $@;
        return 1;
}

