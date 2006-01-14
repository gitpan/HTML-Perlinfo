use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'HTML::Perlinfo',
    VERSION           => '1.25',
    PM 		      =>             
    			{
			'lib/HTML/Perlinfo.pm'             => '$(INST_LIBDIR)/Perlinfo.pm',
			'lib/HTML/Perlinfo/HTML.pm'        => '$(INST_LIBDIR)/Perlinfo/HTML.pm',
			'lib/HTML/Perlinfo/Apache.pm'      => '$(INST_LIBDIR)/Perlinfo/Apache.pm',
			'lib/HTML/Perlinfo/License.pm'     => '$(INST_LIBDIR)/Perlinfo/License.pm',
			'lib/HTML/Perlinfo/Credits.pm'     => '$(INST_LIBDIR)/Perlinfo/Credits.pm',
			'lib/HTML/Perlinfo/General.pm'     => '$(INST_LIBDIR)/Perlinfo/General.pm',
			'lib/HTML/Perlinfo/Modules.pm'     => '$(INST_LIBDIR)/Perlinfo/Modules.pm',
			'lib/HTML/Perlinfo/Variables.pm'   => '$(INST_LIBDIR)/Perlinfo/Variables.pm',
			'lib/HTML/Perlinfo/Config.pm'       => '$(INST_LIBDIR)/Perlinfo/Config.pm',
			
                      	},
		      
    PREREQ_PM	      => {
    				File::Which 	 => 0,
				App::Info   	 => 0,
				Module::CoreList => 0,
			 },

    AUTHOR   => 'Mike Accardo (mikeaccardo@yahoo.com)',
    
);
