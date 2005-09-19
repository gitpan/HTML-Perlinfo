   sub print_license {
       return join '', SECTION("Perl License"),
		       print_box_start(0),
		       print_perl_license(),
		       print_box_end();
   }
1;
