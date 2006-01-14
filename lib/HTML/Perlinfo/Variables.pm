
# Should search for Get, Post, Cookies, Session, and Environment.
  sub perl_print_gpcse_array  {
	  my $HTML;
	  my($name) = @_;
	  my ($gpcse_name, $gpcse_value);
	  foreach my $key (sort(keys %ENV))
	  {
		  $gpcse_name = "$name" . '["' . "$key" . '"]';
		  if ($ENV{$key}) {
			  $gpcse_value = "$ENV{$key}";
		  } else {
			  $gpcse_value = "<i>no value</i>";
		  }
		  $HTML .= print_table_row(2, "$gpcse_name", "$gpcse_value");
	  }
	return $HTML;
  }

  sub print_variables {

	return join '', print_section("Environment Variables"),
		  	print_table_start(),
		  	print_table_header(2, "Variable", "Value"),
		  	((defined($ENV{'SERVER_SOFTWARE'})) ?  perl_print_gpcse_array("_SERVER") : perl_print_gpcse_array("_ENV",)),
		  	print_table_end();
   }
1;
