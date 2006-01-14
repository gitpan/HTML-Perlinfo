sub print_httpd {

        return join '', print_section("apache"), 
			print_table_start(), 
			print_apache(), 
			print_table_end(),
	
			print_section("Apache Environment"), 
			print_table_start(), 
			print_table_header(2, "Variable", "Value"), 
			print_apache_environment(), 
			print_table_end();
}

sub check_apache {

	return 0 unless (defined($ENV{'SERVER_SOFTWARE'}) && $ENV{'SERVER_SOFTWARE'}=~/apache/i);
	return 1;
} 

sub print_apache {

	return unless (check_apache());

	my  ($version, $user, $group, $root, @mods) = ("<i>Not detected</i>") x 5;
	my $apache = App::Info::HTTPD::Apache->new;
	if ($apache->installed) {
		$version = $apache->version; 
		$user  =  $apache->user;
		$group =  $apache->group;
		$root  =  $apache->httpd_root;
		@mods  =  $apache->static_mods;
	} 
	else {
		($version) = $ENV{'SERVER_SOFTWARE'} =~ /(\d+[\.\d]*)/; 
	}  

	return join '', print_table_row(2, "Apache Version", "$version"),
			print_table_row(2, "Hostname:Port", "$ENV{'SERVER_NAME'}:$ENV{'SERVER_PORT'}"),
			print_table_row(2, "User/Group", "$user / $group"),
			print_table_row(2, "Server Root", "$root"),
			($apache->installed) ?
			print_table_row(2, "Loaded Modules", "@mods"):
			print_table_row(2, "Loaded Modules", "<i>Not detected</i>");
}

sub print_apache_environment {

	return unless (check_apache());

	return join '', print_table_row(2, "DOCUMENT_ROOT", "$ENV{'DOCUMENT_ROOT'} "),
			print_table_row(2, "HTTP_ACCEPT", "$ENV{'HTTP_ACCEPT'} "),
			print_table_row(2, "HTTP_ACCEPT_CHARSET", "$ENV{'HTTP_ACCEPT_CHARSET'} "),
			print_table_row(2, "HTTP_ACCEPT_ENCODING", "$ENV{'HTTP_ACCEPT_ENCODING'} "),
			print_table_row(2, "HTTP_ACCEPT_LANGUAGE", "$ENV{'HTTP_ACCEPT_LANGUAGE'} "),
			print_table_row(2, "HTTP_CONNECTION", "$ENV{'HTTP_CONNECTION'} "),
			print_table_row(2, "HTTP_HOSTS", "$ENV{'HTTP_HOSTS'} "),
			print_table_row(2, "HTTP_KEEP_ALIVE", "$ENV{'HTTP_KEEP_ALIVE'} "),
			print_table_row(2, "HTTP_USER_AGENT", "$ENV{'HTTP_USER_AGENT'} "),
			print_table_row(2, "PATH", "$ENV{'PATH'} "),
			print_table_row(2, "REMOTE_ADDR", "$ENV{'REMOTE_ADDR'} "),
			print_table_row(2, "REMOTE_HOST", "$ENV{'REMOTE_HOST'} "),
			print_table_row(2, "REMOTE_PORT", "$ENV{'REMOTE_PORT'} "),
			print_table_row(2, "SCRIPT_FILENAME", "$ENV{'SCRIPT_FILENAME'} "),
			print_table_row(2, "SCRIPT_URI", "$ENV{'SCRIPT_URI'} "),
			print_table_row(2, "SCRIPT_URL", "$ENV{'SCRIPT_URL'} "),
			print_table_row(2, "SERVER_ADDR", "$ENV{'SERVER_ADDR'} "),
			print_table_row(2, "SERVER_ADMIN", "$ENV{'SERVER_ADMIN'} "),
			print_table_row(2, "SERVER_NAME", "$ENV{'SERVER_NAME'} "),
			print_table_row(2, "SERVER_PORT", "$ENV{'SERVER_PORT'} "),
			print_table_row(2, "SERVER_SIGNATURE", "$ENV{'SERVER_SIGNATURE'} "),
			print_table_row(2, "SERVER_SOFTWARE", "$ENV{'SERVER_SOFTWARE'} "),
			print_table_row(2, "GATEWAY_INTERFACE", "$ENV{'GATEWAY_INTERFACE'} "),
			print_table_row(2, "SERVER_PROTOCOL", "$ENV{'SERVER_PROTOCOL'} "),
			print_table_row(2, "REQUEST_METHOD", "$ENV{'REQUEST_METHOD'} "),
			print_table_row(2, "QUERY_STRING", "$ENV{'QUERY_STRING'} "),
			print_table_row(2, "REQUEST_URI", "$ENV{'REQUEST_URI'} "),
			print_table_row(2, "SCRIPT_NAME", "$ENV{'SCRIPT_NAME'} ");  
}
1;
