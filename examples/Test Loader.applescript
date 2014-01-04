(*!
	@header
	@abstract
		Template test loader.
	@discussion
		Runs all the test scripts in the current folder.
	@charset macintosh
*)
property parent : load script (((path to library folder from user domain) as text) �
	& "Script Libraries:ASUnit.scpt") as alias

set pwd to (the folder of file (path to me) of application "Finder")
set suite to makeTestLoader()'s loadTestsFromFolder(pwd)
autorun(suite)
