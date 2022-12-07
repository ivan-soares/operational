#####################################################################################################################################
#
#            numerical codes for operational, short-term forecast of ocean currents and waves
#
#                                          by Ivan Soares, Atlantech Environmental Studies co.
#                                                        
#                                                                       Florianópolis, Brazil
#
######################################################################################################################################

	here is where I keep my stuff to run operational oceanic forecasts of ocean waves and ocean currents !!!

	and here is how to use it:

	In a bash shell in your linux PC run the following commmands:

	git init
	git add 'the name of directory or file to add'
	git commit -m "a message to remind you what is being added"

	then, in your github create a repository and get its address, such as:

	git@github.com:Atlantech-Servicos-Ambientais/operational.git (YOU GET IT BY CLICKING IN 'CODE')

	then, in the same bash shell in your PC, type:

	git remote add origin git@github.com:Atlantech-Servicos-Ambientais/operational.git
	git branch -M master
	git push -u origin master

	and ... voilá !! the entire directory (except the files noted in gitignore) are added to the git branch !!!


	You can make more updates to the repository by running these commands in order:

	git add 'dir or file names'
	git commit -m "Commit message"
	git push origin main

	###### don't forget to update file .gitignore to avoid committing heavy files such as *.nc




##################################################################################################################################
