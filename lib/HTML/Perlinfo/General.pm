package HTML::Perlinfo::General;

use base qw(Exporter);
our @EXPORT = qw(print_httpd print_thesemodules print_config print_variables print_general); 
use CGI::Carp 'fatalsToBrowser';
use POSIX qw(uname);
use Config qw(%Config config_sh);
use Net::Domain qw(hostname);
use File::Which;
use File::Spec;
use HTML::Perlinfo::Common;
use HTML::Perlinfo::Apache;

# Should search for Get, Post, Cookies, Session, and Environment.
sub perl_print_gpcse_array  {
	  my $html;
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
		  $html .= print_table_row(2, "$gpcse_name", "$gpcse_value");
	  }
	return $html;
}

sub print_variables {

	return join '', print_section("Environment Variables"),
		  	print_table_start(),
		  	print_table_header(2, "Variable", "Value"),
		  	((defined($ENV{'SERVER_SOFTWARE'})) ?  perl_print_gpcse_array("_SERVER") : perl_print_gpcse_array("_ENV",)),
		  	print_table_end();
}

sub print_config {

	return join '',	print_section("Perl Core"),
			print_table_start(),
			print_table_header(2, "Variable", "Value"),
			print_config_sh($_[0]),
			print_table_end();	
}

sub print_config_sh {

	my @configs = qw/api_versionstring cc ccflags cf_by cf_email cf_time extensions installarchlib installbin installhtmldir installhtmlhelpdir installprefix installprefixexp installprivlib installscript installsitearch installsitebin known_extensions libc libperl libpth libs myarchname optimize osname osvers package perllibs perlpath pm_apiversion prefix prefixexp privlib privlibexp startperl version version_patchlevel_string xs_apiversion/;
        
	return  ($_[0] eq 'info_all') ? 
			join '', map { print_table_row(2, add_link('config',$_), $Config{$_})} @configs 
				: join '', map { print_table_row(2, map{ 
						if ($_ !~ /^'/) {
							add_link('config', $_);	
						} 
						else {
							if ($_ eq "\'\'" || $_ eq "\' \'" ) { 	
								my $value = "<i>no value</i>";
								$value;
							}
							else {
								$_; 
							} 
						}                     
								    }split/=/,$_ ) 
					    } split /\n/, config_sh();	
}

sub print_httpd {

  my $a = HTML::Perlinfo::Apache->new();

  my $html .= print_section("Apache");
  $html .= print_table_start();
  $html .= $a->print_apache() if $a->has qw(env);
  $html .= print_table_end();
 
  $html .= $a->print_modperl() if $a->has qw(mp);

  $html .= print_section("Apache Environment"), 
  $html	.= print_table_start(); 
  $html .= print_table_header(2, "Variable", "Value"), 
  $html .= $a->print_apache_environment() if $a->has qw(env); 
  $html .= print_table_end();

  return $html;
}

 sub print_thesemodules {
    $m = HTML::Perlinfo::Modules->new();
    return $m->print_modules(show_only=>$_[0], full_page=>0) if $_[0] eq 'core';
    return $m->print_modules(full_page=>0);
 }

sub print_general {

  my $html = print_box_start(1);
  $html .= add_link('ora', 'camel1') if check_images('http://i104.photobucket.com');
  #$html .= add_link('ora', 'camel1');
  $html .= sprintf("<h1 class=\"p\">Perl Version %s</h1><br clear=all>Release date: %s", perl_version(), release());
		 
  $html .= print_box_end();

  $html .= print_table_start();
  $html .= print_table_row(2, "Currently running on", "@{[ (uname)[0..4] ]}");
  $html .= print_table_row(2, "Built for",  "$Config{archname}");
  $html .= print_table_row(2, "Build date",  "$Config{cf_time}");
  $html .= print_table_row(2, "Perl path", "$^X");
		  
  $html .= print_table_row(2, "Additional C Compiler Flags",  "$Config{ccflags}");
  $html .= print_table_row(2, "Optimizer/Debugger Flags",  "$Config{optimize}");

  if (defined($ENV{'SERVER_SOFTWARE'})) {
    $html .= print_table_row(2, "Server API", "$ENV{'SERVER_SOFTWARE'}");
  }
 if ($Config{usethreads} && !$Config{useithreads} && !$Config{use5005threads}) {
    $html .= print_table_row(2, "Thread Support",  "enabled (threads)");
  }		  
  elsif ($Config{useithreads} && !$Config{usethreads} && !$Config{use5005threads}) {
    $html .= print_table_row(2, "Thread Support",  "enabled (ithreads)");
  }
  elsif ($Config{use5005threads} && !$Config{usethreads} && !$Config{useithreads}) {
    $html .= print_table_row(2, "Thread Support",  "enabled (5005threads)");
  }
  elsif ($Config{usethreads} && $Config{useithreads} && !$Config{use5005threads}) {
    $html .= print_table_row(2, "Thread Support",  "enabled (threads, ithreads)");
  }
  elsif ($Config{usethreads} && $Config{use5005threads} && !$Config{useithreads}) {
    $html .= print_table_row(2, "Thread Support",  "enabled (threads, 5005threads)");
  }
  elsif ($Config{useithreads} && $Config{use5005threads} && !$Config{usethreads}) {
    $html .= print_table_row(2, "Thread Support",  "enabled (ithreads, 5005threads)");
  }
  elsif ($Config{usethreads} && $Config{useithreads} &&  $Config{use5005threads}) {
    $html .= print_table_row(2, "Thread Support",  "enabled (threads, ithreads, 5005threads)");
  }
  else {
    $html .= print_table_row(2, "Thread Support",  "disabled (threads, ithreads, 5005threads)");
  }
$html .= print_table_end();

  # Powered by Perl
  # Need to check for net connection
  $html .= print_box_start(0);

  
  if (check_images('http://i104.photobucket.com')) {
    $html .= add_link('ora', 'camel2');
    $html .= "This is perl, v$Config{version} built for $Config{archname}<br />Copyright (c) 1987-@{[ sprintf '%d', (localtime)[5]+1900]}, Larry Wall";
    $html .= "</td></tr></table>";
    $html .= add_link('ora', 'copyright');
  }
  else {
    $html .= "This is perl, v$Config{version} built for $Config{archname}<br />Copyright (c) 1987-@{[ sprintf '%d', (localtime)[5]+1900]}, Larry Wall";
    $html .= print_box_end();
  }

  $html .= print_hr();
  if ($HTML::Perlinfo::Common::links{'all'}) {
    $html .=<<'END_OF_HTML';
<h1>
<script type="text/javascript" language="JavaScript">
<!--
document.write("<a onclick=\"showcredits();\" href=\"javascript:void(0);\">Perl Credits</a>");
//-->
</script>
<noscript>Enable JavaScript to see the credits. Alternatively you can use perlinfo(INFO_CREDITS). 
</noscript>
</h1>
END_OF_HTML
   }
  $html .= print_hr();
  $html .= "<h1>Configuration</h1>\n";
  $html .= print_config('info_all'); 

  $html .= join '', print_section("Perl utilities"),
           print_table_start(),
	   print_table_header(2, "Name", "Location"),
	   print_table_row(2, add_link('cpan', 'h2ph'), check_path("h2ph")),
	   print_table_row(2, add_link('cpan', 'h2xs'), check_path("h2xs")),
	   print_table_row(2, add_link('cpan', 'perldoc'), check_path("perldoc")),
	   print_table_row(2, add_link('cpan', 'pod2html'), check_path("pod2html")),
	   print_table_row(2, add_link('cpan', 'pod2latex'), check_path("pod2latex")),
	   print_table_row(2, add_link('cpan', 'pod2man'), check_path("pod2man")),
	   print_table_row(2, add_link('cpan', 'pod2text'), check_path("pod2text")),
	   print_table_row(2, add_link('cpan', 'pod2usage'), check_path("pod2usage")),
	   print_table_row(2, add_link('cpan', 'podchecker'), check_path("podchecker")),
	   print_table_row(2, add_link('cpan', 'podselect'), check_path("podselect")),
	   print_table_end(),

	   print_section("Mail"),
	   print_table_start(),
	   print_table_row(2, 'SMTP', hostname()),
	   print_table_row(2, 'sendmail_path', which("sendmail")),
	   print_table_end(),

	   print_httpd(),

	   print_section("HTTP Headers Information"),
	   print_table_start(),
	   print_table_colspan_header(2, "HTTP Request Headers");
  if (defined($ENV{'SERVER_SOFTWARE'})) {
    $html .= join '',
             print_table_row(2, 'HTTP Request', "$ENV{'REQUEST_METHOD'} @{[File::Spec->abs2rel($0)]} $ENV{'SERVER_PROTOCOL'}"),
             print_table_row(2, 'Host', $ENV{'HTTP_HOST'}),
	     print_table_row(2, 'User-Agent', $ENV{'HTTP_USER_AGENT'}),
	     print_table_row(2, 'Accept', $ENV{'HTTP_ACCEPT_ENCODING'}),
	     print_table_row(2, 'Accept-Language', $ENV{'HTTP_ACCEPT_LANGUAGE'}),
	     print_table_row(2, 'Accept-Charset', $ENV{'HTTP_ACCEPT_CHARSET'}),
	     print_table_row(2, 'Keep-Alive', $ENV{'HTTP_KEEP_ALIVE'}),
	     print_table_row(2, 'Connection', $ENV{'HTTP_CONNECTION'});
   }
   $html .= print_table_end();
   return $html;
}	  
1;
