package HTML::Perlinfo::Modules;

use CGI::Carp 'fatalsToBrowser'; 
use File::Find;
use File::Spec;
use Carp ();
use Config qw(%Config);
use base qw(HTML::Perlinfo::Base);
use HTML::Perlinfo::Common;
$VERSION = '1.02';

sub module_color_check {

	my ($module_name, $color_specs) = @_;
        if (ref($color_specs->[0]) eq 'ARRAY') {
          foreach (@{ $color_specs }) {
            return $_->[0] if lc($module_name) =~ $_->[1]; 
          }
        }
        else {
	  return $color_specs->[0] if lc($module_name) =~ $color_specs->[1];
	}
	return 0;
}

sub sort_modules {

  my ($modules, $sort_by) = @_;
  my @sorted_modules;  

  if ($sort_by eq 'name') {
    foreach $key (sort {lc $a cmp lc $b} keys %$modules) {
          # Check for duplicate modules
          if (ref($modules->{$key}[0]) eq 'ARRAY') {
            foreach (@{ $modules->{$key} }) {
                   unshift @$_, $key;
		   push @sorted_modules, $_;
            }
          }
          else {
            unshift @{$modules->{$key}}, $key;
	    push @sorted_modules, $modules->{$key};
	  }
     }
  }
  elsif ($sort_by eq 'version') {
    foreach $key (keys %$modules) {
	if (ref($modules->{$key}[0]) eq 'ARRAY') {
	  @{ $modules->{$key} } = sort {$a->[0] cmp $b->[0]}@{ $modules->{$key} };
	  for (@{ $modules->{$key}}) {
	    unshift @$_, $key;
	    push @sorted_modules, $_;   
          }
	}
	else {
	  unshift @{$modules->{$key}}, $key;
          push @sorted_modules, $modules->{$key};
	}	
    }
    @sorted_modules = sort {$a->[1] cmp $b->[1]}@sorted_modules;
  }
  return @sorted_modules;
}

sub html_setup {
 
 my ($self, $show_only, $color_specs, $section) = @_;
 
 my $HTML;

if ($show_only eq 'core') {
                $HTML .= $section ? print_section($section) : print_section("Core Perl modules installed");
                $HTML .= print_table_start();
                $HTML .= print_table_header(3, "Module name", "Version", "Location");
 }
#elsif ($from eq 'all') {
#               $HTML .= $section ? print_section($section) : print_section("All Perl modules installed");
#		$HTML .= print_color_codes($color_specs) if $color_specs;
#                $HTML .= print_table_start();
#                $HTML .= print_table_header(4, "Module name", "Version", "Core", "Location");
# }
 else {
	        $HTML .= $section ? print_section($section) : '';
                $HTML .= print_color_codes($color_specs) if $color_specs;
                $HTML .= print_table_start();
                $HTML .= print_table_header(4, "Module name", "Version", "Core", "Location");
 }

return $HTML;

}

sub module_info {
   my ($module_path, $show_only) = @_;
   my ($mod_name, $mod_version, @mod_info);
   no warnings 'all'; # silence warnings
   open(MOD, $module_path) or return 0; # Be nice. Someone might want to keep things private
   my $inpod = 0;
    while (<MOD>) {
      if (/^ *package +(\S+);/) {       # This is not fool proof and even fails one of the perlinfo modules!
        $mod_name = $1 unless $mod_name; 
      }
      $inpod = /^=(?!cut)/ ? 1 : /^=cut/ ? 0 : $inpod;
      next if $inpod || /^\s*#/;

      chomp;
      next unless /([\$*])(([\w\:\']*)\bVERSION)\b.*\=/;

      my $eval = qq{
        package HTML::Perlinfo::_version;
        no strict;

        local $1$2;
        \$$2=undef; do {
        $_
        }; \$$2
      };
      $mod_version = eval($eval);
      # Again let us be nice here.
      $mod_version = undef if (not defined $mod_version) || ($@);
      last;
    }
   close MOD;
   return 0 if (! $mod_name || $show_only && ref $show_only && lc($mod_name) !~ $show_only);
   $mod_version = "unknown" if !($mod_version) || ($mod_version !~ /^\d+(\.\d+)*$/);
   push @mod_info, $mod_name, $mod_version;
   return \@mod_info;
}


sub print_each_module {

  my ($sorted_modules, $show_only, $color_specs, $core_dir1, $core_dir2, $link) = @_;
  my $HTML;
  if ($show_only eq 'core') {
          if ($color_specs) {
            for $module (@$sorted_modules) {
                my $row_color = module_color_check($module->[0], $color_specs);
                if ($row_color) {
                  $HTML .= print_table_row_color(3,
                                $row_color,
                                add_link('cpan', $module->[0], $link),
                                $module->[1],
                                $module->[2]
                           );
                }
                else {
                  $HTML .= print_table_row(3,
 				add_link('cpan', $module->[0], $link),
                                $module->[1],
                                $module->[2]
                           );
                }
            }
          }
          else {
            for $module (@$sorted_modules) {
                $HTML .= print_table_row(3,
                                add_link('cpan', $module->[0], $link),
                                $module->[1],
                                $module->[2]
                           );
            }
          }
        }
  else {
          if ($color_specs) {
            for $module (@$sorted_modules) {
                $is_core = (grep File::Spec->rel2abs($module->[2]) =~ /\Q$_/, ($core_dir1, $core_dir2)) ? "yes" : "no";
                my $row_color = module_color_check($module->[0], $color_specs);
                if ($row_color) {
                  $HTML .= print_table_row_color(4,
                                $row_color,
                                add_link('cpan', $module->[0], $link),
                                $module->[1],
                                $is_core,
                                $module->[2]
                           );
                }
                else {
                  $HTML .= print_table_row(4,
                                add_link('cpan', $module->[0], $link),
                                $module->[1],
                                $is_core,
                                $module->[2]
                           );
                }
            }
          }
          else {
            for $module (@$sorted_modules) {
                $is_core = (grep File::Spec->rel2abs($module->[2]) =~ /\Q$_/, ($core_dir1, $core_dir2)) ? "yes" : "no";
                $HTML .= print_table_row(4,
                                add_link('cpan', $module->[0], $link),
                                $module->[1],
                                $is_core,
                                $module->[2]
                          );
            }
          }
  }
 $HTML .= print_table_end();
 return $HTML;

}

sub print_color_codes {
  my $color_specs = shift;
  my ($HTML, $label);
  $HTML .= print_table_start();
  $HTML .= print_table_header(1, "Module Color Codes");
  $HTML .= print_table_color_start();

  if (ref($color_specs->[0]) eq 'ARRAY') {
     my $count = 0;
     foreach (@{ $color_specs }) {
        $HTML .= "<tr>" if $count++ % 5 == 0;
        $label = $_->[2] || $_->[1];
        $HTML .= print_color_box($_->[0], $label);
        $HTML .= "</tr>" if (($count >= 5 && $count % 5 == 0)||($count >= @{$color_specs}));
     }
  }
  else {
    $label = $color_specs->[2] || $color_specs->[1];
    $HTML .= print_color_box($color_specs->[0], $label);
  }

  $HTML .= print_table_color_end();
  $HTML .= print_table_end();
  return $HTML;
}

sub print_module_results {

  my ($mod_dir, $mod_count, $from, $overall_total, $show_dir) = @_;

  my ($HTML, $total_amount, $searched, @mod_dir, @bad_dir, %seen);
  
  if ($show_dir) {

    $HTML .= print_table_start();
    $HTML .= print_table_header(2, "Directory", "Number of Modules");
     for my $dir (keys %{$mod_count}) {
         my $amount_found = $mod_count->{$dir};
         push (@mod_dir, $dir) if $amount_found;
     }
     
     for my $dir1 (@mod_dir) {
         for my $dir2 (@mod_dir) {
            if ($dir1 ne $dir2 && $dir2 =~ /^$dir1/) {
                push @bad_dir, $dir2;
            }
         }
     }
     for my $top_dir (@mod_dir) {
         unless (grep{$_ eq $top_dir }@bad_dir) {
           $HTML .= print_table_row(2, add_link('local', File::Spec->canonpath($top_dir)), $mod_count->{$top_dir});
         }
     }
    $HTML .= print_table_end();
  }
  else {
  # Print out directories not in @INC
    @mod_dir = grep { -d $_ && -r $_ && !$seen{$_}++ } map {File::Spec->canonpath($_)}@INC;
    my @module_paths = grep { not exists $seen{$_} }@$mod_dir;

    if (@module_paths >= 1) { 
      $HTML .= print_table_start();
      $HTML .= print_table_header(3, "Directory", "Searched", "Number of Modules");

      for my $dir (map{ File::Spec->canonpath($_) }@module_paths) {
        $searched = (grep { $_ eq $dir } @$mod_dir) ? "yes" : "no";
        my $amount_found = ($searched eq 'yes') ? $mod_count->{$dir} : '<i>unknown</i>';
        $HTML .= print_table_row(3, add_link('local', File::Spec->canonpath($dir)), $searched, $amount_found);
      }
      $HTML .= print_table_end();
    }
  
  
    $HTML .= print_table_start();
    $HTML .= print_table_header(3, "Include path (INC) directories", "Searched", "Number of Modules");
      for my $dir (@mod_dir) {
        $searched = exists $mod_count->{$dir} ? 'yes' : 'no'; 
        my $amount_found = ($searched eq 'yes') ? $mod_count->{$dir} : '<i>unknown</i>';
        $HTML .= print_table_row(3, add_link('local', File::Spec->canonpath($dir)), $searched, $amount_found);
      }

    $HTML .= print_table_end();
  }
  
  $HTML .= print_table_start();
  #my $view = ($from eq 'all') ? 'installed' : 
  #          ($from eq 'core') ? 'core' : 'found';

  $HTML .= print_table_row(2, "Total modules", $overall_total);
  $HTML .= print_table_end();

  $HTML .= print_table_end();

  return $HTML;

}

sub check_my_args {

  my ($key, $value) = @_;
  my ($message, %allowed);
  @allowed{qw(from sort_by color link show_only section show_inc show_dir)} = ();

  if (not exists $allowed{$key}) {
    $message = "$key is an invalid print_modules parameter";
  }
  elsif ($key eq 'sort_by' && $value !~ /^(?:name|version)$/i) {
    $message = "$value is an invalid sort"; 
  }
  elsif ($key =~ /^(?:color|link)$/ && ref($value) ne 'ARRAY') {
    $message = "The $key parameter value is not an array reference";
  }
  elsif ($key eq 'color' && @{$value} <= 1) {
    $message = "You didn't specify a module to color";
  }
  elsif ($key eq 'color' && ref($value->[1]) ne 'Regexp') {
    $message = "Not a properly-formatted regular expression in the $key parameter value";
  }
  elsif ($key eq 'link' && @{$value} <= 1 && $value->[0] != 0) {
    $message = "You didn't provide a URL for the $key parameter";
  }
  elsif ($key eq 'show_only' && (ref($value) ne 'Regexp') && lc $value ne 'core') {
    $message = "$value is an invalid value for the $key parameter";
  }
  elsif ($key eq 'link' && ($value->[0] ne 'all' && $value->[0] != 0 && ref($value->[0]) ne 'Regexp')) {
    $message = "Invalid first element in the $key parameter value";
  }
  error_msg("$message") if $message;
}

sub search_dir {

  my ($from, $show_only, $core_dir1, $core_dir2) = @_;

  my %seen;

  my @mod_dir = (ref($from) eq 'ARRAY') && $show_only ne 'core' ? @{$from} :
                ($show_only eq 'core')  ? ($core_dir1, $core_dir2) : $from;

  # Make sure only unique entries and readable directories in @mod_dir
  @mod_dir = grep { -d $_ && -r $_ && !$seen{$_}++ } map {File::Spec->canonpath($_)}@mod_dir;

  error_msg("Search directories are invalid") unless @mod_dir >= 1;

  return @mod_dir;

}

sub print_modules {

  my $self = shift;
  my $args = process_args(@_, \&check_my_args);
  my $sort_by     = $args->{'sort_by'} || 'name';
  my $from        = $args->{'from'} || \@INC;
  my $show_only   = $args->{'show_only'} || "";
  my $color_specs = $args->{'color'};
  my $link        = $args->{'link'};
  my $section     = $args->{'section'};
  my $show_inc    = exists $args->{'show_inc'} ? $args->{'show_inc'} : 1;
  my $show_dir    = exists $args->{'show_dir'} ? $args->{'show_dir'} : 0;
 
 
  my ( $overall_total, $total_found_inbase, $mod_version, $base, $eval, $mod_info_line, $start_dir, $mod_name, $new_val, $below_inc, $last_inc_dir );
  # arrays
  my (@modinfo_array, @key_value, @inc_dir);
  # hashes
  my ( %path, %inc_path, %mod_count, %found_mod);

  my $HTML .= html_setup($self, $show_only, $color_specs, $section); 

  # Get ready to search 
  my $core_dir1 = File::Spec->canonpath($Config{installarchlib});
  my $core_dir2 = File::Spec->canonpath($Config{installprivlib});
  
  my @mod_dir = search_dir($from, $show_only, $core_dir1, $core_dir2);
  @path{@mod_dir} = ();
  @inc_path{@INC} = ();      
  for $base (@mod_dir) {  
    find ( sub { 
	for (@INC, @mod_dir) {
	  if (index($File::Find::name, $_) == 0) {
	  # lets record it unless we already have hit the dir
	    $mod_count{$_} = 0 unless exists $mod_count{$_};
	  }
        }		
	# This prevents mod_dir dirs from being searched again when you have a dir within a dir 
        $File::Find::prune = 1, return if exists $path{$File::Find::name} && $File::Find::name ne $File::Find::topdir; 

 	# make sure we are dealing with a module
        return unless $File::Find::name =~ m/\.pm$/; 
        $mod_info = module_info($File::Find::name, $show_only);
        return unless ref ($mod_info) eq 'ARRAY';

        # update the counts.
	for (@INC, grep{not exists $inc_path{$_}}@mod_dir) {
	  if (index($File::Find::name, $_) == 0) {
	    $mod_count{$_}++;
          }
	}
	$overall_total++;

	$mod_name = $mod_info->[0];
	$mod_version = $mod_info->[1];
	$mod_info_line = [$mod_version, add_link('local', File::Spec->canonpath($File::Find::dir))];  
	# Check for duplicate modules
        if (exists $found_mod{$mod_name}) {
	  @modinfo_array = ref(${$found_mod{$mod_name}}[0]) eq 'ARRAY' ? @{$found_mod{$mod_name}} : $found_mod{$mod_name};
          push @modinfo_array, $mod_info_line;
          $new_val = [@modinfo_array];
          $found_mod{$mod_name} = $new_val;
        }
	else {
	  $found_mod{$mod_name} = $mod_info_line;
	}
				  
      }, $base); 
   } # end of for loop

   my @sorted_modules = sort_modules(\%found_mod, $sort_by);
   $HTML .= print_each_module(\@sorted_modules, $show_only, $color_specs, $core_dir1, $core_dir2, $link);      
   $HTML .= print_module_results(\@mod_dir,\%mod_count, $from, $overall_total, $show_dir) if $show_inc;
   #$HTML .= "</div></body></html>" unless ((caller)[0] eq 'HTML::Perlinfo::General' || !$self->{full_page} || !$full_page);

   defined wantarray ? return $HTML : print $HTML;

}

1;
__END__
=pod

=head1 NAME

HTML::Perlinfo::Modules - Display a lot of module information in HTML format 

=head1 SYNOPSIS

	use HTML::Perlinfo::Modules;

	my $m = HTML::Perlinfo::Modules->new();
	$m->print_modules;

=head1 DESCRIPTION

This module outputs information about your Perl modules in HTML. By default, the module names are sorted alphabetically in a list. This list is also sortable by version number. 

Other information displayed: 

- Duplicate modules. So if you have CGI.pm installed in different locations, these duplicate modules will be shown.

- Automatic links to module documentation on CPAN (you can also provide your own URLs).
   
- The number of modules under each directory.

You can chose to show 'core' modules or you can search for specific modules. You can also define search paths. HTML::Perlinfo::Modules searches the Perl include path (from @INC) by default. 

You can also highlight specific modules with different colors.

=head1 EXAMPLES

	# List all modules, sort them by version, highlight DBI/DBD modules in blue, and label them 'Database modules' 
        $m->print_modules(
                sort_by => 'version',
		color   => ['blue', qr/^(?:dbi|dbd)::/i, 'Database modules']
	 );

	# List all of the installed modules sorted alphabetically
	$m->print_modules;

	# Show me the same thing but turn off the links
	$m->print_modules( links => [0]);

	# List all modules under the /usr directory, override the Apache modules docs with my own root URL, 
        # and highlight CGI modules in red and Win32 modules in yellow
	$m->print_modules(
                from      => '/usr',
  		link      => [qr/Apache::/i, 'http://www.myexample.com/perldoc/'], 
                color     => ['red', qr/CGI::/i, 'CGI modules'],
                color     => ['yellow', qr/Win32::/i, 'Windoze modules']
         );

=head1 METHODS

=head2 print_modules 

This is the key method in this module. It accepts optional named parameters that dictate the display of module information. Those optional named parameters are:

=head3 from

Show modules from specific directories. 

This parameter accepts 2 things: a single directory or an array reference (containing directories).

The default value is the Perl include path. This is equivalent of supplying \@INC as a value. If you want to show all of the modules on your box, you can specify '/' as a value (or the disk drive on Windows). 

=head3 sort_by

You use this parameter to sort the modules. Values can be either 'version' for version number sorting (in descending order) or 'name' for alphabetical sorting (the default).

=head3 show_only

This parameter acts like a filter and only shows you the modules (more specifically, the package names) you request. So if, for example, you wanted to only show modules in the Net namspace, you would use the show_only parameter. It is probably the most useful option available for the print_modules method. With this option, you can use HTML::Perlinfo::Modules as a search engine tool for your local Perl modules. Observe:

    $m->print_modules(
                show_only => qr/MYCOMPANY::/i,
                section   => 'My Company's Custom Perl Modules',
                show_dir  => 1
        );

The example above will print out every module in the 'MYCOMPANY' namespace in the Perl include path (@INC). The list will be entitled 'My Company's Custom Perl Modules' and because show_dir is set to 1, the list will only show the directories in which these modules were found along with how many are present in each directory. 

In addition to a precompiled regular expression, show_only also accepts the word 'core', a value that will show you all of the core Perl modules (in the installarchlib and installprivlib directories from the config file). 

=head3 show_inc

Whenever you perform a module search, you will see a summary of your search that includes the directories searched and the number of modules found. Whether or not your search encompasses the Perl include path (@INC), you will still see the directories in this special path, along with any directories that were actually searched. If you do not what to see this search summary, you must set show_inc to 0. The default value is 1. 

=head3 show_dir

Setting this parameter to 1 will only show you the directories in which your modules were found (along with a summary of how many were found, etc). The default value is 0 which shows you the full list of directories in your include path (from @INC), including the directories where your modules were found. If you do not want to show any directories/summary, then you must use the show_inc parameter.

=head3 color

This parameter allows you to highlight modules with different colors. Highlighting specific modules is a good way to draw attention to them. 

The parameter value must be an array reference containing at least 2 elements. The first element is the color itself which can be either a hex code like #FFD700 or the name of the color. The second element, a precompiled regular expression, specifies the module(s) to color. And the third, optional element in the array reference acts as a label in the color code section. This final element can even be a link if you so desire. 

Examples:

	color => ['red', qr/Apache::/i, "<a href='http://perl.apache.org'>Apache modules</a>"],
 	color => ['#FFD700', qr/CGI/i] 	

In the second example, the label defaults to '(?i-xsm:CGI)' since there is no third element. 


=head3 section

Ever wanted to call your modules by a petname? Or how about just labeling your company's modules with a heading, so you can more quickly discern what you are looking at? The section parameter lets you do that!  

	$m->print_modules( show_only=>qr/^(?:DBI::|DBD::)|Oracle/i,
                           show_dir=>1,
                           section=>'Database modules');

	$m->print_modules( show_only=>qr/^Apache::/i,
                           show_dir=>1,
                           section=>'Apache/mod_perl modules');

=head3 link

By default, every module is linked to its documentation on search.cpan.org. However some modules, such as custom modules, would not be in CPAN and their link would not show any documentation. With the 'link' parameter you can override the CPAN link with you own URL.  

The parameter value must be an array reference containing two elements. The first element can either be a precompiled regular expression specifying the module(s) to link or the word 'all' which will link all the modules in the list. The second element is the root URL. In the link, the module name will come after the URL. So in the example below, the link for the Apache::Status module would be 'http://www.myexample.com/perldoc/Apache::Status'.

	link => [qr/Apache::/i, 'http://www.myexample.com/perldoc/']

Further information about linking is in the L<HTML documentation|HTML::Perlinfo::HTML>.

=head1 CUSTOMIZING THE HTML

HTML::Perlinfo::Modules uses the same HTML generation as its parent module, HTML::Perlinfo. 

You can capture the HTML output and manipulate it or you can alter CSS elements with object methods. 

(Note that you can also highlight certain modules with the color parameter to print_modules.)

For further details and examples, please see the L<HTML documentation|HTML::Perlinfo::HTML> in the HTML::Perlinfo distribution.

=head1 BUGS

Please report any bugs or feature requests to C<bug-html-perlinfo-modules@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-Perlinfo-Modules>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 NOTES

Suggestions/comments/code welcomed.    

=head1 SEE ALSO

L<HTML::Perlinfo>, L<Module::Info>, L<Module::CoreList>.

=head1 AUTHOR

Mike Accardo <mikeaccardo@yahoo.com>

=head1 COPYRIGHT

   Copyright (c) 2006, Mike Accardo. All Rights Reserved.
 This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License.

=cut
