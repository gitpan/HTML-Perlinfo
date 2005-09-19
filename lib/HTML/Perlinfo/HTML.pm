sub new {

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
	Carp::croak "You did not provide an argument to $meth";
}

sub title {
        &vomit unless $_[1];
        $title = $_[1];
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

sub no_links {
	$link_switch = 0;
}
    
# Default html vars 
sub initialize_globals {

our $link_switch = 1;
our $highlight = 0;
our %colors;

our $title = 'perlinfo()';
our $bg_image = "";
our $bg_position = "center";
our $bg_repeat = "no_repeat";
our $bg_attribute = "fixed";
our $bg_color = "#ffffff";

our $ft_family = "sans-serif";
our $ft_color = "#000000";
our $lk_color = "#000099";
our $lk_decoration = "none";
our $lk_bgcolor = "";
our $lk_hvdecoration = "underline";

our $header_bgcolor = "#9999cc";
our $header_ftcolor = "#000000";
our $leftcol_bgcolor = "#ccccff";
our $leftcol_ftcolor = "#000000";
our $rightcol_bgcolor = "#cccccc";
our $rightcol_ftcolor = "#000000";

#Make modperl happy
1;
}

# HTML subs 

sub print_css{

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
.modules table {border: 0;}
.modules td { border:0; font-size: 100%; vertical-align: baseline;}
.modules th { border:0; font-size: 100%; vertical-align: baseline;}

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

  sub print_style {
	  return <<"END_OF_HTML";
<style type="text/css"><!--
@{[ print_css() ]}
//--></style>
END_OF_HTML
  
  }


  sub print_htmlhead {
	  return <<"END_OF_HTML";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
<html>
<head>
@{[ print_style() ]}
<title>$title</title>
</head>
<body><div class="center">
END_OF_HTML
  }

sub  print_table_colspan_header {
  
   	 return sprintf("<tr class=\"h\"><th colspan=\"%d\">%s</th></tr>\n", $_[0], $_[1]);  

  }

  sub print_table_row {
      
	 
	  my $num_cols = $_[0];
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

 sub print_table_color_start {

 	return qq~<table class="modules" cellpadding=0 cellspacing=2 border=0 width="600"><tr>\n~;
 }

 sub print_table_color_end {

 	return '</tr></table>';
 }


 sub print_color_box {

	return  qq ~<td>
                    <table border=0><tr><td>
                    <table class="modules" border=0 width=50 height=50 align=left bgcolor="$_[0]">
                    <tr bgcolor="$_[0]"> <td color="$_[0]">&nbsp; </td></tr>
                    </table><tr><td>$_[1]</td></tr>
                    </table>
                    </td>~;
 }

 sub print_table_row_color {

  	  my $num_cols = $_[0];
          my $HTML = "<tr>";

          for ($i=0; $i<$num_cols; $i++) {

                  $HTML .= "<td class=\"$_[1]\">";

                  my $row_element = $_[$i+2];
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
 
  sub print_table_start {

	  return "<table border=\"0\" cellpadding=\"3\" width=\"600\">\n";

  }
  sub print_table_end {

	  return "</table><br />\n";

  }
  sub print_box_start {

	  my $HTML = print_table_start();	
	  $HTML .= ($_[0] == 1) ? "<tr class=\"h\"><td>\n" : "<tr class=\"v\"><td>\n";
	  return $HTML; 
  }


  sub print_box_end {
	  my $HTML = "</td></tr>\n";
	  $HTML = print_table_end();
	  return $HTML;
  }

  sub print_hr {
	  return "<hr />\n";

  }

  sub print_table_header {

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

 sub print_perl_license {

	  return <<"END_OF_HTML";
<p>
This program is free software; you can redistribute it and/or modify it under the terms of
either the Artistic License or the GNU General Public License, which may be found in the Perl 5 source kit.
</p>

<p>This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
</p>
<p>
Complete documentation for Perl, including FAQ lists, should be found on
this system using `man perl' or `perldoc perl'.  If you have access to the
Internet, point your browser at @{[ links('same', 'http://www.perl.org/')]}, the Perl directory. 
END_OF_HTML

  }

 sub print_script {

   	my $HTML =  "<SCRIPT LANGUAGE=\"JavaScript\">\n<!--\n function showcredits () {\n";
	my $str = print_htmlhead();
	$str .= print_credits();
        $str .= "<form><input type='submit' value='close window' onclick='window.close(); return false;'></form>"; 	
        $str .= "</div></body></html>";	
	$str =~ s/"/\\"/g;
	my @arr = split /\n/, $str;
        $HTML .= "contents=\"$arr[0]\"" . ';';
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

sub highlight {

 %colors = @_;
 die Dumper \%colors; 
 $highlight = 1;

}

sub links {

	my $type = shift;
	my $value = shift;

	return $value unless $link_switch;

	if ($type eq "cpan") {

		return qq~ <a href="http://search.cpan.org/perldoc?$value" title="Click here to see $value on CPAN [Opens in a new window]" target="_blank">$value</a> ~;

	}
	elsif ($type eq "ora") {
		if ($value eq "camel1") {
			return  qq~ <a href="http://www.perl.com/"><img border="0" src="http://perl.oreilly.com/images/perl/sm_perl_id_313_wt.gif" alt="Perl Logo" title="Perl Logo" /></a> ~;
		}
		elsif ($value eq "camel2") {
			return qq~ <a href="http://www.perl.com/"><img border="0" src="http://perl.oreilly.com/images/perl/powered_by_perl.gif" alt="Perl logo" title="Perl Logo" /></a> ~; 

		}
                else {
			return qq~ <font size="1">The use of a camel image in association with Perl is a trademark of <a href="http://www.oreilly.com">OReilly Media, Inc.</a>  Used with permission.</font><p /> ~;
		}
	}

	elsif ($type eq "config") {
		my ($letter) = $value =~ /^(.)/;
		return  qq! <a href="http://search.cpan.org/~aburlison/Solaris-PerlGcc-1.3/config/5.006001/5.10/sparc/Config.pm#$letter">$value</a> !;
	}
	elsif ($type eq "local") {
	       if (($ENV{'HTTP_HOST'}) && ($ENV{'HTTP_HOST'} eq 'localhost') || 
	 	   (($ENV{'REMOTE_ADDR'}) && $ENV{'SERVER_ADDR'}) && ($ENV{'REMOTE_ADDR'} eq $ENV{'SERVER_ADDR'})) {
			return qq~ <a href="file://$value" title="Click here to see $value [Opens in a new window]" target="_blank">$value</a> ~;
	       }
	       else {
			return $value;	
	       }
	}
	elsif ($type eq "same") {
		return qq~ <a href="$value">$value</a> ~;
	}
}
1;  
