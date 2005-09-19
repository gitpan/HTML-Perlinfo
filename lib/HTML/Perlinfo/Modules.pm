sub module_check {

  	return 0 unless $highlight;	
	my $module = shift;
	for my $namespace (keys %colors) {
	  if ($module =~ /$namespace/i) {
		return $namespace;
	  }
        }
	return 0;
}

sub print_all_modules {
	my ($HTML, $total_found, $mod_version, $base, $eval, $mod_info, $inpod, $is_core, $core_dir1, $core_dir2, $start_dir, $module, $new_val);
        my ( @mod_count, @mod_dir, @modinfo_array);
        my ( %path, %found_mod, %seen); 


	$core_dir1 = File::Spec->canonpath($Config{installarchlib});
	$core_dir2 = File::Spec->canonpath($Config{installprivlib});

	@path{@INC} = ();
	@mod_dir = ($flag eq "INFO_ALL") ? ($core_dir1, $core_dir2) : @INC;

	# Make sure only unique entries and readable directories in @mod_dir
	@mod_dir = grep { -d $_ && -r $_ && !$seen{$_}++ } map {File::Spec->canonpath($_)}@mod_dir; 
	
	for $base (@mod_dir) { 
		find ( sub { 
				$start_dir = File::Spec->rel2abs($File::Find::topdir);
				$File::Find::prune = 1, return if
				exists $path{$File::Find::dir} and $File::Find::dir ne $start_dir;
				$module = substr $File::Find::name, length $start_dir;
				return unless $module =~ s/\.pm$//;

				$module =~ s!^/+!!;
				$module =~ s!/!::!g;

				# Get the version	
				# Thieved from ExtUtils::MM_Unix 1.12603	    

				open(MOD, $_) or return; # Be nice. Someone might want to keep things private
				$inpod = 0;
				while (<MOD>) {
					$inpod = /^=(?!cut)/ ? 1 : /^=cut/ ? 0 : $inpod;
					next if $inpod || /^\s*#/;

					chomp;
					next unless /([\$*])(([\w\:\']*)\bVERSION)\b.*\=/;
					$eval = qq{
					package HTML::Perlinfo::_version;
					no strict;

					local $1$2;
					\$$2=undef; do {
					$_
					}; \$$2
				};
				local $^W = 0;
				$mod_version = eval($eval);
  				# Again let us be nice here. 
				$mod_version = "undef" if (not defined $mod_version) || ($@);
				last;
			}
			close MOD;
			$mod_version = "unknown" if !($mod_version) || ($mod_version !~ /^\d+(\.\d+)*$/);

			$mod_info = [$mod_version, links('local', File::Spec->canonpath($File::Find::dir))];  

			if (exists $found_mod{$module}) {
				@modinfo_array = $found_mod{$module};
        			push @modinfo_array, $mod_info;
        			$new_val = [@modinfo_array];
        			$found_mod{$module} = $new_val;
			}
			else {
				$found_mod{$module} = $mod_info;

			}
			$total_found++;
			  
		}, $base); 
	push(@mod_count, $total_found);
	$total_found = 0;
}

if ($flag eq "INFO_ALL") {

	foreach $key (sort {lc $a cmp lc $b} keys %found_mod) {
		$mod_name = links('cpan',$key); 
		# Check for duplicate modules
		if (ref($found_mod{$key}[0]) eq 'ARRAY') {

			foreach (@{ $found_mod{$key} }) {

		#	my $row_color = module_check($key);
		#	  if ($row_color && $flag eq 'INFO_MODULES') {
		#		$HTML .= print_table_row_color(3, $row_color, $mod_name, $_->[0], $_->[1]);
		#	  }
		#	  else {
				$HTML .= print_table_row(3, $mod_name, $_->[0], $_->[1]);
		#	  }
			}
		}
		else {
		#	my $row_color = module_check($key);
        	#	  if ($row_color && $flag eq 'INFO_MODULES') {
		#		$HTML .= print_table_row_color(3, $row_color, $mod_name, $found_mod{$key}->[0], $found_mod{$key}->[1]);
		#	  }
		#	  else {
				$HTML .= print_table_row(3, $mod_name, $found_mod{$key}->[0], $found_mod{$key}->[1]);
		#	  }
		}	
	}
}
else {

	foreach $key (sort {lc $a cmp lc $b} keys %found_mod) {
                $mod_name = links('cpan',$key);
                # Check for duplicate modules
                if (ref($found_mod{$key}[0]) eq 'ARRAY') {

                        foreach my $info (@{ $found_mod{$key} }) {
				$is_core = (grep File::Spec->rel2abs($info->[1]) =~ /\Q$_/, ($core_dir1, $core_dir2)) ? "yes" : "no";
			#my $row_color = module_check($key);
			#  if ($row_color && $flag eq 'INFO_MODULES') {
			#	$HTML .= print_table_row_color(4, $row_color, $mod_name, $info->[0], $is_core, $info->[1]);
			#  }
			#  else {
                                $HTML .= print_table_row(4, $mod_name, $info->[0], $is_core, $info->[1]);
			#  }
                        }
                }
                else {
			$is_core = (grep File::Spec->rel2abs($found_mod{$key}->[1]) =~ /\Q$_/, ($core_dir1, $core_dir2)) ? "yes" : "no";
			#my $row_color = module_check($key);
                        # if ($row_color && $flag eq 'INFO_MODULES') {
			#	$HTML .= print_table_row_color(4, $row_color, $mod_name, $found_mod{$key}->[0], $is_core, $found_mod{$key}->[1]);
			 # }
			 # else {
                        	$HTML .= print_table_row(4, $mod_name, $found_mod{$key}->[0], $is_core, $found_mod{$key}->[1]);
			 #}
                }
        }
}

$HTML .= print_table_end();

#if ($flag eq "INFO_MODULES" && $highlight) {
#
#       $HTML .= print_table_start();
#       $HTML .= print_table_header(1, "Color codes"); 
#       $HTML .= print_table_color_start();
#       while (my ($namespace, $code) = each (%colors)) {
#       	$HTML .= print_color_box($code, $namespace);
#       }
#       $HTML .= print_table_color_end();
#       $HTML .= print_table_end();
#
#}

$HTML .= print_table_start();
$HTML .= print_table_header(3, "Module Directories", "Searched", "Number of Modules");

my $amount_index = 0;
my $total_amount = 0;

for my $dir (map{ File::Spec->canonpath($_) }@INC) {

my $searched = (grep { $_ eq $dir } @mod_dir) ? "yes" : "no";
my $amount_found = ($searched eq 'yes') ? $mod_count[$amount_index] : '<i>unknown</i>';
$amount_index++ if ($searched eq 'yes');

$HTML .= print_table_row(3, links('local', File::Spec->canonpath($dir)), $searched, $amount_found);
}
$HTML .= print_table_end();

$HTML .= print_table_start(); 
$total_amount += $_ for (@mod_count); 
my $view = ($flag eq "INFO_ALL") ? 'core' : 'installed'; 
$HTML .= print_table_row(2, "Total $view modules", "$total_amount");
$HTML .= print_table_end();

$HTML .= print_table_end();

return $HTML;

}

sub print_modules {
         
        my $HTML;
	if ($flag eq "INFO_ALL") {
		$HTML .= SECTION("Core Perl modules installed"); 
		$HTML .= print_table_start();
		$HTML .= print_table_header(3, "Module name", "Version", "Location");
	}		
	else {
		$HTML .= SECTION("All Perl modules installed"); 
		$HTML .= print_table_start();
		$HTML .= print_table_header(4, "Module name", "Version", "Core", "Location");
	}

	$HTML .= print_all_modules();
	return $HTML;
}

1;
