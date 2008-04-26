
use 5.006;
use ExtUtils::MakeMaker;

my %prereqs;

eval{require App::Info::HTTPD::Apache};
if ($@) {
    my $reply = prompt("Hmmm... You don't have App::Info installed. You don't need it, but it can be useful to get extra information about the Apache HTTPD server. Install (Y/N)", "Y");
    $prereqs{"App::Info"} = 0 unless $reply =~ m/n/i;
}

WriteMakefile(
    NAME              => 'HTML::Perlinfo',
    VERSION           => '1.49',
    PREREQ_PM	      => \%prereqs,

    AUTHOR   => 'Mike Accardo (mikeaccardo@yahoo.com)',
    
);
