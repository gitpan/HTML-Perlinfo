   sub perl_info_print_license {
       return join '', SECTION("Perl License"),
		       perl_info_print_box_start(0),
		       perl_info_print_perl_license(),
		       perl_info_print_box_end();
   }
1;
