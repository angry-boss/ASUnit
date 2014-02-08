use AppleScript version "2.3"
use scripting additions
use ASMake : script "ASMake" version "0.1.0"
property parent : ASMake
property TopLevel : me

on run {action}
	runTask(action)
end run


------------------------------------------------------------------
-- Tasks
------------------------------------------------------------------

script api
	property parent : Task(me)
	property description : "Build the API documentation."
	property dir : "Documentation"
	
	owarn("HeaderDoc's support for AppleScript is definitely broken as of v8.9 (Xcode 5.0)")
	--Set LANG to get rid of warnings about missing default encoding
	sh("env LANG=en_US.UTF-8 headerdoc2html", {"-q", "-o", dir, "ASUnit.applescript"})
	sh("env LANG=en_US.UTF-8 gatherheaderdoc", dir)
	sh("open", dir & "/ASUnit_applescript/index.html")
end script


script asunitBuild
	property parent : Task(me)
	property name : "asunit"
	property description : "Build ASUnit."
	osacompile("ASUnit", "scpt", {"-x"})
end script

script build
	property parent : Task(me)
	property description : "Build all source AppleScript scripts."
	run asunitBuild
	osacompile({�
		"examples/HexString", "examples/Test HexString", "examples/Test Loader", �
		"examples/Test AppleScript Variable Types and You", "templates/Test Template", �
		"templates/Runtime Loader", "templates/MyScript"}, "scpt", {"-x"})
end script

script clean
	property parent : Task(me)
	property description : "Remove any temporary products."
	rm({"*.scpt", "*.scptd", "templates/*.scpt*", "examples/*.scpt*"})
end script

script clobber
	property parent : Task(me)
	property description : "Remove any generated file."
	run clean
	rm({api's dir, "ASUnit-*", "*.tar.gz", "*.html"})
end script

script doc
	property parent : Task(me)
	property description : "Build an HTML version of the old manual and the README."
	property markdown : missing value
	
	set markdown to which("markdown")
	if markdown is not missing value then
		set out to sh(markdown, {"OldManual.md"})
		set fp to open for access POSIX file (my PWD & "/OldManual.html") with write permission
		write out to fp as �class utf8�
		close access fp
		set out to sh(markdown, {"README.md"})
		set fp to open for access POSIX file (my PWD & "/README.html") with write permission
		write out to fp as �class utf8�
		close access fp
	else
		error markdown & space & "not found." & linefeed & �
			"PATH: " & (do shell script "echo $PATH")
	end if
end script

script dist
	property parent : Task(me)
	property description : "Prepare a directory for distribution."
	property dir : missing value
	run clobber
	run asunitBuild
	run doc
	set {n, v} to {name, version} of �
		(run script POSIX file (my PWD & "/ASUnit.applescript"))
	set dir to n & "-" & v
	mkdir(dir)
	cp({"ASUnit.scpt", "COPYING", "OldManual.html", �
		"README.html", "examples", "templates"}, dir)
end script

script gzip
	property parent : Task(me)
	property description : "Build a compressed archive for distribution."
	run dist
	do shell script "tar czf " & quoted form of (dist's dir & ".tar.gz") & space & quoted form of dist's dir & "/*"
end script

script install
	property parent : Task(me)
	property dir : POSIX path of �
		((path to library folder from user domain) as text) & "Script Libraries"
	property description : "Install ASUnit in" & space & dir & "."
	run asunitBuild
	mkdir(dir)
	cp("ASUnit.scpt", dir)
	ohai("ASUnit installed in" & space & (dir as text))
end script

script test
	property parent : Task(me)
	property description : "Run tests."
	property printSuccess : false
	run script "Test ASUnit.applescript"
end script

script versionTask
	property parent : Task(me)
	property name : "version"
	property synonyms : {"v"}
	property description : "Print ASUnit's version and exit."
	property printSuccess : false
	set {n, v} to {name, version} of �
		(run script POSIX file (my PWD & "/ASUnit.applescript"))
	ohai(n & space & "v" & v)
end script
