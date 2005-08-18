   sub check_path {

	return which("$_[0]") if which("$_[0]");
	return "<i>not in path</i>";

   }

  sub PERL_VERSION {
	  my $version;
          if ($] >= 5.006) {
	  $version = sprintf "%vd", $^V;
          }
	  else { # else time to update Perl!
          $version = "$]";
  	  }
	  return $version;
  }

  sub RELEASE {

	return ($Module::CoreList::released{$]}) ? $Module::CoreList::released{$]} : "unknown";

  }

  
  sub ORA {
	  local($^W) = 0;
	  my $sock = IO::Socket::INET->new(	PeerAddr  => 'perl.oreilly.com',  
		  				PeerPort  => 80,
						PeerProto => 'tcp',
					        Timeout   => 5) || return 0;	 
	  $sock->close;
	  return 1;

  }


  sub perl_info_print_general {

   	          my $connected = ORA();
		  my $HTML = perl_info_print_box_start(1);
		  if ($connected) {
		  $HTML .= "<a href=\"http://www.perl.com/\"><img border=\"0\" src=\"";
		  $HTML .= "http://perl.oreilly.com/images/perl/sm_perl_id_313_wt.gif\" alt=\"Perl Logo\" title=\"Perl Logo\" /></a>";
		  }
		  $HTML .= sprintf("<h1 class=\"p\">Perl Version %s</h1><br clear=all>Release date: %s", PERL_VERSION(), RELEASE());
		 
		  $HTML .= perl_info_print_box_end();

		  $HTML .= perl_info_print_table_start();
                  $HTML .= perl_info_print_table_row(2, "Currently running on", "@{[ (uname)[0..4] ]}");
		  $HTML .= perl_info_print_table_row(2, "Built for",  "$Config{archname}");
		  $HTML .= perl_info_print_table_row(2, "Build date",  "$Config{cf_time}");
		  $HTML .= perl_info_print_table_row(2, "Perl path", which("perl"));
		  
		  $HTML .= perl_info_print_table_row(2, "Additional C Compiler Flags",  "$Config{ccflags}");
		  $HTML .= perl_info_print_table_row(2, "Optimizer/Debugger Flags",  "$Config{optimize}");

		  if (defined($ENV{'SERVER_SOFTWARE'})) {
			  $HTML .= perl_info_print_table_row(2, "Server API", "$ENV{'SERVER_SOFTWARE'}");
		  }


		  if ($Config{usethreads} && !$Config{useithreads} && !$Config{use5005threads}) {
			  $HTML .= perl_info_print_table_row(2, "Thread Support",  "enabled (threads)");
		  }		  
		  elsif ($Config{useithreads} && !$Config{usethreads} && !$Config{use5005threads}) {
			  $HTML .= perl_info_print_table_row(2, "Thread Support",  "enabled (ithreads)");
		  }
		  elsif ($Config{use5005threads} && !$Config{usethreads} && !$Config{useithreads}) {
			  $HTML .= perl_info_print_table_row(2, "Thread Support",  "enabled (5005threads)");
		  }
		  elsif ($Config{usethreads} && $Config{useithreads} && !$Config{use5005threads}) {
			  $HTML .= perl_info_print_table_row(2, "Thread Support",  "enabled (threads, ithreads)");
		  }
		  elsif ($Config{usethreads} && $Config{use5005threads} && !$Config{useithreads}) {
			  $HTML .= perl_info_print_table_row(2, "Thread Support",  "enabled (threads, 5005threads)");
		  }
		  elsif ($Config{useithreads} && $Config{use5005threads} && !$Config{usethreads}) {
			  $HTML .= perl_info_print_table_row(2, "Thread Support",  "enabled (ithreads, 5005threads)");
		  }
		  elsif ($Config{usethreads} && $Config{useithreads} &&  $Config{use5005threads}) {
			  $HTML .= perl_info_print_table_row(2, "Thread Support",  "enabled (threads, ithreads, 5005threads)");
		  }
		  else {
			  $HTML .= perl_info_print_table_row(2, "Thread Support",  "disabled (threads, ithreads, 5005threads");
		  }
			

		  $HTML .= perl_info_print_table_end();

		  # Powered by Perl
		  # Need to check for net connection
		  $HTML .= perl_info_print_box_start(0);

		  if ($connected) {
			  $HTML .= "<a href=\"http://www.perl.com/\"><img border=\"0\" src=\"http://perl.oreilly.com/images/perl/powered_by_perl.gif\" alt=\"Perl logo\" title=\"Perl Logo\" /></a>";
			  $HTML .= "This is perl, v$Config{version} built for $Config{archname}<br />Copyright (c) 1987-@{[ sprintf '%d', (localtime)[5]+1900]}, Larry Wall";
			  $HTML .= "</td></tr></table>";
			  $HTML .= "<font size=\"1\">The use of a camel image in association with Perl is a trademark of <a href=\"http://www.oreilly.com\">O'Reilly Media, Inc.</a> Used with permission.</font><p />";
		  }
		  else {
			  $HTML .= "This is perl, v$Config{version} built for $Config{archname}<br />Copyright (c) 1987-@{[ sprintf '%d', (localtime)[5]+1900]}, Larry Wall";
			  $HTML .= perl_info_print_box_end();
		  }

		  if ($flag eq "INFO_ALL") { 
			  $HTML .= perl_info_print_hr();

			  $HTML .=<<'END_OF_HTML';
		  <h1>
		  <SCRIPT LANGUAGE="JavaScript">
		  <!--
		  document.write("<a onclick=\"showcredits();\" href=\"javascript:void(0);\">Perl Credits</a>");
		  //-->
		  </SCRIPT>
		  <noscript>Enable JavaScript to see the credits. Alternatively you can use perlinfo(INFO_CREDITS). 
		  </noscript>
		  </h1>
END_OF_HTML
			  $HTML .= perl_info_print_hr();
			  $HTML .= "<h1>Configuration</h1>\n";
			  $HTML .= perl_info_print_config(); 

			  $HTML .= join '', SECTION("Perl utilities"),
			  perl_info_print_table_start(),
			  perl_info_print_table_header(2, "Name", "Location"),
			  perl_info_print_table_row(2, cpan_link("h2ph"), check_path("h2ph")),
			  perl_info_print_table_row(2, cpan_link("h2xs"), check_path("h2xs")),
			  perl_info_print_table_row(2, cpan_link("perldoc"), check_path("perldoc")),
			  perl_info_print_table_row(2, cpan_link("pod2html"), check_path("pod2html")),
			  perl_info_print_table_row(2, cpan_link("pod2latex"), check_path("pod2latex")),
			  perl_info_print_table_row(2, cpan_link("pod2man"), check_path("pod2man")),
			  perl_info_print_table_row(2, cpan_link("pod2text"), check_path("pod2text")),
			  perl_info_print_table_row(2, cpan_link("pod2usage"), check_path("pod2usage")),
			  perl_info_print_table_row(2, cpan_link("podchecker"), check_path("podchecker")),
			  perl_info_print_table_row(2, cpan_link("podselect"), check_path("podselect")),
			  perl_info_print_table_end(),

			  SECTION("Mail"),
			  perl_info_print_table_start(),
			  perl_info_print_table_row(2, 'SMTP', hostname()),
			  perl_info_print_table_row(2, 'sendmail_path', which("sendmail")),
			  perl_info_print_table_end(),


			  perl_info_print_httpd(),

			  SECTION("HTTP Headers Information"),
			  perl_info_print_table_start(),
			  perl_info_print_table_colspan_header(2, "HTTP Request Headers");
			  if  (defined($ENV{'SERVER_SOFTWARE'})) {
				  $HTML .= join '',
				  perl_info_print_table_row(2, 'HTTP Request', "$ENV{'REQUEST_METHOD'} @{[File::Spec->abs2rel($0)]} $ENV{'SERVER_PROTOCOL'}"),
				  perl_info_print_table_row(2, 'Host', $ENV{'HTTP_HOST'}),
				  perl_info_print_table_row(2, 'User-Agent', $ENV{'HTTP_USER_AGENT'}),
				  perl_info_print_table_row(2, 'Accept', $ENV{'HTTP_ACCEPT_ENCODING'}),
				  perl_info_print_table_row(2, 'Accept-Language', $ENV{'HTTP_ACCEPT_LANGUAGE'}),
				  perl_info_print_table_row(2, 'Accept-Charset', $ENV{'HTTP_ACCEPT_CHARSET'}),
				  perl_info_print_table_row(2, 'Keep-Alive', $ENV{'HTTP_KEEP_ALIVE'}),
				  perl_info_print_table_row(2, 'Connection', $ENV{'HTTP_CONNECTION'});
			  }
			  $HTML .= perl_info_print_table_end();
		  }
		return $HTML;
	  }	  
	  1;
