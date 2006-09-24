package HTML::Perlinfo::Modules;

use CGI::Carp 'fatalsToBrowser'; 
use File::Find;
use File::Spec;
use Carp ();
use Config qw(%Config);
use base qw(HTML::Perlinfo::Base);
use HTML::Perlinfo::Common;

$VERSION = '1.06';

sub new {

    my ($class, %params) = @_;
    $params{'title'} = exists $params{'title'} ?  $params{'title'} : 'Perl Modules';

    $class->SUPER::new(%params);

}
sub module_color_check {

	my ($module_name, $color_specs) = @_;
        if (defined $color_specs && ref($color_specs->[0]) eq 'ARRAY') {
          foreach (@{ $color_specs }) {
            return $_->[0] if lc($module_name) =~ $_->[1]; 
          }
        }
        else {
	      return $color_specs->[0] if (defined $color_specs && lc($module_name) =~ $color_specs->[1]);
	}
	return 0;
}

sub sort_modules {

  my ($modules, $sort_by) = @_;
  my @sorted_modules;  

  if ($sort_by eq 'name') {
    foreach $key (sort {lc $a cmp lc $b} keys %$modules) {
          # Check for duplicate modules
          if (ref($modules->{$key}) eq 'ARRAY') {
            foreach (@{ $modules->{$key} }) {
		        push @sorted_modules, $_;
            }
          }
          else {
	        push @sorted_modules, $modules->{$key};
	  }
     }
  }
  elsif ($sort_by eq 'version') {
    foreach $key (keys %$modules) {
	if (ref($modules->{$key}) eq 'ARRAY') {
	  @{ $modules->{$key} } = sort {$a->{'version'} cmp $b->{'version'}}@{ $modules->{$key} };
	  for (@{ $modules->{$key}}) {
	    push @sorted_modules, $_;   
          }
	}
	else {
        push @sorted_modules, $modules->{$key};
	}	
    }
    @sorted_modules = sort {$a->{'version'} cmp $b->{'version'}}@sorted_modules;
  }
  return @sorted_modules;
}

sub html_setup {
 
 my ($self, $columns, $color_specs, $section, $full_page) = @_;
 
 my $html;

 $html .= $self->print_htmlhead if $full_page; 

 my %show_columns = ( 
		'name'    => 'Module name',
		'version' => 'Version',
		'path'	  => 'Location',
		'core' 	  => 'Core',
		'desc'	  => 'Description'
	);

  $html .= $section ? print_section($section) : '';
  $html .= print_color_codes($color_specs) if $color_specs && $color_specs->[2];
  $html .= print_table_start();
  $html .= print_table_header(scalar @$columns, map{ $show_columns{$_} }@$columns);
return $html;
}

sub module_info {
   my ($module_path, $show_only, $get_desc) = @_;
   my ($mod_name, $mod_version, $mod_desc);
 
   no warnings 'all'; # silence warnings
   open(MOD, $module_path) or return 0; 
    while (<MOD>) {
	  next if /^\s*#/;
      
      unless ($mod_name) {
	    if (/^ *package +(\S+);/) { 
		    $mod_name = $1;
        }
      }
      
      unless ($mod_version) {
	
      if (/([\$*])(([\w\:\']*)\bVERSION)\b.*\=/) {
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
       $mod_version = 'unknown' if (not defined $mod_version) || ($@);
       $mod_version =~ s/^\s+|\s+$//;
      }
     }

    if ($get_desc && !$mod_desc) {
        if (/=head\d\s+NAME/) {
            local $/ = '';
            local $_;
            chomp($_ = <MOD>);
            ($mod_desc) = /^.*?-+\s*(.*?)$/ism;
        }
    }
    unless ($get_desc && !$mod_desc) {
        last if $mod_name && $mod_version; 
    }
 }
 
   close MOD;
   return 0 if (! $mod_name || $show_only && ref $show_only && lc($mod_name) !~ $show_only);
   $mod_version = 'unknown' if !($mod_version) || ($mod_version !~ /^[\.\d+_]+$/);
   $mod_desc = "<i>No description found</i>" unless $mod_desc;
   return { 'name' => $mod_name, 'version' => $mod_version, 'desc' => $mod_desc };
}

sub print_color_codes {
  my $color_specs = shift;
  my ($html, $label);
  $html .= print_table_start();
  $html .= print_table_header(1, "Module Color Codes");
  $html .= print_table_color_start();

  if (ref($color_specs->[0]) eq 'ARRAY') {
     my $count = 0;
     foreach (@{ $color_specs }) {
        $html .= "<tr>" if $count++ % 5 == 0;
        $label = $_->[2] || $_->[1];
        $html .= print_color_box($_->[0], $label);
        $html .= "</tr>" if (($count >= 5 && $count % 5 == 0)||($count >= @{$color_specs}));
     }
  }
  else {
    $label = $color_specs->[2] || $color_specs->[1];
    $html .= print_color_box($color_specs->[0], $label);
  }

  $html .= print_table_color_end();
  $html .= print_table_end();
  return $html;
}

sub print_module_results {

  my ($mod_dir, $mod_count, $from, $overall_total, $show_dir) = @_;

  my ($html, $total_amount, $searched, @mod_dir, @bad_dir, %seen);
  
  if ($show_dir) {

    $html .= print_table_start();
    $html .= print_table_header(2, "Directory", "Number of Modules");
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
           $html .= print_table_row(2, add_link('local', File::Spec->canonpath($top_dir)), $mod_count->{$top_dir});
         }
     }
    $html .= print_table_end();
  }
  else {
  # Print out directories not in @INC
    @mod_dir = grep { -d $_ && -r $_ && !$seen{$_}++ } map {File::Spec->canonpath($_)}@INC;
    my @module_paths = grep { not exists $seen{$_} }@$mod_dir;

    if (@module_paths >= 1) { 
      $html .= print_table_start();
      $html .= print_table_header(3, "Directory", "Searched", "Number of Modules");

      for my $dir (map{ File::Spec->canonpath($_) }@module_paths) {
        $searched = (grep { $_ eq $dir } @$mod_dir) ? "yes" : "no";
        my $amount_found = ($searched eq 'yes') ? $mod_count->{$dir} : '<i>unknown</i>';
        $html .= print_table_row(3, add_link('local', File::Spec->canonpath($dir)), $searched, $amount_found);
      }
      $html .= print_table_end();
    }
  
  
    $html .= print_table_start();
    $html .= print_table_header(3, "Include path (INC) directories", "Searched", "Number of Modules");
      for my $dir (@mod_dir) {
        $searched = exists $mod_count->{$dir} ? 'yes' : 'no'; 
        my $amount_found = ($searched eq 'yes') ? $mod_count->{$dir} : '<i>unknown</i>';
        $html .= print_table_row(3, add_link('local', File::Spec->canonpath($dir)), $searched, $amount_found);
      }

    $html .= print_table_end();
  }
  
  $html .= print_table_start();
  #my $view = ($from eq 'all') ? 'installed' : 
  #          ($from eq 'core') ? 'core' : 'found';

  $html .= print_table_row(2, "Total modules", $overall_total);
  $html .= print_table_end();

  $html .= print_table_end();

  return $html;

}

sub search_dir {

  my ($from, $show_only, $core_dir1, $core_dir2) = @_;

  my %seen = ();

  my @user_dir = (ref($from) eq 'ARRAY') && $show_only ne 'core' ? @{$from} :
                ($show_only eq 'core')  ? ($core_dir1, $core_dir2) : $from;

  # Make sure only unique entries and readable directories in @mod_dir
  my @mod_dir = grep { -d $_ && -r $_ && !$seen{$_}++ } map {File::Spec->canonpath($_)}@user_dir;
  if (@mod_dir != @user_dir) {

  # Looks like there might have been a problem with the directories given to us.
  # Or maybe not. @user_dir could have duplicate values and that's ok.
  # But let's still warn about any unreadable or non-directories given 

	%seen = ();
	@user_dir = grep { !$seen{$_}++ } map {File::Spec->canonpath($_)}@user_dir;
	if (@user_dir > @mod_dir) {
        #%seen = map {$_ => undef} @mod_dir;
        %seen = ();
        @seen{@mod_dir} = ();
		my @difference = grep { !$seen{$_}++ }@user_dir;
		foreach $element (@difference) {
			if (! -d $element) {
				if ( grep {$_ eq $element} map {File::Spec->canonpath($_)}@INC) {
					warn "$element is in the Perl include path, but is not a directory";
				}
				else { 
					warn "$element is not a directory"; 
				}
			} 
			elsif (! -r $element) {
				if ( grep {$_ eq $element} map {File::Spec->canonpath($_)}@INC) {
					warn "$element is in the Perl include path, but is not readable";
				}
				else { 
					warn "$element is not a readable directory"; 
				}
			}
		}
	}
  }

  error_msg("Search directories are invalid") unless @mod_dir >= 1;

  return @mod_dir;
}

sub get_input {

  my $self = shift;
  my $args = process_args(@_, \&check_module_args);
  my %input = ();
  $input{'sort_by'}     = $args->{'sort_by'} || 'name';
  $input{'from'}        = $args->{'from'} || \@INC;
  $input{'show_only'}   = $args->{'show_only'} || "";
  $input{'color_specs'} = $args->{'color'};
  $input{'link'}        = $args->{'link'};
  $input{'section'}     = exists $args->{'section'} ? $args->{'section'} : 
			  			$input{'show_only'} eq 'core' ? 'Core Perl modules installed' : '';
  $input{'full_page'}   = exists $args->{'full_page'} ? $args->{'full_page'} :  $self->{'full_page'};
  $input{'show_inc'}    = exists $args->{'show_inc'}  ? $args->{'show_inc'} : 1;
  $input{'show_dir'}    = exists $args->{'show_dir'}  ? $args->{'show_dir'} : 0;
  $input{'columns'}     = exists $args->{'columns'}   ? $args->{'columns'}  : ['name','version','desc'];
  return %input;              
 }

sub print_modules {
 
  my %input = get_input(@_);
  
  # Get ready to search 
  my $core_dir1 = File::Spec->canonpath($Config{installarchlib});
  my $core_dir2 = File::Spec->canonpath($Config{installprivlib});
  
  my @mod_dir = search_dir($input{'from'}, $input{'show_only'}, $core_dir1, $core_dir2);

  my $get_desc = grep $_ eq 'desc',@{$input{'columns'}};
  my ($overall_total, $found_mod, $mod_count) = find_modules($input{'show_only'}, $get_desc, \@mod_dir);
  
  return undef unless $overall_total;
  
  my @sorted_modules = sort_modules($found_mod, $input{'sort_by'});
  
  my $html .= html_setup( $_[0], 
                          $input{'columns'}, 
                          $input{'color_specs'}, 
                          $input{'section'}, 
                          $input{'full_page'}
                        );

  my $numberof_columns = scalar @{$input{'columns'}};
                        
  foreach my $module (@sorted_modules) {
  
       $html .= print_table_row_color(  $numberof_columns, 
                                        module_color_check($module->{'name'}, $input{'color_specs'}), 
                                        map{  
                                                    if ($_ eq 'name') {
                                                        add_link('cpan', $module->{'name'}, $input{'link'});
                                                    }
                                                    elsif ($_ eq 'core') {
					                                    (grep File::Spec->rel2abs($module->{'path'}) =~ /\Q$_/, ($core_dir1, $core_dir2)) ? 'yes' : 'no'; 
                                                    }
													elsif ($_ eq 'path') {
    													add_link('local', $module->{'path'});
													}
                                                    else {
                                                        $module->{$_};
                                                    }
                                                    
                                                 }  @{$input{'columns'}} );
  }
  
 $html .= print_table_end();
 $html .= print_module_results( \@mod_dir,
                                $mod_count, 
                                $input{'from'}, 
                                $overall_total, 
                                $input{'show_dir'}) if $input{'show_inc'};
                                
 $html .= "</div></body></html>" if $input{'full_page'}; 
  
  defined wantarray ? return $html : print $html;
                
}

sub find_modules {

  my ($show_only, $get_desc, $mod_dir) = @_;

  my ( $overall_total, $module, $total_found_inbase, $mod_version, $mod_desc, $base, $eval, $mod_info_line, $start_dir, $mod_name, $new_val, $below_inc, $last_inc_dir );
  # arrays
  my (@modinfo_array, @key_value, @inc_dir);
  # hashes
  my ( %path, %inc_path, %mod_count, %found_mod);
  my @mod_dir = @$mod_dir;
  
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
        $mod_info = module_info($File::Find::name, $show_only, $get_desc);
        return unless ref ($mod_info) eq 'HASH';

        # update the counts.
	for (@INC, grep{not exists $inc_path{$_}}@mod_dir) {
	  if (index($File::Find::name, $_) == 0) {
	    $mod_count{$_}++;
          }
	}
	$overall_total++;

    $mod_info->{'path'} = File::Spec->canonpath($File::Find::dir);
	# Check for duplicate modules
    if (exists $found_mod{$mod_info->{'name'}}) {
	  @modinfo_array = ref( $found_mod{$mod_info->{'name'}} ) eq 'ARRAY' ? @{$found_mod{$mod_info->{'name'}}} : $found_mod{$mod_info->{'name'}};
          push @modinfo_array, $mod_info;
          $new_val = [@modinfo_array];
          $found_mod{$mod_info->{'name'}} = $new_val;
        }
	else {
	  $found_mod{$mod_info->{'name'}} = $mod_info;
	}
				  
      }, $base); 
   } # end of for loop

  return ($overall_total, \%found_mod, \%mod_count);

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

This module outputs information about your Perl modules in HTML. The information includes a module's name, version, description and location. The HTML presents the module information in B<two sections>, one section is a list of modules and the other is a summary of this list. Both the list and its summary are configurable.  

Other information displayed: 

- Duplicate modules. So if you have CGI.pm installed in different locations, these duplicate modules will be shown.

- Automatic links to module documentation on CPAN (you can also provide your own URLs).
   
- The number of modules under each directory.

You can chose to show 'core' modules or you can search for specific modules. You can also define search paths. HTML::Perlinfo::Modules searches the Perl include path (from @INC) by default. You can also highlight specific modules with different colors.

=head1 METHODS

=head2 print_modules 

This is the key method in this module. It accepts optional named parameters that dictate the display of module information. The method returns undefined if no modules were found. This means that you can write code such as:

    my $modules = $m->print_modules(from=>'/home/paco');
    
    if ($modules) {
        print $modules;
    }
    else {
        print "No modules are in Paco's home directory!";
    }

The code example above will show you the modules in Paco's home directory if any are found. If none are found, the code prints the message in the else block. There is a lot more you can do with the named parameters, but you do not have to use them. For example: 

    $m->print_modules; 
	
    # The above line is the equivalent of saying:
    $m->print_modules(
			from     => \@INC,
			columns  => ['name','version','desc'],
			sort_by  => 'name',
			show_inc => 1
	 );
	
    # Alternatively, in this case, you could use the HTML::Perlinfo function to achieve the same result:
    perlinfo(INFO_MODULES); 

The optional named parameters for the print_modules method are listed below.

=head3 from

Show modules from specific directories. 

This parameter accepts 2 things: a single directory or an array reference (containing directories).

The default value is the Perl include path. This is equivalent of supplying \@INC as a value. If you want to show all of the modules on your box, you can specify '/' as a value (or the disk drive on Windows). 

=head3 columns

This parameter allows you to control the table columns in the list of modules. With this parameter, you can dictate which columns will be shown and their order. Examples:

    # Show only module names
    columns=>['name']

    # Show version numbers before names
    columns=>['version','name']
  
The column parameter accepts an array reference containing strings that represent the column names. Those names are:

=over

=item name 

The module name. This value is the namespace in the package declaration. Note that the method for retrieving the module name is not fool proof, since a module file can have multiple package declarations. HTML::Perlinfo::Modules grabs the namespace from the first package declaration that it finds.  

=item version

The version number. Divines the value of $VERSION. This uses the same method as ExtUtils::MakeMaker and all caveats therein apply. 

=item desc

The module description. The description is from the POD. Note that some modules don't have POD (or have POD without a description) and, in such cases, the message "No description found" will be shown. 

=item path

The full path to the module file on disk.

=item core

This column value (either 'yes' or 'no') will tell you if the module is core. In other words, it will tell you if the module was included in your Perl distribution. If the value is 'yes', then the module lives in either the installarchlib or the installprivlib directory listed in the config file. 

=back

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

Whenever you perform a module search, you will see a summary of your search that includes the directories searched and the number of modules found. Whether or not your search encompasses the Perl include path (@INC), you will still see these directories, along with any other directories that were actually searched. If you do not what to see this search summary, you must set show_inc to 0. The default value is 1. 

=head3 show_dir

The default value is 0. Setting this parameter to 1 will only show you the directories in which your modules were found (along with a summary of how many were found, etc). If you do not want to show a search summary, then you must use the show_inc parameter.

=head3 color

This parameter allows you to highlight modules with different colors. Highlighting specific modules is a good way to draw attention to them. 

The parameter value must be an array reference containing at least 2 elements. The first element is the color itself which can be either a hex code like #FFD700 or the name of the color. The second element, a precompiled regular expression, specifies the module(s) to color. And the third, optional element, in the array reference acts as a label in the color code section. This final element can even be a link if you so desire. 

Examples:

	color => ['red', qr/Apache::/i, "<a href='http://perl.apache.org'>Apache modules</a>"],
 	color => ['#FFD700', qr/CGI::/i] 	

Note: In the second example, there is no third element in array reference, so there will be no color code section in the HTML. Only the color-coded modules (in this case, CGI modules) will be shown. 

Alternatively, you can also change the color of the rows, by setting CSS values in the constructor. For example:

	$m = HTML::Perlinfo::Modules->new(
			leftcol_bgcolor	 => 'red',
			rightcol_bgcolor => 'red'
	);
	
	$m->print_modules( 	show_only 	=> qr/CGI::/i, 
						show_inc 	=> 0
	);

	# This next example does the same thing, but uses the color parameter in the print_modules method
    $m = HTML::Perlinfo::Modules->new();

	$m->print_modules( 	show_only 	=> qr/CGI::/i, 
					   	color	 	=> ['red', qr/CGI::/i],
						show_inc	=> 0
	);

The above example will yield the same HTML results. So which approach should you use? The CSS approach gives you greater control of the HTML presentation. The color parameter, on the other hand, only affects the row colors in the modules list. You cannot achieve that same effect using CSS. For example:

	$m->print_modules(	color	=>	['red', qr/CGI::/i],
						color	=>  ['red', qr/Apache::/i]
	);

The above example will list B<all of the modules> in @INC with CGI modules colored red and Apache modules colored blue. Another advantage of using the color parameter is that gives you the option to create a "module color coding" section above the modules list. To do so, you simply add a third element in the array reference:

	color => ['red', qr/Apache::/i, "<a href='http://perl.apache.org'>Apache modules</a>"],

For further information on customizing the HTML, including setting CSS values, please refer to the L<HTML documentation|HTML::Perlinfo::HTML>. 

=head3 section

The section parameter lets you put a heading above the module list. Example:  

    $m->print_modules(  
			show_only	=> qr/^Apache::/i,
            section		=> 'Apache/mod_perl modules',
			show_dir	=> 1,
   	);

=head3 full_page

Do you want only a fragment of HTML and not a page with body tags (among other things)? Then the full_page option is what you need to use (or a regular expression, as explained in the L<HTML documentation|HTML::Perlinfo::HTML>). This option allows you to add your own header/footer if you so desire. By default, the value is 1. Set it to 0 to output the HTML report with as little HTML as possible. 

    $m = HTML::Perlinfo::Modules->new(
		    full_page  => 0   # Change value to 1 to get a full HTML page
	);

    $m->print_modules; # You will still get an HTML page but without CSS settings or body tags

	$m->print_modules( full_page => 1); # Now you will get the complete, default HTML page. 

Note that the full_page option can be set in either the constructor or the method call. The advantage of setting it in the constructor is that every subsequent method call will have this attribute. (There is no limit to how many times you can call print_modules in a program. If calling the method more than once makes no sense to you, then you need to look at the show_only and from options.) If you set the full_page in the print_modules method, you will override its value in the object.     

=head3 link

By default, every module is linked to its documentation on search.cpan.org. However some modules, such as custom modules, would not be in CPAN and their link would not show any documentation. With the 'link' parameter you can override the CPAN link with you own URL.  

The parameter value must be an array reference containing two elements. The first element can either be a precompiled regular expression specifying the module(s) to link or the word 'all' which will link all the modules in the list. The second element is the root URL. In the link, the module name will come after the URL. So in the example below, the link for the Apache::Status module would be 'http://www.myexample.com/perldoc/Apache::Status'.

	link => [qr/Apache::/i, 'http://www.myexample.com/perldoc/']

Further information about linking is in the L<HTML documentation|HTML::Perlinfo::HTML>.

=head1 CUSTOMIZING THE HTML

HTML::Perlinfo::Modules uses the same HTML generation as its parent module, HTML::Perlinfo. 

You can capture the HTML output and manipulate it or you can alter CSS elements with object attributes. 

(Note that you can also highlight certain modules with the color parameter to print_modules.)

For further details and examples, please see the L<HTML documentation|HTML::Perlinfo::HTML> in the HTML::Perlinfo distribution.

=head1 BUGS

Please report any bugs or feature requests to C<bug-html-perlinfo@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HTML-Perlinfo>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 NOTES

If you decide to use this module in a CGI script, make sure you print out the content-type header beforehand.  

=head1 SEE ALSO

L<HTML::Perlinfo>, L<Module::Info>, L<Module::CoreList>.

=head1 AUTHOR

Mike Accardo <mikeaccardo@yahoo.com>

=head1 COPYRIGHT

   Copyright (c) 2006, Mike Accardo. All Rights Reserved.
 This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License.

=cut
