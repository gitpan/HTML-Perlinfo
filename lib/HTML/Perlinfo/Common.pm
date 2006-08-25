package HTML::Perlinfo::Common;

our @ISA = qw(Exporter);
our @EXPORT = qw(initialize_globals print_table_colspan_header print_table_row print_table_color_start print_table_color_end print_color_box print_table_row_color print_table_start print_table_end print_box_start print_box_end print_hr print_table_header print_section print_license add_link check_images check_path check_args perl_version release process_args error_msg);
require Exporter;

use CGI::Carp 'fatalsToBrowser';
use Carp ();
use IO::Socket;
use Module::CoreList;
use File::Which;

our %links;

%links = ( 
 'all'   => 1,
 'local' => 0,
 'docs'  => 1,
);

sub check_path {
  
  return add_link('local', which("$_[0]")) if which("$_[0]");
  return "<i>not in path</i>";

}

sub perl_version {
  my $version;
  if ($] >= 5.006) {
    $version = sprintf "%vd", $^V;
  }
  else { # else time to update Perl!
    $version = "$]";
  }
  return $version;
}

sub release {
  return ($Module::CoreList::released{$]}) ? $Module::CoreList::released{$]} : "unknown";
}

sub check_args { 

  my ($key, $value) = @_;
  my ($message, %allowed);
  @allowed{qw(docs local 0 1)} = ();

  if (not exists $allowed{$key}) {
    $message = "$key is an invalid links parameter";
  }
  elsif ($key =~ /(?:docs|local)/ && $value !~ /^(?:0|1)$/i) {
    $message = "$value is an invalid value for the $key parameter in the links attribute";
  }

  error_msg("$message") if $message;

}

sub process_args {
  # This sub returns a hash ref containing param args
  my %params;
  my $sub  = pop @_ || die "No coderef provided\n"; # get the sub
  if (defined $_[0]) {
    while(my($key, $value) = splice @_, 0, 2) {
        $sub->($key, $value);
        if (exists $params{$key}){
           @key_value = ref(${$params{$key}}[0]) eq 'ARRAY' ? @{$params{$key}} : $params{$key};
           push @key_value,$value;
           $new_val = [@key_value];
           $params{$key} = $new_val;
        }
        else {
            $params{$key} = $value;
        }
    }
  } 
  return \%params; 
}

sub error_msg {
  Carp::croak "User error: $_[0]";
}

# HTML subs 

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

 	return qq~<table class="modules" cellpadding=4 cellspacing=4 border=0 width="600"><tr>\n~;
 }

 sub print_table_color_end {

 	return '</tr></table>';
 }


 sub print_color_box {

	return  qq ~<td>
                      <table border=0>
                       <tr><td>
                          <table class="modules" border=0 width=50 height=50 align=left bgcolor="$_[0]">
                            <tr bgcolor="$_[0]"> 
				<td color="$_[0]">
				 &nbsp; 
				</td>
			    </tr>
                          </table>
                       </tr></td>
		       <tr><td><small>$_[1]</small></td></tr>
                      </table>
                    </td>~;
 }

 sub print_table_row_color {

  	  my $num_cols = $_[0];
          my $HTML = "<tr bgcolor=\"$_[1]\">";

          for ($i=0; $i<$num_cols; $i++) {

                  $HTML .= "<td bgcolor=\"$_[1]\">";

                  my $row_element = $_[$i+2]; # start at the 2nd element
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


  sub print_section  {

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
Internet, point your browser at @{[ add_link('same', 'http://www.perl.org/')]}, the Perl directory. 
END_OF_HTML

  }

sub print_license {

 return join '', print_section("Perl License"),
		       print_box_start(0),
		       print_perl_license(),
		       print_box_end();
}


sub check_images {

	return 0 unless $links{'all'};

	  local($^W) = 0;
	  my $sock = IO::Socket::INET->new(	PeerAddr  => $_[0],  
		  				PeerPort  => 80,
						PeerProto => 'tcp',
					        Timeout   => 5) || return 0;	 
	  $sock->close;
	  return 1;

  }
  
sub add_link {

	my ($type, $value, $link) = @_;

	return $value unless $links{'all'};

	if ($type eq "cpan") {

          #return $value unless $links{'docs'} or $link;
          return $value if $link && $link->[0] == 0;

	  if ($link) {
	    if (ref $link eq 'ARRAY') {
	      foreach (@$link) {
	        if ($_->[0] eq 'all' or lc $value =~ $_->[0]) {
		  return '<a href=' . $_->[1] . $value .
                                qq~ title="Click here to see $value documentation [Opens in a new window]"
                                target="_blank">$value</a> ~		  
		}
	      }	
	    }
            elsif ($link->[0] eq 'all' or lc $value =~ $link->[0]) {
			return '<a href=' . $link->[1] . $value .  
				qq~ title="Click here to see $value documentation [Opens in a new window]" 
				target="_blank">$value</a> ~
 	    }
          }
		return qq~ <a href="http://search.cpan.org/perldoc?$value" 
		title="Click here to see $value on CPAN [Opens in a new window]" target="_blank">$value</a> ~;
	}
	elsif ($type eq "ora") {
		if ($value eq "camel1") {
			return  qq~ <a href="http://www.perl.com/"><img border="0" src="http://i104.photobucket.com/albums/m176/perlinfo/sm_perl_id_313_bk.gif" alt="Perl Logo" title="Perl Logo" /></a> ~;
		}
		elsif ($value eq "camel2") {
			return qq~ <a href="http://www.perl.com/"><img border="0" src="http://i104.photobucket.com/albums/m176/perlinfo/powered_by_perl.gif" alt="Perl logo" title="Perl Logo" /></a> ~; 

		}
                else {
			return qq~ <font size="1">The use of a camel image in association with Perl is a trademark of <a href="http://www.oreilly.com">OReilly Media, Inc.</a>  Used with permission.</font><p /> ~;
		}
	}
	elsif ($type eq 'apache') {
		return qq~ <a href="http://perl.apache.org/"><img src='http://i104.photobucket.com/albums/m176/perlinfo/button-110x30.gif' border=0 alt="mod_perl -- Speed, Power, Scalability"></a> ~;
	}
	elsif ($type eq "config") {
      		return $value unless $links{'docs'};
		my ($letter) = $value =~ /^(.)/;
		return  qq! <a href="http://search.cpan.org/~aburlison/Solaris-PerlGcc-1.3/config/5.006001/5.10/sparc/Config.pm#$letter">$value</a> !;
	}
	elsif ($type eq "local") {
	  return $value unless $links{'local'};
			return qq~ <a href="file://$value" title="Click here to see $value [Opens in a new window]" target="_blank">$value</a> ~;
	}
	elsif ($type eq "same") {
		return qq~ <a href="$value">$value</a> ~;
	}
}
1; 
