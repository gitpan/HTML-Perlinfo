sub mod_check {

my $module = $_[0];	
$module =~ s!::!/!g;
$module = "$module.pm";

my $mod_path;
    foreach my $i (@INC)
    {
        if ( -f File::Spec->catfile($i, $module) )
        {
            $mod_path = $i;
            last;
        }
    }
return "yes" if ($mod_path);
return "no";
}	

sub cpan_link {

return qq~ <a href="http://search.cpan.org/perldoc?$_[0]" title="Click here to see $_[0] on CPAN [Opens in a new window]" target="_blank">$_[0]</a> ~; 

}


sub perl_info_print_all_modules {
	my ($HTML, $total_found, $mod_version, $base, $eval, $mod_info, $inpod, $is_core, $core_dir1, $core_dir2, $start_dir, $module, $new_val);
        my ( @mod_count, @mod_dir, @modinfo_array);
        my ( %path, %found_mod, %seen); 


	$core_dir1 = File::Spec->canonpath($Config{installarchlib});
	$core_dir2 = File::Spec->canonpath($Config{installprivlib});

	@path{@INC} = ();
	@mod_dir = ($flag eq "INFO_ALL") ? ($core_dir1, $core_dir2) : @INC;

	# Make sure only unique entries and readable directories in @mod_dir
	@mod_dir = grep { -d $_ && -r $_ && !$seen{$_}++ } @mod_dir; 
	
	for $base (@mod_dir) { 
		$base = File::Spec->canonpath($base); 		  
		find ( sub { 
				$start_dir = "$File::Find::topdir";
				$start_dir = File::Spec->rel2abs($start_dir);
				$File::Find::prune = 1, return if
				exists $path{$File::Find::dir} and $File::Find::dir ne $start_dir;
				$module = substr $File::Find::name, length $start_dir;
				return unless $module =~ s/\.pm$//;

				$module =~ s!^/+!!;
				$module =~ s!/!::!g;

				# Get the version	
				# Thieved from ExtUtils::MM_Unix 1.12603	    

				open(MOD, $_) or die "$_: $!";
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
				warn "Could not eval '$eval' in $_: $@" if $@;
				$mod_version = "undef" unless defined $mod_version;
				last;
			}
			close MOD;
			$mod_version = "unknown" if !($mod_version) || ($mod_version !~ /^\d+(\.\d+)*$/);

			$mod_info = [$mod_version, File::Spec->canonpath($File::Find::dir)];  

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
		$mod_name = cpan_link($key); 
		# Check for duplicate modules
		if (ref($found_mod{$key}[0]) eq 'ARRAY') {

			foreach (@{ $found_mod{$key} }) {
				$HTML .= perl_info_print_table_row(3, "$mod_name", "$_->[0]", "$_->[1]");
			}
		}
		else {

			$HTML .= perl_info_print_table_row(3, "$mod_name", "$found_mod{$key}->[0]", "$found_mod{$key}->[1]");
		}	
	}
}
else {

	foreach $key (sort {lc $a cmp lc $b} keys %found_mod) {
                $mod_name = cpan_link($key);
                # Check for duplicate modules
                if (ref($found_mod{$key}[0]) eq 'ARRAY') {

                        foreach my $info (@{ $found_mod{$key} }) {
				$is_core = (grep File::Spec->rel2abs($info->[1]) =~ /\Q$_/, ($core_dir1, $core_dir2)) ? "yes" : "no";
                                $HTML .= perl_info_print_table_row(4, "$mod_name", "$info->[0]", $is_core, "$info->[1]");
                        }
                }
                else {
			$is_core = (grep File::Spec->rel2abs($found_mod{$key}->[1]) =~ /\Q$_/, ($core_dir1, $core_dir2)) ? "yes" : "no";
                        $HTML .= perl_info_print_table_row(4, "$mod_name", "$found_mod{$key}->[0]", "$is_core", "$found_mod{$key}->[1]");
                }
        }
}

$HTML .= perl_info_print_table_end();

$HTML .= perl_info_print_table_start();
$HTML .= perl_info_print_table_colspan_header(2, "Module Directories");
$HTML .= perl_info_print_table_row(2, ++$total_found, File::Spec->canonpath($_)) foreach (@INC);
$HTML .= perl_info_print_table_end();

$HTML .= perl_info_print_table_start();
$HTML .= perl_info_print_table_header(2, "Directories searched", "Number of modules");

my $amount_index = 0; 
my $total_amount = 0;	
for $base (@mod_dir) {
	$HTML .= perl_info_print_table_row(2, "$base", "$mod_count[$amount_index]");	
	$amount_index++;
}	

$HTML .= perl_info_print_table_end();
$HTML .= perl_info_print_table_start(); 
$total_amount += $_ for (@mod_count); 
my $view = ($flag eq "INFO_ALL") ? 'core' : 'installed'; 
$HTML .= perl_info_print_table_row(2, "Total $view modules", "$total_amount");
$HTML .= perl_info_print_table_end();

$HTML .= perl_info_print_table_end();
}

sub perl_info_print_modules {
         
        my $HTML;
	if ($flag eq "INFO_ALL") {
		$HTML .= SECTION("Core Perl modules installed"); 
		$HTML .= perl_info_print_table_start();
		$HTML .= perl_info_print_table_header(3, "Module name", "Version", "Location");
	}		
	else {
		$HTML .= SECTION("All Perl modules installed"); 
		$HTML .= perl_info_print_table_start();
		$HTML .= perl_info_print_table_header(4, "Module name", "Version", "Core", "Location");
	}

	$HTML .= perl_info_print_all_modules();
	return $HTML;

}

1;
