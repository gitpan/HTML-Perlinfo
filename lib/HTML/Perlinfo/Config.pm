sub print_config {

	return join '',	print_section("Perl Core"),
			print_table_start(),
			print_table_header(2, "Variable", "Value"),
			print_config_sh(),
			print_table_end();	
}

sub print_config_sh {

	my @configs = qw/api_versionstring cc ccflags cf_by cf_email cf_time extensions installarchlib installbin installhtmldir installhtmlhelpdir installprefix installprefixexp installprivlib installscript installsitearch installsitebin known_extensions libc libperl libpth libs myarchname optimize osname osvers package perllibs perlpath pm_apiversion prefix prefixexp privlib privlibexp startperl version version_patchlevel_string xs_apiversion/;
        
	return  ($flag eq "INFO_ALL") ? 
			join '', map { print_table_row(2, links('config',$_), $Config{$_})} @configs 
				: join '', map { print_table_row(2, map{ 
						if ($_ !~ /^'/) {
							links('config', $_);	
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

1;
