package HTML::Perlinfo::Base;


use CGI::Carp 'fatalsToBrowser';
use HTML::Perlinfo::Common;
use HTML::Perlinfo::General;
use HTML::Perlinfo::Credits;
use CGI qw(header);
use Carp ();
use warnings;
use strict;



sub new {
  my ($class, %params) = @_;
  my $self = {};
  $self->{full_page} = 1; 
  $self->{header} = '';
  $self->{title} = 'perlinfo()';
  $self->{bg_image} = '';
  $self->{bg_position} = 'center';
  $self->{bg_repeat} = 'no_repeat';
  $self->{bg_attribute} = 'fixed';
  $self->{bg_color} = '#ffffff';
  $self->{ft_family} = 'sans-serif';
  $self->{ft_color} = '#000000';
  $self->{lk_color} = '#000099';
  $self->{lk_decoration} = 'none';
  $self->{lk_bgcolor} = '';
  $self->{lk_hvdecoration} = 'underline'; 
  $self->{header_bgcolor} = '#9999cc';
  $self->{header_ftcolor} = '#000000';
  $self->{leftcol_bgcolor} = '#ccccff';
  $self->{leftcol_ftcolor} = '#000000';
  $self->{rightcol_bgcolor} = '#cccccc';
  $self->{rightcol_ftcolor} = '#000000';

  foreach my $key (keys %params) {
    if (exists $self->{$key}) {  
      $self->{$key} = $params{$key}; 
    }
    else { 
      error_msg("$key is an invalid attribute");
    }
  }

  bless $self, $class;
  return $self;
    
}

sub info_all {
  my $self = shift;
  my %param = @_;
  error_msg("invalid parameter") if (defined $_[0] && exists $param{'links'} && ref $param{'links'} ne 'ARRAY');   
  $self->links(@{$param{'links'}});
  # header is 1, then give header. If header is 0, then don't. 
  my $html = ($self->{header} || defined($ENV{'SERVER_SOFTWARE'}) && length $self->{header} != 1) ? header() : '';
  $html .= $self->print_htmlhead() if $self->{full_page};
  $html .= $self->print_script();
  $html .= print_general();
  $html .= print_variables();
  $html .= print_thesemodules('core');
  $html .= print_license();
  $html .= "</div></body></html>" if $self->{full_page};
  defined wantarray ? return $html : print $html;
}
sub info_general {
  my $self = shift;
  my %param = @_;
  error_msg("invalid parameter") if (defined $_[0] && exists $param{'links'} && ref $param{'links'} ne 'ARRAY');   
  $self->links(@{$param{'links'}});
  my $html = ($self->{header} || defined($ENV{'SERVER_SOFTWARE'}) && length $self->{header} != 1) ? header() : '';
  $html .= $self->print_htmlhead() if $self->{full_page};
  $html .= print_general();
  $html .= "</div></body></html>" if $self->{full_page};
  defined wantarray ? return $html : print $html;
}
sub info_modules {
  my $self = shift;
  my %param = @_;
  error_msg("invalid parameter") if (defined $_[0] && exists $param{'links'} && ref $param{'links'} ne 'ARRAY');   
  $self->links(@{$param{'links'}});
  my $html = ($self->{header} || defined($ENV{'SERVER_SOFTWARE'}) && length $self->{header} != 1) ? header() : '';
  $html .= $self->print_htmlhead() if $self->{'full_page'};
  $html .= print_thesemodules('all');
  $html .= "</div></body></html>"  if $self->{'full_page'};
  defined wantarray ? return $html : print $html;
}
sub info_credits {
  my $self = shift;
  my %param = @_;
  error_msg("invalid parameter") if (defined $_[0] && exists $param{'links'} && ref $param{'links'} ne 'ARRAY');   
  $self->links(@{$param{'links'}});
  my $html = ($self->{header} || defined($ENV{'SERVER_SOFTWARE'}) && length $self->{header} != 1) ? header() : '';
  $html .= $self->print_htmlhead() if $self->{full_page};
  $html .= print_credits(); 
  $html .= "</div></body></html>" if $self->{full_page};
  defined wantarray ? return $html : print $html;
}
sub info_config {
  my $self = shift;
  my %param = @_;
  error_msg("invalid parameter") if (defined $_[0] && exists $param{'links'} && ref $param{'links'} ne 'ARRAY');   
  $self->links(@{$param{'links'}});
  my $html = ($self->{header} || defined($ENV{'SERVER_SOFTWARE'}) && length $self->{header} != 1) ? header() : '';
  $html .= $self->print_htmlhead() if $self->{full_page};
  $html .= print_config('info_config');
  $html .= "</div></body></html>" if $self->{full_page};
  defined wantarray ? return $html : print $html;
}
sub info_apache {
  my $self = shift;
  my %param = @_;
  error_msg("invalid parameter") if (defined $_[0] && exists $param{'links'} && ref $param{'links'} ne 'ARRAY');   
  $self->links(@{$param{'links'}});
  my $html = ($self->{header} || defined($ENV{'SERVER_SOFTWARE'}) && length $self->{header} != 1) ? header() : '';
  $html .= $self->print_htmlhead() if $self->{full_page};
  $html .= print_httpd();
  $html .= "</div></body></html>" if $self->{full_page};
  defined wantarray ? return $html : print $html;
}
sub info_variables {
  my $self = shift;
  my %param = @_;
  error_msg("invalid parameter") if (defined $_[0] && exists $param{'links'} && ref $param{'links'} ne 'ARRAY');   
  $self->links(@{$param{'links'}});
  my $html = ($self->{header} || defined($ENV{'SERVER_SOFTWARE'}) && length $self->{header} != 1) ? header() : '';
  $html .= $self->print_htmlhead() if $self->{full_page};
  $html .= print_variables();
  $html .= "</div></body></html>" if $self->{full_page};
  defined wantarray ? return $html : print $html;
}

sub info_license {
  my $self = shift;
  my %param = @_;
  error_msg("invalid parameter") if (defined $_[0] && exists $param{'links'} && ref $param{'links'} ne 'ARRAY');   
  $self->links(@{$param{'links'}});
  my $html = ($self->{header} || defined($ENV{'SERVER_SOFTWARE'}) && length $self->{header} != 1) ? header() : '';
  $html .= $self->print_htmlhead() if $self->{full_page};
  $html .= print_license();
  $html .= "</div></body></html>" if $self->{full_page};
  defined wantarray ? return $html : print $html;
}

sub print_script {

        my $HTML =  "<script type=\"text/javascript\" language=\"JavaScript\">\n<!--\n function showcredits () {\n";
        my $str = shift->print_htmlhead();
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

sub print_htmlhead {
	
  my $self = shift;

  my $title = $self->{title};
  my $bg_image = $self->{bg_image};
  my $bg_position = $self->{bg_position};
  my $bg_repeat = $self->{bg_repeat};
  my $bg_attribute = $self->{bg_attribute};
  my $bg_color = $self->{bg_color};

  my $ft_family = $self->{ft_family};
  my $ft_color = $self->{ft_color};
  my $lk_color = $self->{lk_color};
  my $lk_decoration = $self->{lk_decoration};
  my $lk_bgcolor = $self->{lk_bgcolor};
  my $lk_hvdecoration = $self->{lk_hvdecoration};

  my $header_bgcolor = $self->{header_bgcolor};
  my $header_ftcolor = $self->{header_ftcolor};
  my $leftcol_bgcolor =$self->{leftcol_bgcolor};
  my $leftcol_ftcolor = $self->{leftcol_ftcolor};
  my $rightcol_bgcolor = $self->{rightcol_bgcolor};
  my $rightcol_ftcolor = $self->{rightcol_ftcolor};

  return <<"END_OF_HTML";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "DTD/xhtml1-transitional.dtd">
<html>
<head>
<style type="text/css"><!--
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
//--></style>
<title>$title</title>
</head>
<body><div class="center">
END_OF_HTML
}

sub links {

  my $self = shift;
  my $args = process_args(@_, \&check_args);
  if (exists $args->{'0'}) {
    $HTML::Perlinfo::Common::links{'all'} = 0;
  }
  elsif (exists $args->{'1'}) {
    $HTML::Perlinfo::Common::links{'all'} = 1;
  }
  elsif (exists $args->{'docs'} && not exists $args->{'local'}) {
    $HTML::Perlinfo::Common::links{'docs'} = $args->{'docs'};
  } 
  elsif (exists $args->{'local'} && not exists $args->{'docs'}) {
    $HTML::Perlinfo::Common::links{'local'} = $args->{'local'};
  }			 
  else {
    $HTML::Perlinfo::Common::links{'docs'} = $args->{'docs'}, 
    $HTML::Perlinfo::Common::links{'local'} = $args->{'local'}, 
  }
}
1; 
