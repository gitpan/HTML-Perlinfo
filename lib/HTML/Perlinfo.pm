package HTML::Perlinfo;

# core modules
use CGI::Carp 'fatalsToBrowser';
use CGI qw(header);
use Config qw(%Config config_sh);
use Net::Domain qw(hostname);
use Carp (); 
use File::Spec;
use IO::Socket;
use POSIX qw(uname);

# non-core
use App::Info::HTTPD::Apache;
use Module::CoreList;
use File::Which;
use HTML::Perlinfo::Modules; 
use HTML::Perlinfo::Credits;
use HTML::Perlinfo::HTML;
use base 'Exporter';
our @EXPORT = qw(perlinfo);
#use Data::Dumper;
require HTML::Perlinfo::Config;
require HTML::Perlinfo::General;
require HTML::Perlinfo::Variables;
require HTML::Perlinfo::Apache;
require HTML::Perlinfo::License;

#die Data::Dumper::Dumper \%HTML::Perlinfo::;

$VERSION = '1.25';

# This is for modperl
initialize_globals();

  sub print_perl_info {

	  $flag = $_[0];
 	  my $m = HTML::Perlinfo::Modules->new();
	  my $HTML = print_htmlhead();
	  $HTML .= print_script()    if  ($flag eq "INFO_ALL");
	  $HTML .= print_credits()   if  ($flag eq "INFO_CREDITS");
	  $HTML .= print_config()    if  ($flag eq "INFO_CONFIG");
	  $HTML .= print_httpd()     if  ($flag eq "INFO_APACHE");
	  $HTML .= print_general()   if  ($flag eq "INFO_ALL"  || $flag eq "INFO_GENERAL");
	  $HTML .= print_variables() if  ($flag eq "INFO_ALL"  || $flag eq "INFO_VARIABLES");
	  $HTML .= $m->print_modules( show=>'core' ) if $flag eq "INFO_ALL";
	  $HTML .= $m->print_modules( show=>'all' )  if $flag eq "INFO_MODULES";
          $HTML .= print_license()   if  ($flag eq "INFO_ALL"  || $flag eq "INFO_LICENSE");
	  $HTML .= "</div></body></html>";
	  return $HTML;
  }
  
  #Output a page of useful information about Perl and the current request 

  sub perlinfo { 

          my $info = shift;
	  $info = 'INFO_ALL' unless defined $info;
	  Carp::croak "@_ is an invalid perlinfo() parameter"
	  if (($info !~ /INFO_ALL|INFO_GENERAL|INFO_CREDITS|INFO_CONFIG|INFO_VARIABLES|INFO_APACHE|INFO_MODULES|INFO_LICENSE/) || @_ > 1); 
	  # Andale!  Andale!  Yee-Hah! 
	  my $HTML = defined($ENV{'SERVER_SOFTWARE'}) ? header : '';
	  $HTML .= print_perl_info($info);
	  defined wantarray ? return $HTML : print $HTML;
  }
1;
__END__
=pod

=head1 NAME

HTML::Perlinfo - Display a lot of Perl information in HTML format 

=head1 SYNOPSIS

	use HTML::Perlinfo;

	perlinfo();

=head1 DESCRIPTION

This module outputs a large amount of information about your Perl installation in HTML. So far, this includes information about Perl compilation options, the Perl version, server information and environment, HTTP headers, OS version information, Perl modules, and more. 

HTML::Perlinfo is aimed at Web developers, but almost anyone using Perl may find it useful.

Since the module outputs HTML, you may want to use it in a CGI script, but you do not have to. Of course, some information, like HTTP headers, would not be available if you use the module at the command-line.  

=head1 OPTIONS

There are 6 options to pass to the perlinfo funtion. All of these options are also object methods. The key difference is their case: Captilize the option name when passing it to the function and use only lower-case letters when using the object-oriented approach.

=over

=item INFO_GENERAL

The configuration line, build date, Web Server, System and more.

=item INFO_VARIABLES

Shows all predefined variables from EGPCS (Environment, GET, POST, Cookie, Server).

=item INFO_CONFIG

All configuration values from config_sh. INFO_ALL shows only some values.

=item INFO_APACHE

Apache HTTP server information.  

=item INFO_MODULES 

All installed modules, their version number and more. INFO_ALL shows only core modules.
Please also see L<HTML::Perlinfo::Modules>.

=item INFO_LICENSE 

Perl license information.

=item INFO_CREDITS

Shows the credits for Perl, listing the Perl pumpkings, developers, module authors, etc.

=item INFO_ALL

Shows all of the above. This is the default value.

=back

=head1 CUSTOMIZING THE HTML

You can capture the HTML output and manipulate it or you can alter CSS elements with object methods.

For further details and examples, please see the L<HTML documentation|HTML::Perlinfo::HTML> in the HTML::Perlinfo distribution.

=head1 SECURITY

Displaying detailed server information on the internet is not a good idea if security is a top concern, as it is for most system administrators, and HTML::Perlinfo reveals a lot of information about the local environment. While restricting what system users can publish online is wise, you can also hinder them from using the module by installing it outside of the usual module directories (see perldoc -q lib). Of course, preventing users from installing the module in their own home directories is another matter entirely. 

=head1 REQUIREMENTS

HTML::Perlinfo requires only 3 non-core modules. These 3 modules are:

L<App::Info> (for some HTTPD information)

L<Module::CoreList> (for Perl release dates)

L<File::Which> (for searching the path)

=head1 NOTES

Some might notice that HTML::Perlinfo shares the look and feel of the PHP function phpinfo. It was originally inspired by that function and was first in the PHP namespace as PHP::Perlinfo, which is no longer available on CPAN.   

=head1 BUGS

Please report any bugs or feature requests to C<bug-html-perlinfo@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-Perlinfo>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SEE ALSO

Perl Diver and Perl Digger are free CGI scripts that offer similar information.  

Perl Diver:  L<http://www.scriptsolutions.com/programs/free/perldiver/>

Perl Digger: L<http://sniptools.com/perldigger>

Other modules worth mentioning:

L<Config>. You can also use "perl -V" to see a configuration summary at the command-line.

L<Apache::Status>, L<App::Info>, L<Probe::Perl>, L<Module::CoreList>, L<Module::Info>, among others.

Also included in the Perlinfo distribution: L<HTML::Perlinfo::Modules> 

=head1 AUTHOR

Mike Accardo <mikeaccardo@yahoo.com>

=head1 COPYRIGHT

   Copyright (c) 2006, Mike Accardo. All Rights Reserved.
 This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License.

=cut

