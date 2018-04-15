#
# Makefile
# Mark Wells, 2018-03-23 14:38
#

.ONESHELL:

install:
	@julia <<- EOF
	Pkg.update()
	println("Using a \"HEREDOC\" to install Julia packages...")
	println("Installing DataStructures")
	Pkg.add("DataStructures")
	println("Installing JSON")
	Pkg.add("JSON")
	println("Installing ArgParse")
	Pkg.add("ArgParse")
	EOF
	#
	if [ -z $(PREFIX) ]; then
		# default to /usr/local/bin if PREFIX wasn't supplied
		sudo ln -sf $$(pwd)/jjnbparam /usr/local/bin/
	else
		if [ -w $(PREFIX) ]; then
			# run as user without sudo
			ln -sf $$(pwd)/jjnbparam $(PREFIX)
		else
			# run as user with sudo
			sudo ln -sf $$(pwd)/jjnbparam $(PREFIX)
		fi
	fi

# vim:ft=make
#

