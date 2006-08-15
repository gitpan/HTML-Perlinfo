package HTML::Perlinfo;

# core modules
use CGI::Carp 'fatalsToBrowser';
use Carp (); 

# non-core
use HTML::Perlinfo::Apache;
use HTML::Perlinfo::Modules; 
use HTML::Perlinfo::Common;
use base qw(Exporter HTML::Perlinfo::Base);
our @EXPORT = qw(perlinfo);

$VERSION = '1.42';

# This function is a wrapper for the functional interface
sub perlinfo {
  my $info = shift;
  $info = 'info_all' unless defined $info;

  error_msg("@_ is an invalid perlinfo() parameter")
  if (($info !~ /info_all|info_general|info_credits|info_config|info_variables|info_apache|info_modules|info_license/i) || @_ > 1); 
  
  my $p = HTML::Perlinfo->new();

  if (lc $info eq 'info_all') {
    $p->info_all;
  }
  elsif (lc $info eq 'info_general') {
    $p->info_general;
  }
  elsif (lc $info eq 'info_variables') {
    $p->info_variables;
  }
  elsif (lc $info eq 'info_credits') {
    $p->info_credits;
  }
  elsif (lc $info eq 'info_config') {
    $p->info_config;
  }
  elsif (lc $info eq 'info_apache') {
    $p->info_apache;
  }
  else {
    $p->info_modules;
  }
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

There are 8 options to pass to the perlinfo funtion. All of these options are also object methods. The key difference is their case: Captilize the option name when passing it to the function and use only lower-case letters when using the object-oriented approach.

=over

=item INFO_GENERAL

The configuration line, build date, Web Server, System and more.

=item INFO_VARIABLES

Shows all predefined variables from EGPCS (Environment, GET, POST, Cookie, Server).

=item INFO_CONFIG

All configuration values from config_sh. INFO_ALL shows only some values.

=item INFO_APACHE

Apache HTTP server information, including mod_perl information.  

=item INFO_MODULES 

All installed modules, their version number and much more. INFO_ALL shows only core modules.
Please also see L<HTML::Perlinfo::Modules>.

=item INFO_LICENSE 

Perl license information.

=item INFO_CREDITS

Shows the credits for Perl, listing the Perl pumpkings, developers, module authors, etc.

=item INFO_ALL

Shows all of the above defaults. This is the default value.

=back

=head1 CUSTOMIZING THE HTML

You can capture the HTML output and manipulate it or you can alter CSS elements with object attributes.

For further details and examples, please see the L<HTML documentation|HTML::Perlinfo::HTML> in the HTML::Perlinfo distribution.

=head1 SECURITY

Displaying detailed server information on the internet is not a good idea and HTML::Perlinfo reveals a lot of information about the local environment. While restricting what system users can publish online is wise, you can also hinder them from using the module by installing it outside of the usual module directories (see perldoc -q lib). Of course, preventing users from installing the module in their own home directories is another matter entirely. 

=head1 REQUIREMENTS

HTML::Perlinfo requires only 3 non-core modules. These 3 modules are:

L<App::Info> - for some HTTPD information

L<Module::CoreList> - for Perl release dates

L<File::Which> - for searching the path

=head1 NOTES

Some might notice that HTML::Perlinfo shares the look and feel of the PHP function phpinfo. It was originally inspired by that function and was first released in 2004 as PHP::Perlinfo, which is no longer available on CPAN.   

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

