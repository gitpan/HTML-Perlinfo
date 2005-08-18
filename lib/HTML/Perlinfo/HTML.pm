sub new {

	#my $class = shift;
	my $self = {};
	while (my($field, $val) = splice(@_, 1, 2)) {
	if (defined $field) {  $$field = $val; }
	else { Carp::croak "$field is an invalid CSS field name";}
	}
	bless($self);          
	return $self;
        
}

sub info_all {
	my $meth = (caller 0)[3];
	Carp::croak "$meth does not accept a parameter" if $_[1];
	perlinfo(INFO_ALL);    
}
sub info_general {
	my $meth = (caller 0)[3];
	Carp::croak "$meth does not accept a parameter" if $_[1];
	perlinfo(INFO_GENERAL);    
}
sub info_modules {
	my $meth = (caller 0)[3];
	Carp::croak "$meth does not accept a parameter" if $_[1];
	perlinfo(INFO_MODULES);    
}
sub info_credits {
	my $meth = (caller 0)[3];
	Carp::croak "$meth does not accept a parameter" if $_[1];
	perlinfo(INFO_CREDITS);    
}
sub info_config {
	my $meth = (caller 0)[3];
	Carp::croak "$meth does not accept a parameter" if $_[1];
	perlinfo(INFO_CONFIG);    
}
sub info_apache {
	my $meth = (caller 0)[3];
	Carp::croak "$meth does not accept a parameter" if $_[1];
	perlinfo(INFO_APACHE);    
}
sub info_variables {
	my $meth = (caller 0)[3];
	Carp::croak "$meth does not accept a parameter" if $_[1];
	perlinfo(INFO_VARIABLES);    
}
sub info_license {
	my $meth = (caller 0)[3];
	Carp::croak "$meth does not accept a parameter" if $_[1];
	perlinfo(INFO_LICENSE);    
}

sub vomit {
	my $meth = (caller 1)[3];
	Carp::croak "You did not supply a parameter to $meth";
}

sub bg_image {
        &vomit unless $_[1];
	$bg_image = $_[1];
}

sub bg_position {
        &vomit unless $_[1];
	$bg_position = $_[1];
}

sub bg_repeat {
        &vomit unless $_[1];
	$bg_repeat = $_[1];
}

sub bg_attribute {
        &vomit unless $_[1];
	$bg_attribute = $_[1];
}

sub bg_color {
        &vomit unless $_[1];
	$bg_color = $_[1];
}

sub ft_family {
        &vomit unless $_[1];
	$ft_family = $_[1];
}

sub ft_color {
        &vomit unless $_[1];
	$ft_color = $_[1];
}

sub lk_color {
        &vomit unless $_[1];
	$lk_color = $_[1];
}

sub lk_decoration {
        &vomit unless $_[1];
	$lk_decoration = $_[1];
}

sub lk_bgcolor {
        &vomit unless $_[1];
	$lk_bgcolor = $_[1];
}

sub lk_hvdecoration {
        &vomit unless $_[1];
	$lk_hvdecoration = $_[1];
}

sub header_bgcolor {
        &vomit unless $_[1];
	$header_bgcolor = $_[1];
}

sub header_ftcolor {
        &vomit unless $_[1];
	$header_ftcolor = $_[1];
}
sub leftcol_bgcolor {
        &vomit unless $_[1];
	$leftcol_bgcolor = $_[1];
}

sub leftcol_ftcolor {
	&vomit unless $_[1];
	$leftcol_ftcolor = $_[1];
}

sub rightcol_bgcolor {
	&vomit unless $_[1];
	$rightcol_bgcolor = $_[1];
}

sub rightcol_ftcolor {
	&vomit unless $_[1];
	$rightcol_ftcolor = $_[1];
}
    
# Default html vars 
sub initialize_globals {

$HTML::Perlinfo::bg_image = "";
$HTML::Perlinfo::bg_position = "center";
$HTML::Perlinfo::bg_repeat = "no_repeat";
$HTML::Perlinfo::bg_attribute = "fixed";
$HTML::Perlinfo::bg_color = "#ffffff";

$HTML::Perlinfo::ft_family = "sans-serif";
$HTML::Perlinfo::ft_color = "#000000";
$HTML::Perlinfo::lk_color = "#000099";
$HTML::Perlinfo::lk_decoration = "none";
$HTML::Perlinfo::lk_bgcolor = "#ffffff";
$HTML::Perlinfo::lk_hvdecoration = "underline";

$HTML::Perlinfo::header_bgcolor = "#9999cc";
$HTML::Perlinfo::header_ftcolor = "#000000";
$HTML::Perlinfo::leftcol_bgcolor = "#ccccff";
$HTML::Perlinfo::leftcol_ftcolor = "#000000";
$HTML::Perlinfo::rightcol_bgcolor = "#cccccc";
$HTML::Perlinfo::rightcol_ftcolor = "#000000";

#Make modperl happy
1;
}

# HTML subs 

sub perl_info_print_css{

	  return <<"END_OF_HTML";
body {
background-color: $bg_color; 
background-image: url($bg_image);
background-position: $bg_position;
background-repeat: $bg_repeat;
background-attachment: $bg_attribute;  
color: $ft_color;}
body, td, th, h1, h2 {font-family: $ft_family;}
pre {margin: 0px; font-family: monospace;}
a:link {color: $lk_color; text-decoration: $lk_decoration; background-color: $lk_bgcolor;}
a:hover {text-decoration: $lk_hvdecoration;}
table {border-collapse: collapse;}
.center {text-align: center;}
.center table { margin-left: auto; margin-right: auto; text-align: left;}
.center th { text-align: center !important; }
td, th { border: 1px solid #000000; font-size: 75%; vertical-align: baseline;}
h1 {font-size: 150%;}
h2 {font-size: 125%;}
.p {text-align: left;}
.e {background-color: $leftcol_bgcolor; font-weight: bold; color: $leftcol_ftcolor;}
.h {background-color: $header_bgcolor; font-weight: bold; color: $header_ftcolor;}
.v {background-color: $rightcol_bgcolor; color: $rightcol_ftcolor;}
i {color: #666666; background-color: #cccccc;}
img {float: right; border: 0px;}
hr {width: 600px; background-color: #cccccc; border: 0px; height: 1px; color: #000000;}
END_OF_HTML

  }

  sub perl_info_print_style {
	  return <<"END_OF_HTML";
<style type="text/css"><!--
@{[ perl_info_print_css() ]}
//--></style>
END_OF_HTML
  
  }


  sub perl_info_print_htmlhead {
	  return <<"END_OF_HTML";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
<html>
<head>
@{[ perl_info_print_style() ]}
<title>perlinfo()</title>
</head>
<body><div class="center">
END_OF_HTML
  }

sub  perl_info_print_table_colspan_header {
  
   	 return sprintf("<tr class=\"h\"><th colspan=\"%d\">%s</th></tr>\n", $_[0], $_[1]);  

  }

  sub perl_info_print_table_row {
      
	 
	  my($num_cols) = $_[0];
	  my $HTML = "<tr>";

	  for ($i=0; $i<$num_cols; $i++) {

		  $HTML .= sprintf("<td class=\"%s\">", ($i==0 ? "e" : "v" ));

		  my $row_element = $_[$i+1];
		  if ((not defined ($row_element)) || ($row_element !~ /\S/)) {
			  $HTML .= "<i>no value</i>";
		  } else {
			  my $elem_esc = $row_element;
			  $HTML .= "$elem_esc";

		  }

		  $HTML .= " </td>";

	  }

	  $HTML .=  "</tr>\n";
	  return $HTML;
	  
  }

  sub perl_info_print_table_start {

	  return "<table border=\"0\" cellpadding=\"3\" width=\"600\">\n";

  }
  sub perl_info_print_table_end {

	  return "</table><br />\n";

  }
  sub perl_info_print_box_start {

	  my $HTML = perl_info_print_table_start();	
	  $HTML .= ($_[0] == 1) ? "<tr class=\"h\"><td>\n" : "<tr class=\"v\"><td>\n";
	  return $HTML; 
  }


  sub perl_info_print_box_end {
	  my $HTML = "</td></tr>\n";
	  $HTML = perl_info_print_table_end();
	  return $HTML;
  }

  sub perl_info_print_hr {
	  return "<hr />\n";

  }

  sub perl_info_print_table_header {

	  my($num_cols) = $_[0];
	  my $HTML = "<tr class=\"h\">";

	  my $i;		
	  for ($i=0; $i<$num_cols; $i++) {
		  my $row_element = $_[$i+1];
		  $row_element = " " if (!$row_element);
		  $HTML .=  "<th>$row_element</th>";
	  }

	  return "$HTML</tr>\n";
  }


  sub SECTION  {

	  return "<h2>" . $_[0] . "</h2>\n"; 

  }

 sub perl_info_print_perl_license {

	  return <<'END_OF_HTML';
<p>
This program is free software; you can redistribute it and/or modify it under the terms of
either the Artistic License or the GNU General Public License, which may be found in the Perl 5 source kit.
</p>

<p>This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
</p>
<p>
Complete documentation for Perl, including FAQ lists, should be found on
this system using `man perl' or `perldoc perl'.  If you have access to the
Internet, point your browser at <a href="http://www.perl.org/">http://www.perl.org/</a>, the Perl directory. 
END_OF_HTML

  }

 sub perl_info_print_script {

   	my $HTML =  "<SCRIPT LANGUAGE=\"JavaScript\">\n<!--\n function showcredits () {\n";
	my $str = perl_info_print_htmlhead();
	$str .= perl_info_print_credits();
        $str .= "<form><input type='submit' value='close window' onclick='window.close(); return false;'></form>"; 	
        $str .= "</div></body></html>";	
	$str =~ s/"/\\"/g;
	my @arr = split /\n/, $str;
        $HTML .= "contents=\"$arr[0]\"" . ';';
	#shift(@arr);
        $HTML .= $_ for map{"\ncontents+= \"$arr[$_]\";"} 1 .. $#arr;
        $HTML .= <<'END_OF_HTML';
 
Win1=window.open( '' , 'Window1' , 'location=yes,toolbar=yes,menubar=yes,directories=yes,status=yes,resizable=yes,scrollbars=yes'); 
Win1.moveTo(0,0);
Win1.resizeTo(screen.width,screen.height);
Win1.document.writeln(contents);
Win1.document.close();
	}	    
	//--></SCRIPT>
END_OF_HTML

	return $HTML;
  }   
1;  
