#
# Makefile
# Mark Wells, 2018-03-23 14:38
#

JULIAPKGS = \
	Conda \
	IJulia \
	ArgParse \
	JSON \
	DataStructures

.ONESHELL:

all: juliapkgs condapkgs

juliapkgs:
	@for pkg in $(JULIAPKGS) ; do \
		julia --color=yes <<- EOF
		using Pkg
		printstyled("Installing $$pkg\n", bold=true, color=:orange)
		pkg"add $$pkg"
		EOF
	done

condapkgs:
	@julia --color=yes <<- EOF
		using Conda
		printstyled( "Adding conda-forge channel to Conda\n"
				   , bold=true
				   , color=:cyan
				   )
		Conda.add_channel("conda-forge")
		printstyled( "Installing jupyter_contrib_nbextensions via Conda\n"
				   , bold=true
				   , color=:orange
				   )
		Conda.add("jupyter_contrib_nbextensions")
	EOF

# vim:ft=make
#
