
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'HTML::Perlinfo',
    VERSION           => '1.46',
    PREREQ_PM	      => {
    				File::Which 	 => 0,
				App::Info   	 => 0,
				Module::CoreList => 0,
			 },

    AUTHOR   => 'Mike Accardo (mikeaccardo@yahoo.com)',
    
);
