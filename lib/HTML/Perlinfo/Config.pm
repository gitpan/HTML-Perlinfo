sub config_link {
  my ($letter) = $_[0] =~ /^(.)/;  	
  return "<a href=http://search.cpan.org/~aburlison/Solaris-PerlGcc-1.3/config/5.006001/5.10/sparc/Config.pm#$letter>$_[0]</a>";
}

sub perl_info_print_config {

	return join '',	SECTION("Perl Core"),
			perl_info_print_table_start(),
			perl_info_print_table_header(2, "Variable", "Value"),
			perl_info_print_config_sh(),
			perl_info_print_table_end();	
}

sub perl_info_print_config_sh {

	my @configs = qw/api_versionstring cc ccflags cf_by cf_email cf_time extensions installarchlib installbin installhtmldir installhtmlhelpdir installprefix installprefixexp installprivlib installscript installsitearch installsitebin known_extensions libc libperl libpth libs myarchname optimize osname osvers package perllibs perlpath pm_apiversion prefix prefixexp privlib privlibexp startperl version version_patchlevel_string xs_apiversion/;

	return  ($flag eq "INFO_ALL") ? 
			join '', map { perl_info_print_table_row(2, config_link($_), "$Config{$_}")} @configs 
				: join '', map { perl_info_print_table_row(2, map{ 
						if ($_ !~ /^'/) {
							config_link($_);	
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
