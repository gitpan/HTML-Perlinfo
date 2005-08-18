package HTML::Perlinfo;

use App::Info::HTTPD::Apache;
use CGI::Carp 'fatalsToBrowser';
use CGI qw(header);
use Config qw(%Config config_sh);
use Net::Domain qw(hostname);
use Carp (); 
use Module::CoreList;
use File::Find;
use File::Spec;
use IO::Socket;
use File::Which;
use POSIX qw(uname);
 
require Exporter;
require HTML::Perlinfo::HTML; 
require HTML::Perlinfo::Credits;
require HTML::Perlinfo::Config;
require HTML::Perlinfo::General;
require HTML::Perlinfo::Variables;
require HTML::Perlinfo::Apache;
require HTML::Perlinfo::Modules;
require HTML::Perlinfo::License;

@HTML::Perlinfo::ISA    = qw(Exporter);
@HTML::Perlinfo::EXPORT = qw(perlinfo);

$VERSION = '1.00';

# This is for modperl
initialize_globals();

  sub perl_print_info {

	  $flag = $_[0];
	  my $HTML = perl_info_print_htmlhead();
	  $HTML .= perl_info_print_script()  if ($flag eq "INFO_ALL");
	  $HTML .= perl_info_print_credits() if ($flag eq "INFO_CREDITS");
	  $HTML .= perl_info_print_config() if ($flag eq "INFO_CONFIG");
	  $HTML .= perl_info_print_httpd() if ($flag eq "INFO_APACHE");
	  $HTML .= perl_info_print_general() if ($flag eq "INFO_ALL" || $flag eq "INFO_GENERAL");
	  $HTML .= perl_info_print_variables() if  ($flag eq "INFO_ALL" || $flag eq "INFO_VARIABLES");
          $HTML .= perl_info_print_modules()   if  ($flag eq "INFO_ALL" || $flag eq "INFO_MODULES");
          $HTML .= perl_info_print_license()   if  ($flag eq  "INFO_ALL" || $flag eq "INFO_LICENSE");
	  $HTML .= "</div></body></html>";
	  return $HTML;
  }

  #Output a page of useful information about Perl and the current request 

  sub perlinfo { 

	  my $INFO = $_[0] =~ /^\s*$/ ? "INFO_ALL" : $_[0];
	  Carp::croak "@_ is an invalid perlinfo() parameter"
	  if (($INFO !~ /INFO_ALL|INFO_GENERAL|INFO_CREDITS|INFO_CONFIG|INFO_VARIABLES|INFO_APACHE|INFO_MODULES|INFO_LICENSE/) || @_ > 1); 
	  # Andale!  Andale!  Yee-Hah! 
	  my $HTML = defined($ENV{'SERVER_SOFTWARE'}) ? header : '';
	  $HTML .= perl_print_info($INFO);
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

=item INFO_LICENSE 

Perl license information.

=item INFO_CREDITS

Shows the credits for Perl, listing the Perl pumpkings, developers, module authors, etc.

=item INFO_ALL

Shows all of the above. This is the default value.

=back

=head1 OBJECT METHODS

These object methods allow you to change the HTML CSS settings to achieve a stylish effect. When using them, you must pass them a parameter. Please see your favorite HTML guide for acceptable CSS values. Refer to the HTML source code of perlinfo for the defaults.

Method name/Corresponding CSS element

 bg_image 		/ background_image
 bg_position 		/ background_position
 bg_repeat 		/ background_repeat
 bg_attribute 		/ background_attribute 
 bg_color 		/ background_color
 ft_family 		/ font_familty 
 ft_color 		/ font_color
 lk_color 		/ link color
 lk_decoration 		/ link text-decoration  
 lk_bgcolor 		/ link background-color 
 lk_hvdecoration 	/ link hover text-decoration 
 header_bgcolor 	/ table header background-color 
 header_ftcolor 	/ table header font color
 leftcol_bgcolor	/ background-color of leftmost table cell  
 leftcol_ftcolor 	/ font color of left table cell
 rightcol_bgcolor	/ background-color of right table cell  
 rightcol_ftcolor	/ font color of right table cell

Remember that there are more methods (the info options listed above). 

=head1 EXAMPLES

Function-oriented style:

	# Show all information, defaults to INFO_ALL
	perlinfo();

	# Show only module information. This shows all installed modules.
	perlinfo(INFO_MODULES);

Object-oriented style:

	$p = new HTML::Perlinfo;
	$p->bg_color("#eae5c8");
	$p->info_all;

	# You can also set the CSS values in the constructor!
    	$p = HTML::Perlinfo->new(
		bg_image  => 'http://www.tropic.org.uk/~edward/ctrip/images/camel.gif',
		bg_repeat => 'yes-repeat'
	);
	$p->info_all;

More examples . . .

	# This is wrong (no capitals!)
	$p->INFO_CREDITS;

	# But this is correct
	perlinfo(INFO_CREDITS);
	
	# Ditto
	$p->info_credits;

=head1 NOTES

This is a work in progress. So expect to see big, exciting changes from version to version. 

Some might notice that HTML::Perlinfo shares the look and feel of the PHP function phpinfo. It was originally based on that function and was first in the PHP namespace as PHP::Perlinfo, which will no longer be available on CPAN.   

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

=head1 AUTHOR

Mike Accardo <mikeaccardo@yahoo.com>

=head1 COPYRIGHT

   Copyright (c) 2005, Mike Accardo. All Rights Reserved.
 This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License.

=cut

