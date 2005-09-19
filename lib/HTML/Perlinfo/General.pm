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

          return 0 unless $link_switch;

	  local($^W) = 0;
	  my $sock = IO::Socket::INET->new(	PeerAddr  => 'perl.oreilly.com',  
		  				PeerPort  => 80,
						PeerProto => 'tcp',
					        Timeout   => 5) || return 0;	 
	  $sock->close;
	  return 1;

  }


  sub print_general {

		  my $HTML = print_box_start(1);
		  $HTML .= links('ora', 'camel1') if ORA();
		  $HTML .= sprintf("<h1 class=\"p\">Perl Version %s</h1><br clear=all>Release date: %s", PERL_VERSION(), RELEASE());
		 
		  $HTML .= print_box_end();

		  $HTML .= print_table_start();
                  $HTML .= print_table_row(2, "Currently running on", "@{[ (uname)[0..4] ]}");
		  $HTML .= print_table_row(2, "Built for",  "$Config{archname}");
		  $HTML .= print_table_row(2, "Build date",  "$Config{cf_time}");
		  $HTML .= print_table_row(2, "Perl path", which("perl"));
		  
		  $HTML .= print_table_row(2, "Additional C Compiler Flags",  "$Config{ccflags}");
		  $HTML .= print_table_row(2, "Optimizer/Debugger Flags",  "$Config{optimize}");

		  if (defined($ENV{'SERVER_SOFTWARE'})) {
			  $HTML .= print_table_row(2, "Server API", "$ENV{'SERVER_SOFTWARE'}");
		  }


		  if ($Config{usethreads} && !$Config{useithreads} && !$Config{use5005threads}) {
			  $HTML .= print_table_row(2, "Thread Support",  "enabled (threads)");
		  }		  
		  elsif ($Config{useithreads} && !$Config{usethreads} && !$Config{use5005threads}) {
			  $HTML .= print_table_row(2, "Thread Support",  "enabled (ithreads)");
		  }
		  elsif ($Config{use5005threads} && !$Config{usethreads} && !$Config{useithreads}) {
			  $HTML .= print_table_row(2, "Thread Support",  "enabled (5005threads)");
		  }
		  elsif ($Config{usethreads} && $Config{useithreads} && !$Config{use5005threads}) {
			  $HTML .= print_table_row(2, "Thread Support",  "enabled (threads, ithreads)");
		  }
		  elsif ($Config{usethreads} && $Config{use5005threads} && !$Config{useithreads}) {
			  $HTML .= print_table_row(2, "Thread Support",  "enabled (threads, 5005threads)");
		  }
		  elsif ($Config{useithreads} && $Config{use5005threads} && !$Config{usethreads}) {
			  $HTML .= print_table_row(2, "Thread Support",  "enabled (ithreads, 5005threads)");
		  }
		  elsif ($Config{usethreads} && $Config{useithreads} &&  $Config{use5005threads}) {
			  $HTML .= print_table_row(2, "Thread Support",  "enabled (threads, ithreads, 5005threads)");
		  }
		  else {
			  $HTML .= print_table_row(2, "Thread Support",  "disabled (threads, ithreads, 5005threads");
		  }
			

		  $HTML .= print_table_end();

		  # Powered by Perl
		  # Need to check for net connection
		  $HTML .= print_box_start(0);

		  if (ORA()) {
			  $HTML .= links('ora', 'camel2');
			  $HTML .= "This is perl, v$Config{version} built for $Config{archname}<br />Copyright (c) 1987-@{[ sprintf '%d', (localtime)[5]+1900]}, Larry Wall";
			  $HTML .= "</td></tr></table>";
			  $HTML .= links('ora', 'copyright');
		  }
		  else {
			  $HTML .= "This is perl, v$Config{version} built for $Config{archname}<br />Copyright (c) 1987-@{[ sprintf '%d', (localtime)[5]+1900]}, Larry Wall";
			  $HTML .= print_box_end();
		  }

		  if ($flag eq "INFO_ALL") { 
			$HTML .= print_hr();

			if ($link_switch) {
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
			}
			$HTML .= print_hr();
			$HTML .= "<h1>Configuration</h1>\n";
			$HTML .= print_config(); 

			$HTML .= join '', SECTION("Perl utilities"),
				print_table_start(),
				print_table_header(2, "Name", "Location"),
				print_table_row(2, links('cpan', 'h2ph'), check_path("h2ph")),
				print_table_row(2, links('cpan', 'h2xs'), check_path("h2xs")),
				print_table_row(2, links('cpan', 'perldoc'), check_path("perldoc")),
				print_table_row(2, links('cpan', 'pod2html'), check_path("pod2html")),
				print_table_row(2, links('cpan', 'pod2latex'), check_path("pod2latex")),
				print_table_row(2, links('cpan', 'pod2man'), check_path("pod2man")),
				print_table_row(2, links('cpan', 'pod2text'), check_path("pod2text")),
				print_table_row(2, links('cpan', 'pod2usage'), check_path("pod2usage")),
				print_table_row(2, links('cpan', 'podchecker'), check_path("podchecker")),
				print_table_row(2, links('cpan', 'podselect'), check_path("podselect")),
				print_table_end(),

				SECTION("Mail"),
				print_table_start(),
				print_table_row(2, 'SMTP', hostname()),
				print_table_row(2, 'sendmail_path', which("sendmail")),
				print_table_end(),


				print_httpd(),

				SECTION("HTTP Headers Information"),
				print_table_start(),
				print_table_colspan_header(2, "HTTP Request Headers");
			if  (defined($ENV{'SERVER_SOFTWARE'})) {
				$HTML .= join '',
					print_table_row(2, 'HTTP Request', "$ENV{'REQUEST_METHOD'} @{[File::Spec->abs2rel($0)]} $ENV{'SERVER_PROTOCOL'}"),
					print_table_row(2, 'Host', $ENV{'HTTP_HOST'}),
					print_table_row(2, 'User-Agent', $ENV{'HTTP_USER_AGENT'}),
					print_table_row(2, 'Accept', $ENV{'HTTP_ACCEPT_ENCODING'}),
					print_table_row(2, 'Accept-Language', $ENV{'HTTP_ACCEPT_LANGUAGE'}),
					print_table_row(2, 'Accept-Charset', $ENV{'HTTP_ACCEPT_CHARSET'}),
					print_table_row(2, 'Keep-Alive', $ENV{'HTTP_KEEP_ALIVE'}),
					print_table_row(2, 'Connection', $ENV{'HTTP_CONNECTION'});
			}
			$HTML .= print_table_end();
		  }
		  return $HTML;
  }	  
1;
