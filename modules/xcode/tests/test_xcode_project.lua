--
-- tests/actions/xcode/test_xcode_project.lua
-- Automated test suite for Xcode project generation.
-- Copyright (c) 2009-2011 Jess Perkins and the Premake project
--
	local suite = test.declare("xcode_project")
	local p = premake
	local xcode = p.modules.xcode



---------------------------------------------------------------------------
-- Setup/Teardown
---------------------------------------------------------------------------

	local tr, wks

	function suite.teardown()
		tr = nil
	end

	function suite.setup()
		_TARGET_OS = "macosx"
		p.action.set('xcode4')
		p.eol("\n")
		wks = test.createWorkspace()
	end

	local function prepare()
		wks = p.oven.bakeWorkspace(wks)
		xcode.prepareWorkspace(wks)
		local prj = test.getproject(wks, 1)
		tr = xcode.buildprjtree(prj)
	end

---------------------------------------------------------------------------
-- PBXBuildFile tests
---------------------------------------------------------------------------

	function suite.PBXBuildFile_ListsCppSources()
		files { "source.h", "source.c", "source.cpp", "Info.plist" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		7018C364CB5A16D69EB461A4 /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = 9B47484CB259E37EA275DE8C /* source.cpp */; };
		F3989C244A260696229F1A64 /* source.c in Sources */ = {isa = PBXBuildFile; fileRef = 7DC6D30C8137A53E02A4494C /* source.c */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsObjCSources()
		files { "source.h", "source.m", "source.mm", "Info.plist" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		8A01A092B9936F8494A0AED2 /* source.mm in Sources */ = {isa = PBXBuildFile; fileRef = CCAA329A6F98594CFEBE38DA /* source.mm */; };
		CBA890782235FAEAFAAF0EB8 /* source.m in Sources */ = {isa = PBXBuildFile; fileRef = 3AFE9C203E6F6E52BFDC1260 /* source.m */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsSwiftSources()
		files { "source.swift", "Info.plist" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		4616E7383FD8A3AA79D7A578 /* source.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0B2BDAE0539CBF12983B9120 /* source.swift */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsMetalFileInResources()
		files { "source.metal", "Info.plist" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		3873A08432355CF66C345EC4 /* source.metal in Resources */ = {isa = PBXBuildFile; fileRef = 35B2856C7E23699EC2C23BAC /* source.metal */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsResourceFilesOnlyOnceWithGroupID()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		6FE0F2A3E16C0B15906D30E3 /* MainMenu.xib in Resources */ = {isa = PBXBuildFile; fileRef = 6CB8FB6B191BBB9DD7A431AB /* MainMenu.xib */; };
/* End PBXBuildFile section */
		]]
	end


	function suite.PBXBuildFile_ListsFrameworks()
		links { "Cocoa.framework", "ldap" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		F8E8DBA28B76A594F44F49E2 /* Cocoa.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = 8D6BC6AA50D7885C8F7B2CEA /* Cocoa.framework */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsDylibs()
		links { "../libA.dylib", "libB.dylib", "/usr/lib/libC.dylib" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		3C98627697D9B5E86B3400B6 /* libB.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = D413533EEB25EE70DB41E97E /* libB.dylib */; };
		91686CDFDECB631154EA631F /* libA.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = 5F9AE5C74A870BB9926CD407 /* libA.dylib */; };
		A7E42B5676077F08FD15D196 /* libC.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = CF0547FE2A469B70FDA0E63E /* libC.dylib */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ListsFrameworksAndDylibsForSigning()
		links
		{
			"../libA.dylib",
			"libB.dylib",
			"/usr/lib/libC.dylib",
			"../D.framework",
			"../E.framework",
		}
		embedAndSign
		{
			"libA.dylib",
			"D.framework",
		}
		embed
		{
			"libB.dylib",
			"E.framework",
		}
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		12F1B82D44EB02DFBECA3E6D /* E.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = A817AE35FEA518A7D71E2C75 /* E.framework */; };
		773ADFBAA9342A6C231365FA /* E.framework in Embed Libraries */ = {isa = PBXBuildFile; fileRef = A817AE35FEA518A7D71E2C75 /* E.framework */; settings = {ATTRIBUTES = (RemoveHeadersOnCopy, ); }; };
		3C98627697D9B5E86B3400B6 /* libB.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = D413533EEB25EE70DB41E97E /* libB.dylib */; };
		3369CB838EAB1EF5620569C3 /* libB.dylib in Embed Libraries */ = {isa = PBXBuildFile; fileRef = D413533EEB25EE70DB41E97E /* libB.dylib */; };
		91686CDFDECB631154EA631F /* libA.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = 5F9AE5C74A870BB9926CD407 /* libA.dylib */; };
		9C3456CCE9974CFE5FB64D0C /* libA.dylib in Embed Libraries */ = {isa = PBXBuildFile; fileRef = 5F9AE5C74A870BB9926CD407 /* libA.dylib */; settings = {ATTRIBUTES = (CodeSignOnCopy, ); }; };
		A7E42B5676077F08FD15D196 /* libC.dylib in Frameworks */ = {isa = PBXBuildFile; fileRef = CF0547FE2A469B70FDA0E63E /* libC.dylib */; };
		F56B754B2764BFFDA143FB8B /* D.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = F3987C734A25E6E5229EFAB3 /* D.framework */; };
		59B49CD88BADE78A058D2318 /* D.framework in Embed Libraries */ = {isa = PBXBuildFile; fileRef = F3987C734A25E6E5229EFAB3 /* D.framework */; settings = {ATTRIBUTES = (CodeSignOnCopy, RemoveHeadersOnCopy, ); }; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_IgnoresVpaths()
		files { "source.h", "source.c", "source.cpp", "Info.plist" }
		vpaths { ["Source Files"] = { "**.c", "**.cpp" } }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		7018C364CB5A16D69EB461A4 /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = 9B47484CB259E37EA275DE8C /* source.cpp */; };
		F3989C244A260696229F1A64 /* source.c in Sources */ = {isa = PBXBuildFile; fileRef = 7DC6D30C8137A53E02A4494C /* source.c */; };
/* End PBXBuildFile section */
		]]
	end


---
-- Verify that files listed in xcodebuildresources are marked as resources
---
	function suite.PBXBuildFile_ListsXcodeBuildResources()
		files { "file1.txt", "file01.png", "file02.png", "file-3.png" }
		xcodebuildresources { "file1.txt", "**.png" }
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		628F3826BDD08B98912AD666 /* file-3.png in Resources */ = {isa = PBXBuildFile; fileRef = 992385EEB0362120A0521C2E /* file-3.png */; };
		93485EDEC2DA2DD09DE76D1E /* file1.txt in Resources */ = {isa = PBXBuildFile; fileRef = 9F78562642667CD8D18C5C66 /* file1.txt */; };
		C87AFEAA23BC521CF7169CEA /* file02.png in Resources */ = {isa = PBXBuildFile; fileRef = D54D8E32EC602964DC7C2472 /* file02.png */; };
		EE9FC5C849E1193A1D3B6408 /* file01.png in Resources */ = {isa = PBXBuildFile; fileRef = 989B7E70AFAE19A29FCA14B0 /* file01.png */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ExcludedFromBuildByFlags()
		files { "source.cpp", "excluded.cpp" }
		filter { "files:excluded.cpp" }
			flags { "ExcludeFromBuild" }
		filter {}
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		7018C364CB5A16D69EB461A4 /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = 9B47484CB259E37EA275DE8C /* source.cpp */; };
/* End PBXBuildFile section */
		]]
	end

	function suite.PBXBuildFile_ExcludedFromBuildByBuildactionNone()
		files { "source.cpp", "excluded.cpp" }
		filter { "files:excluded.cpp" }
			buildaction "None"
		filter {}
		prepare()
		xcode.PBXBuildFile(tr)
		test.capture [[
/* Begin PBXBuildFile section */
		7018C364CB5A16D69EB461A4 /* source.cpp in Sources */ = {isa = PBXBuildFile; fileRef = 9B47484CB259E37EA275DE8C /* source.cpp */; };
/* End PBXBuildFile section */
		]]
	end


---------------------------------------------------------------------------
-- PBXFileReference tests
---------------------------------------------------------------------------

	function suite.PBXFileReference_ListsConsoleTarget()
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		19A5C4E61D1697189E833B26 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsWindowedTarget()
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		E5FB9875FD0E33A7ED2A2EB5 /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = MyProject.app; path = MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsIOSWindowedTarget()
		_TARGET_OS = "ios"
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		E5FB9875FD0E33A7ED2A2EB5 /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = MyProject.app; path = MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsStaticLibTarget()
		kind "StaticLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		FDCF31ACF735331EEAD08FEC /* libMyProject.a */ = {isa = PBXFileReference; explicitFileType = archive.ar; includeInIndex = 0; name = libMyProject.a; path = libMyProject.a; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsIOSStaticLibTarget()
		_TARGET_OS = "ios"
		kind "StaticLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		FDCF31ACF735331EEAD08FEC /* libMyProject.a */ = {isa = PBXFileReference; explicitFileType = archive.ar; includeInIndex = 0; name = libMyProject.a; path = libMyProject.a; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsSharedLibTarget()
		kind "SharedLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		2781AF7F7E0F19F156882DBF /* libMyProject.dylib */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.dylib"; includeInIndex = 0; name = libMyProject.dylib; path = libMyProject.dylib; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsIOSSharedLibTarget()
		_TARGET_OS = "ios"
		kind "SharedLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		2781AF7F7E0F19F156882DBF /* libMyProject.dylib */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.dylib"; includeInIndex = 0; name = libMyProject.dylib; path = libMyProject.dylib; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsOSXBundleTarget()
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		8AD066EE75BC8CE0BDA2552E /* MyProject.bundle */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MyProject.bundle; path = MyProject.bundle; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsIOSOSXBundleTarget()
		_TARGET_OS = "ios"
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		8AD066EE75BC8CE0BDA2552E /* MyProject.bundle */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MyProject.bundle; path = MyProject.bundle; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_ListsXCTestTarget()
		kind "SharedLib"
		sharedlibtype "XCTest"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		F573990FE05FBF012845874F /* MyProject.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MyProject.xctest; path = MyProject.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_ListsIOSXCTestTarget()
		_TARGET_OS = "ios"
		kind "SharedLib"
		sharedlibtype "XCTest"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		F573990FE05FBF012845874F /* MyProject.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; name = MyProject.xctest; path = MyProject.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_ListsOSXFrameworkTarget()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		2D914F2255CC07D43D679562 /* MyProject.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; name = MyProject.framework; path = MyProject.framework; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListsIOSOSXFrameworkTarget()
		_TARGET_OS = "ios"
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		2D914F2255CC07D43D679562 /* MyProject.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; name = MyProject.framework; path = MyProject.framework; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end



	function suite.PBXFileReference_ListsSourceFiles()
		files { "source.c" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		19A5C4E61D1697189E833B26 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		7DC6D30C8137A53E02A4494C /* source.c */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.c; name = source.c; path = source.c; sourceTree = "<group>"; };
		]]
	end

	function suite.PBXFileReference_ListsSourceFilesCompileAs()
		files { "source.c", "objsource.c", "objsource.cpp" }
		filter { "files:source.c" }
			compileas "C++"
		filter { "files:objsource.c" }
			compileas "Objective-C"
		filter { "files:objsource.cpp" }
			compileas "Objective-C++"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		19A5C4E61D1697189E833B26 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		7DC6D30C8137A53E02A4494C /* source.c */ = {isa = PBXFileReference; explicitFileType = sourcecode.cpp.cpp; name = source.c; path = source.c; sourceTree = "<group>"; };
		C8C6CC62F1018514D89D12A2 /* objsource.cpp */ = {isa = PBXFileReference; explicitFileType = sourcecode.cpp.objcpp; name = objsource.cpp; path = objsource.cpp; sourceTree = "<group>"; };
		E4BF12E20AE5429471EC3922 /* objsource.c */ = {isa = PBXFileReference; explicitFileType = sourcecode.c.objc; name = objsource.c; path = objsource.c; sourceTree = "<group>"; };
		]]
	end


	function suite.PBXFileReference_ListsXibCorrectly()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		19A5C4E61D1697189E833B26 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		31594983623D4175755577C3 /* French */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = French; path = French.lproj/MainMenu.xib; sourceTree = "<group>"; };
		625C7BEB5C1E385D961D3A2B /* English */ = {isa = PBXFileReference; lastKnownFileType = file.xib; name = English; path = English.lproj/MainMenu.xib; sourceTree = "<group>"; };
		]]
	end


	function suite.PBXFileReference_ListsStringsCorrectly()
		files { "English.lproj/InfoPlist.strings", "French.lproj/InfoPlist.strings" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		19A5C4E61D1697189E833B26 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		A329C1B0714D1562F85B67F0 /* English */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = English; path = English.lproj/InfoPlist.strings; sourceTree = "<group>"; };
		C3BECE4859358D7AC7D1E488 /* French */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = French; path = French.lproj/InfoPlist.strings; sourceTree = "<group>"; };
		]]
	end


	function suite.PBXFileReference_ListFrameworksCorrectly()
		links { "Cocoa.framework/" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		19A5C4E61D1697189E833B26 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		8D6BC6AA50D7885C8F7B2CEA /* Cocoa.framework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = Cocoa.framework; path = System/Library/Frameworks/Cocoa.framework; sourceTree = SDKROOT; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_ListDylibsCorrectly()
		links { "../libA.dylib", "libB.dylib", "/usr/lib/libC.dylib" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		19A5C4E61D1697189E833B26 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		5F9AE5C74A870BB9926CD407 /* libA.dylib */ = {isa = PBXFileReference; lastKnownFileType = compiled.mach-o.dylib; name = libA.dylib; path = ../libA.dylib; sourceTree = SOURCE_ROOT; };
		CF0547FE2A469B70FDA0E63E /* libC.dylib */ = {isa = PBXFileReference; lastKnownFileType = compiled.mach-o.dylib; name = libC.dylib; path = /usr/lib/libC.dylib; sourceTree = "<absolute>"; };
		D413533EEB25EE70DB41E97E /* libB.dylib */ = {isa = PBXFileReference; lastKnownFileType = compiled.mach-o.dylib; name = libB.dylib; path = libB.dylib; sourceTree = SOURCE_ROOT; };
/* End PBXFileReference section */
		]]
	end

	function suite.PBXFileReference_leavesFrameworkLocationsAsIsWhenSupplied_pathIsSetToInput()
		local inputFrameWork = 'somedir/Foo.framework'
		links(inputFrameWork)
		prepare()

		--io.capture()
		xcode.PBXFileReference(tr)
		--local str = io.captured()
		--test.istrue(str:find('path = "'..inputFrameWork..'"'))

		--ms check
	end


	function suite.PBXFileReference_relativeFrameworkPathSupplied_callsError()
		local inputFrameWork = '../somedir/Foo.framework'
		links(inputFrameWork)
		prepare()
		-- ms no longer and error
		-- valid case for linking relative frameworks
		--local error_called = false
		--local old_error = error
		--error = function( ... )error_called = true end
		xcode.PBXFileReference(tr)
		--error = old_error
		--test.istrue(error_called)
	end

	function suite.PBXFileReference_ListsIconFiles()
		files { "Icon.icns" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		19A5C4E61D1697189E833B26 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		1A07B4D0BCF5DB824C1BBB10 /* Icon.icns */ = {isa = PBXFileReference; lastKnownFileType = image.icns; name = Icon.icns; path = Icon.icns; sourceTree = "<group>"; };
		]]
	end

	function suite.PBXFileReference_IgnoresTargetDir()
		targetdir "bin"
		kind "WindowedApp"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		E5FB9875FD0E33A7ED2A2EB5 /* MyProject.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; name = MyProject.app; path = MyProject.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_UsesTargetSuffix()
		targetsuffix "-d"
		kind "SharedLib"
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		9E361150CDC7E042A8D51F90 /* libMyProject-d.dylib */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.dylib"; includeInIndex = 0; name = "libMyProject-d.dylib"; path = "libMyProject-d.dylib"; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
		]]
	end


	function suite.PBXFileReference_UsesFullPath_WhenParentIsVirtual()
		files { "src/source.c" }
		vpaths { ["Source Files"] = "**.c" }
		prepare()
		xcode.PBXFileReference(tr)
		test.capture [[
/* Begin PBXFileReference section */
		19A5C4E61D1697189E833B26 /* MyProject */ = {isa = PBXFileReference; explicitFileType = "compiled.mach-o.executable"; includeInIndex = 0; name = MyProject; path = MyProject; sourceTree = BUILT_PRODUCTS_DIR; };
		721A4003892CDB357948D643 /* source.c */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.c; name = source.c; path = src/source.c; sourceTree = "<group>"; };
		]]
	end


---------------------------------------------------------------------------
-- PBXFrameworksBuildPhase tests
---------------------------------------------------------------------------

	function suite.PBXFrameworksBuildPhase_OnNoFiles()
		prepare()
		xcode.PBXFrameworksBuildPhase(tr)
		test.capture [[
/* Begin PBXFrameworksBuildPhase section */
		9FDD37564328C0885DF98D96 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
		]]
	end


	function suite.PBXFrameworksBuild_ListsFrameworksCorrectly()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXFrameworksBuildPhase(tr)
		test.capture [[
/* Begin PBXFrameworksBuildPhase section */
		9FDD37564328C0885DF98D96 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				F8E8DBA28B76A594F44F49E2 /* Cocoa.framework in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */
		]]
	end


---------------------------------------------------------------------------
-- PBXCopyFilesBuildPhaseForEmbedFrameworks tests
---------------------------------------------------------------------------

	function suite.PBXCopyFilesBuildPhaseForEmbedFrameworks_OnNoFiles()
		prepare()
		xcode.PBXCopyFilesBuildPhaseForEmbedFrameworks(tr)
		test.capture [[
/* Begin PBXCopyFilesBuildPhase section */
		E1D3B542862652F4985E9B82 /* Embed Libraries */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 10;
			files = (
			);
			name = "Embed Libraries";
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXCopyFilesBuildPhase section */
		]]
	end


	function suite.PBXCopyFilesBuildPhaseForEmbedFrameworks_ListsEmbeddedLibrariesCorrectly()
		links
		{
			"../libA.dylib",
			"../D.framework",
		}
		embed { "libA.dylib" }
		embedAndSign { "D.framework" }
		prepare()
		xcode.PBXCopyFilesBuildPhaseForEmbedFrameworks(tr)
		test.capture [[
/* Begin PBXCopyFilesBuildPhase section */
		E1D3B542862652F4985E9B82 /* Embed Libraries */ = {
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 10;
			files = (
				9C3456CCE9974CFE5FB64D0C /* libA.dylib in Frameworks */,
				59B49CD88BADE78A058D2318 /* D.framework in Frameworks */,
			);
			name = "Embed Libraries";
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXCopyFilesBuildPhase section */
		]]
	end


---------------------------------------------------------------------------
-- PBXGroup tests
---------------------------------------------------------------------------

	function suite.PBXGroup_OnNoFiles()
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		12F5A37D963B00EFBF8281BD /* MyProject */ = {
			isa = PBXGroup;
			children = (
				A6C936B49B3FADE6EA134CF4 /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		A6C936B49B3FADE6EA134CF4 /* Products */ = {
			isa = PBXGroup;
			children = (
				19A5C4E61D1697189E833B26 /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_OnSourceFiles()
		files { "source.h" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		12F5A37D963B00EFBF8281BD /* MyProject */ = {
			isa = PBXGroup;
			children = (
				5C62B7965FD389C8E1402DD6 /* source.h */,
				A6C936B49B3FADE6EA134CF4 /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		A6C936B49B3FADE6EA134CF4 /* Products */ = {
			isa = PBXGroup;
			children = (
				19A5C4E61D1697189E833B26 /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_OnSourceSubdirs()
		files { "include/premake/source.h" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		12F5A37D963B00EFBF8281BD /* MyProject */ = {
			isa = PBXGroup;
			children = (
				5C62B7965FD389C8E1402DD6 /* source.h */,
				A6C936B49B3FADE6EA134CF4 /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		A6C936B49B3FADE6EA134CF4 /* Products */ = {
			isa = PBXGroup;
			children = (
				19A5C4E61D1697189E833B26 /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_pathHasPlusPlus_PathIsQuoted()
		files { "RequiresQuoting++/h.h" }
		prepare()
		xcode.PBXGroup(tr)

		local str = p.captured()
		--test.istrue(str:find('path = "RequiresQuoting%+%+";'))

	end

	function suite.PBXGroup_SortsFiles()
		files { "test.h", "source.h", "source.cpp" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		12F5A37D963B00EFBF8281BD /* MyProject */ = {
			isa = PBXGroup;
			children = (
				9B47484CB259E37EA275DE8C /* source.cpp */,
				5C62B7965FD389C8E1402DD6 /* source.h */,
				ABEF15744F3A9EA66A0B6BB4 /* test.h */,
				A6C936B49B3FADE6EA134CF4 /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		A6C936B49B3FADE6EA134CF4 /* Products */ = {
			isa = PBXGroup;
			children = (
				19A5C4E61D1697189E833B26 /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_OnResourceFiles()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib", "Info.plist" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		12F5A37D963B00EFBF8281BD /* MyProject */ = {
			isa = PBXGroup;
			children = (
				ACC2AED4C3D54A06B3F14514 /* Info.plist */,
				6CB8FB6B191BBB9DD7A431AB /* MainMenu.xib */,
				A6C936B49B3FADE6EA134CF4 /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		A6C936B49B3FADE6EA134CF4 /* Products */ = {
			isa = PBXGroup;
			children = (
				19A5C4E61D1697189E833B26 /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */
		]]
	end


	function suite.PBXGroup_OnFrameworks()
		links { "Cocoa.framework" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		12F5A37D963B00EFBF8281BD /* MyProject */ = {
			isa = PBXGroup;
			children = (
				BBF76781A7E87333FA200DC1 /* Frameworks */,
				A6C936B49B3FADE6EA134CF4 /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		A6C936B49B3FADE6EA134CF4 /* Products */ = {
			isa = PBXGroup;
			children = (
				19A5C4E61D1697189E833B26 /* MyProject */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		BBF76781A7E87333FA200DC1 /* Frameworks */ = {
			isa = PBXGroup;
			children = (
				8D6BC6AA50D7885C8F7B2CEA /* Cocoa.framework */,
			);
			name = Frameworks;
			sourceTree = "<group>";
		};
		]]
	end


	function suite.PBXGroup_OnVpaths()
		files { "include/premake/source.h" }
		vpaths { ["Headers"] = "**.h" }
		prepare()
		xcode.PBXGroup(tr)
		test.capture [[
/* Begin PBXGroup section */
		12F5A37D963B00EFBF8281BD /* MyProject */ = {
			isa = PBXGroup;
			children = (
				20D885C0C52B2372D7636C00 /* Headers */,
				A6C936B49B3FADE6EA134CF4 /* Products */,
			);
			name = MyProject;
			sourceTree = "<group>";
		};
		20D885C0C52B2372D7636C00 /* Headers */ = {
			isa = PBXGroup;
			children = (
				E91A2DDD367D240FAC9C241D /* source.h */,
			);
			name = Headers;
			sourceTree = "<group>";
		};
		]]
	end


---------------------------------------------------------------------------
-- PBXNativeTarget tests
---------------------------------------------------------------------------

	function suite.PBXNativeTarget_OnConsoleApp()
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		48B5980C775BEBFED09D464C /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 8E187FB5316408E74C34D5F5 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				0FC4B7F6B3104128CDE10E36 /* Resources */,
				7971D14D1CBD5A7F378E278D /* Sources */,
				9FDD37564328C0885DF98D96 /* Frameworks */,
				E1D3B542862652F4985E9B82 /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = 19A5C4E61D1697189E833B26 /* MyProject */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */
		]]
	end


	function suite.PBXNativeTarget_OnWindowedApp()
		kind "WindowedApp"
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		D2C7B5BBD37AB2AD475C83FB /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 8DCCE3C4913DB5F612AA5A04 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				0F791C0512E9EE3794569245 /* Resources */,
				7926355C7C97078EFE03AB9C /* Sources */,
				9F919B65A3026D97246F11A5 /* Frameworks */,
				A0315911431F7FC3D2455F51 /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/Applications";
			productName = MyProject;
			productReference = E5FB9875FD0E33A7ED2A2EB5 /* MyProject.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */
		]]
	end


	function suite.PBXNativeTarget_OnSharedLib()
		kind "SharedLib"
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		CD0213851572F7B75A11C9C5 /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 1F5D05CE18C307400C5E640E /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				A1093E0F9A6F3F818E0A9C4F /* Resources */,
				0AB65766041C58D8F7B7B5A6 /* Sources */,
				3121BD6F2A87BEE11E231BAF /* Frameworks */,
				D652259BC13E4B8D092413DB /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productName = MyProject;
			productReference = 2781AF7F7E0F19F156882DBF /* libMyProject.dylib */;
			productType = "com.apple.product-type.library.dynamic";
		};
/* End PBXNativeTarget section */
		]]
	end


	function suite.PBXNativeTarget_OnBuildCommands()
		prebuildcommands { "prebuildcmd" }
		prelinkcommands { "prelinkcmd" }
		postbuildcommands { "postbuildcmd" }
		files { "file.in" }
		filter { "files:file.in" }
			buildcommands { "buildcmd" }
			buildoutputs { "file.out" }
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		48B5980C775BEBFED09D464C /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 8E187FB5316408E74C34D5F5 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				9607AE1010C857E500CD1376 /* Prebuild */,
				C06220C983CDE27BC2718709 /* Build "file.in" */,
				0FC4B7F6B3104128CDE10E36 /* Resources */,
				7971D14D1CBD5A7F378E278D /* Sources */,
				9607AE3510C85E7E00CD1376 /* Prelink */,
				9FDD37564328C0885DF98D96 /* Frameworks */,
				E1D3B542862652F4985E9B82 /* Embed Libraries */,
				9607AE3710C85E8F00CD1376 /* Postbuild */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = 19A5C4E61D1697189E833B26 /* MyProject */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */
		]]
	end


	function suite.PBXNativeTarget_OnBuildCommandsFilesFilterDependency()
		files { "file.1", "file.2", "file.3" }
		filter { "files:file.1" }
			buildcommands { "first" }
			buildoutputs { "file.2" }
		filter { "files:file.3" }
			buildcommands { "last" }
			buildoutputs { "file.4" }
		filter { "files:file.2" }
			buildcommands { "second" }
			buildoutputs { "file.3" }
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		48B5980C775BEBFED09D464C /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 8E187FB5316408E74C34D5F5 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				A50DBDBDC6D96AEF038E93FD /* Build "file.1" */,
				71E4A5FF93B05331D0657C3F /* Build "file.2" */,
				3EBB8E4160873B739D3C6481 /* Build "file.3" */,
				0FC4B7F6B3104128CDE10E36 /* Resources */,
				7971D14D1CBD5A7F378E278D /* Sources */,
				9FDD37564328C0885DF98D96 /* Frameworks */,
				E1D3B542862652F4985E9B82 /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = 19A5C4E61D1697189E833B26 /* MyProject */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */
		]]
	end


	function suite.PBXNativeTarget_OnBuildCommandsBuildInputsDependency()
		files { "file.1", "file.2", "file.3" }
		filter { "files:file.1" }
			buildcommands { "first" }
			buildoutputs { "file.4" }
		filter { "files:file.3" }
			buildcommands { "last" }
			buildinputs { "file.5" }
			buildoutputs { "file.6" }
		filter { "files:file.2" }
			buildcommands { "second" }
			buildinputs { "file.4" }
			buildoutputs { "file.5" }
		prepare()
		xcode.PBXNativeTarget(tr)
		test.capture [[
/* Begin PBXNativeTarget section */
		48B5980C775BEBFED09D464C /* MyProject */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 8E187FB5316408E74C34D5F5 /* Build configuration list for PBXNativeTarget "MyProject" */;
			buildPhases = (
				A50DBDBDC6D96AEF038E93FD /* Build "file.1" */,
				71E4A5FF93B05331D0657C3F /* Build "file.2" */,
				3EBB8E4160873B739D3C6481 /* Build "file.3" */,
				0FC4B7F6B3104128CDE10E36 /* Resources */,
				7971D14D1CBD5A7F378E278D /* Sources */,
				9FDD37564328C0885DF98D96 /* Frameworks */,
				E1D3B542862652F4985E9B82 /* Embed Libraries */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productInstallPath = "$(HOME)/bin";
			productName = MyProject;
			productReference = 19A5C4E61D1697189E833B26 /* MyProject */;
			productType = "com.apple.product-type.tool";
		};
/* End PBXNativeTarget section */
		]]
	end


---------------------------------------------------------------------------
-- PBXAggregateTarget tests
---------------------------------------------------------------------------

	function suite.PBXAggregateTarget_OnUtility()
		kind "Utility"
		prepare()
		xcode.PBXAggregateTarget(tr)
		test.capture [[
/* Begin PBXAggregateTarget section */
		48B5980C775BEBFED09D464C /* MyProject */ = {
			isa = PBXAggregateTarget;
			buildConfigurationList = 8E187FB5316408E74C34D5F5 /* Build configuration list for PBXAggregateTarget "MyProject" */;
			buildPhases = (
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productName = MyProject;
		};
/* End PBXAggregateTarget section */
		]]
	end


	function suite.PBXAggregateTarget_OnBuildCommands()
		kind "Utility"
		prebuildcommands { "prebuildcmd" }
		prelinkcommands { "prelinkcmd" }
		postbuildcommands { "postbuildcmd" }
		files { "file.in" }
		filter { "files:file.in" }
			buildcommands { "buildcmd" }
			buildoutputs { "file.out" }
		prepare()
		xcode.PBXAggregateTarget(tr)
		test.capture [[
/* Begin PBXAggregateTarget section */
		48B5980C775BEBFED09D464C /* MyProject */ = {
			isa = PBXAggregateTarget;
			buildConfigurationList = 8E187FB5316408E74C34D5F5 /* Build configuration list for PBXAggregateTarget "MyProject" */;
			buildPhases = (
				9607AE1010C857E500CD1376 /* Prebuild */,
				C06220C983CDE27BC2718709 /* Build "file.in" */,
				9607AE3510C85E7E00CD1376 /* Prelink */,
				9607AE3710C85E8F00CD1376 /* Postbuild */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MyProject;
			productName = MyProject;
		};
/* End PBXAggregateTarget section */
		]]
	end


---------------------------------------------------------------------------
-- PBXProject tests
---------------------------------------------------------------------------

	function suite.PBXProject_OnProject()
		prepare()
		xcode.PBXProject(tr)
		test.capture [[
/* Begin PBXProject section */
		08FB7793FE84155DC02AAC07 /* Project object */ = {
			isa = PBXProject;
			buildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */;
			compatibilityVersion = "Xcode 3.2";
			hasScannedForEncodings = 1;
			mainGroup = 12F5A37D963B00EFBF8281BD /* MyProject */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				48B5980C775BEBFED09D464C /* MyProject */,
			);
		};
/* End PBXProject section */
		]]
	end


	function suite.PBXProject_OnSystemCapabilities()
		xcodesystemcapabilities {
			["com.apple.InAppPurchase"] = "ON",
			["com.apple.iCloud"] = "ON",
			["com.apple.GameCenter.iOS"] = "OFF",
		}
		prepare()
		xcode.PBXProject(tr)
		test.capture [[
/* Begin PBXProject section */
		08FB7793FE84155DC02AAC07 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				TargetAttributes = {
					48B5980C775BEBFED09D464C = {
						SystemCapabilities = {
							com.apple.GameCenter.iOS = {
								enabled = 0;
							};
							com.apple.InAppPurchase = {
								enabled = 1;
							};
							com.apple.iCloud = {
								enabled = 1;
							};
						};
					};
				};
			};
			buildConfigurationList = 1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */;
			compatibilityVersion = "Xcode 3.2";
			hasScannedForEncodings = 1;
			mainGroup = 12F5A37D963B00EFBF8281BD /* MyProject */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				48B5980C775BEBFED09D464C /* MyProject */,
			);
		};
/* End PBXProject section */
		]]
	end


---------------------------------------------------------------------------
-- PBXResourceBuildPhase tests
---------------------------------------------------------------------------

	function suite.PBXResourcesBuildPhase_OnNoResources()
		prepare()
		xcode.PBXResourcesBuildPhase(tr)
		test.capture [[
/* Begin PBXResourcesBuildPhase section */
		0FC4B7F6B3104128CDE10E36 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */
		]]
	end


	function suite.PBXResourcesBuildPhase_OnResources()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib", "Info.plist" }
		prepare()
		xcode.PBXResourcesBuildPhase(tr)
		test.capture [[
/* Begin PBXResourcesBuildPhase section */
		0FC4B7F6B3104128CDE10E36 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				6FE0F2A3E16C0B15906D30E3 /* MainMenu.xib in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */
		]]
	end


---------------------------------------------------------------------------
-- PBXShellScriptBuildPhase tests
---------------------------------------------------------------------------

	function suite.PBXShellScriptBuildPhase_OnNoScripts()
		prepare()
		xcode.PBXShellScriptBuildPhase(tr)
		test.capture [[
		]]
	end


	function suite.PBXShellScriptBuildPhase_OnPrebuildScripts()
		prebuildcommands { 'ls src', 'cp "a" "b"' }
		prepare()
		xcode.PBXShellScriptBuildPhase(tr)
		test.capture [[
/* Begin PBXShellScriptBuildPhase section */
		9607AE1010C857E500CD1376 /* Prebuild */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputPaths = (
			);
			name = Prebuild;
			outputPaths = (
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "set -e\nif [ \"${CONFIGURATION}\" = \"Debug\" ]; then\nls src\ncp \"a\" \"b\"\nfi\nif [ \"${CONFIGURATION}\" = \"Release\" ]; then\nls src\ncp \"a\" \"b\"\nfi";
		};
/* End PBXShellScriptBuildPhase section */
		]]
	end


	function suite.PBXShellScriptBuildPhase_OnBuildComandScripts()
		files { "file.in1" }
		filter { "files:file.in1" }
			buildcommands { 'ls src', 'cp "a" "b"' }
			buildinputs { "file.in2" }
			buildoutputs { "file.out" }
		prepare()
		xcode.PBXShellScriptBuildPhase(tr)
		test.capture [[
/* Begin PBXShellScriptBuildPhase section */
		9AE2196BE8450F9D5E640FAB /* Build "file.in1" */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputPaths = (
				"file.in1",
				"file.in2",
			);
			name = "Build \"file.in1\"";
			outputPaths = (
				"file.out",
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "set -e\nif [ \"${CONFIGURATION}\" = \"Debug\" ]; then\n\tls src\n\tcp \"a\" \"b\"\nfi\nif [ \"${CONFIGURATION}\" = \"Release\" ]; then\n\tls src\n\tcp \"a\" \"b\"\nfi";
		};
/* End PBXShellScriptBuildPhase section */
		]]
	end


	function suite.PBXShellScriptBuildPhase_OnPerConfigCmds()
		prebuildcommands { 'ls src' }
		filter { "configurations:Debug" }
		prebuildcommands { 'cp a b' }
		prepare()
		xcode.PBXShellScriptBuildPhase(tr)
		test.capture [[
/* Begin PBXShellScriptBuildPhase section */
		9607AE1010C857E500CD1376 /* Prebuild */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputPaths = (
			);
			name = Prebuild;
			outputPaths = (
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "set -e\nif [ \"${CONFIGURATION}\" = \"Debug\" ]; then\nls src\ncp a b\nfi\nif [ \"${CONFIGURATION}\" = \"Release\" ]; then\nls src\nfi";
		};
/* End PBXShellScriptBuildPhase section */
		]]
	end


	function suite.PBXShellScriptBuildPhase_OnBuildInputsAnddOutputsOrder()
		files { "file.a" }
		filter { "files:file.a" }
			buildcommands { "buildcmd" }
			buildinputs { "file.3", "file.1", "file.2" }
			buildoutputs { "file.5", "file.6", "file.4" }
		prepare()
		xcode.PBXShellScriptBuildPhase(tr)
		test.capture [[
/* Begin PBXShellScriptBuildPhase section */
		0D594A1D2F24F74F6BDA205D /* Build "file.a" */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputPaths = (
				"file.a",
				"file.3",
				"file.1",
				"file.2",
			);
			name = "Build \"file.a\"";
			outputPaths = (
				"file.5",
				"file.6",
				"file.4",
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "set -e\nif [ \"${CONFIGURATION}\" = \"Debug\" ]; then\n\tbuildcmd\nfi\nif [ \"${CONFIGURATION}\" = \"Release\" ]; then\n\tbuildcmd\nfi";
		};
/* End PBXShellScriptBuildPhase section */
		]]
	end


---------------------------------------------------------------------------
-- PBXSourcesBuildPhase tests
---------------------------------------------------------------------------

	function suite.PBXSourcesBuildPhase_OnNoSources()
		prepare()
		xcode.PBXSourcesBuildPhase(tr)
		test.capture [[
/* Begin PBXSourcesBuildPhase section */
		7971D14D1CBD5A7F378E278D /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */
		]]
	end


	function suite.PBXSourcesBuildPhase_OnSources()
		files { "hello.cpp", "goodbye.cpp" }
		prepare()
		xcode.PBXSourcesBuildPhase(tr)
		test.capture [[
/* Begin PBXSourcesBuildPhase section */
		7971D14D1CBD5A7F378E278D /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				D7426C94082664861B3E9AD4 /* goodbye.cpp in Sources */,
				EF69EEEA1EFBBDDCFA08FD2A /* hello.cpp in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */
		]]
	end


---------------------------------------------------------------------------
-- PBXVariantGroup tests
---------------------------------------------------------------------------

	function suite.PBXVariantGroup_OnNoGroups()
		prepare()
		xcode.PBXVariantGroup(tr)
		test.capture [[
/* Begin PBXVariantGroup section */
/* End PBXVariantGroup section */
		]]
	end


	function suite.PBXVariantGroup_OnNoResourceGroups()
		files { "English.lproj/MainMenu.xib", "French.lproj/MainMenu.xib" }
		prepare()
		xcode.PBXVariantGroup(tr)
		test.capture [[
/* Begin PBXVariantGroup section */
		6CB8FB6B191BBB9DD7A431AB /* MainMenu.xib */ = {
			isa = PBXVariantGroup;
			children = (
				625C7BEB5C1E385D961D3A2B /* English */,
				31594983623D4175755577C3 /* French */,
			);
			name = MainMenu.xib;
			sourceTree = "<group>";
		};
/* End PBXVariantGroup section */
		]]
	end


---------------------------------------------------------------------------
-- XCBuildConfiguration_Target tests
---------------------------------------------------------------------------

	function suite.XCBuildConfigurationTarget_OnConsoleApp()
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnConsoleApp_dwarf()
		debugformat "Dwarf"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = dwarf;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnConsoleApp_split_dwarf()
		debugformat "SplitDwarf"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnConsoleApp_default()
		debugformat "Default"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnWindowedApp()
		kind "WindowedApp"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		F1C0BE8A138C6BBC504194CA /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "\"$(HOME)/Applications\"";
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnStaticLib()
		kind "StaticLib"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		92D99EC1EE1AF233C1753D01 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnSharedLib()
		kind "SharedLib"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		144A3F940E0BFC06480AFDD4 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_PREFIX = lib;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXBundle()
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		5C54F6038D38EDF5A0512443 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Bundles";
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationTarget_OnXCTest()
		kind "SharedLib"
		sharedlibtype "XCTest"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		0C14B9243CF8B1165010E764 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXFramework()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		2EC4D23760BE1CE9DA9D5877 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnTargetPrefix()
		kind "SharedLib"
		targetprefix "xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		33365BC82CF8183A66F71A08 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_PREFIX = xyz;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnConsoleAppTargetExtension()
		kind "ConsoleApp"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		4FD8665471A41386AE593C94 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject.xyz;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnConsoleAppNoTargetExtension()
		kind "ConsoleApp"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnSharedLibTargetExtension()
		kind "SharedLib"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		8FB8842BC09C7C1DD3B4B26B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_EXTENSION = xyz;
				EXECUTABLE_PREFIX = lib;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnSharedLibNoTargetExtension()
		kind "SharedLib"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		5E2996528DBB654468C8A492 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_EXTENSION = "";
				EXECUTABLE_PREFIX = lib;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnStaticLibTargetExtension()
		kind "StaticLib"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		8FB8842BC09C7C1DD3B4B26B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_EXTENSION = xyz;
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnStaticLibNoTargetExtension()
		kind "StaticLib"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		5E2996528DBB654468C8A492 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				EXECUTABLE_EXTENSION = "";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/lib;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnWindowedAppTargetExtension()
		kind "WindowedApp"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		4FD8665471A41386AE593C94 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "\"$(HOME)/Applications\"";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = xyz;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnWindowedAppNoTargetExtension()
		kind "WindowedApp"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "\"$(HOME)/Applications\"";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = "";
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXBundleTargetExtension()
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		4FD8665471A41386AE593C94 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Bundles";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = xyz;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXBundleNoTargetExtension()
		kind "SharedLib"
		sharedlibtype "OSXBundle"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Bundles";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = "";
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXFrameworkTargetExtension()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		targetextension ".xyz"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		4FD8665471A41386AE593C94 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = xyz;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnOSXFrameworkNoTargetExtension()
		kind "SharedLib"
		sharedlibtype "OSXFramework"
		targetextension ""
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
				PRODUCT_NAME = MyProject;
				WRAPPER_EXTENSION = "";
			};
			name = Debug;
		};
		]]
	end

    function suite.XCBuildConfigurationTarget_OnOSXMinVersion()
		_TARGET_OS = "macosx"
		systemversion "10.11"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				MACOSX_DEPLOYMENT_TARGET = 10.11;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end

    function suite.XCBuildConfigurationTarget_OnOSXUnSpecificedVersion()
		_TARGET_OS = "macosx"
		-- systemversion "10.11"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnInfoPlist()
		files { "./a/b/c/MyProject-Info.plist" }
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INFOPLIST_FILE = "a/b/c/MyProject-Info.plist";
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnSymbols()
		symbols "On"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnTargetSuffix()
		targetsuffix "-d"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		46BCF44C6EF7ACFE56933A8C /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = "MyProject-d";
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnSinglePlatform()
		platforms { "Universal32" }
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Universal32/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationTarget_OnMultiplePlatforms()
		workspace("MyWorkspace")
		platforms { "Universal32", "Universal64" }
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CONFIGURATION_BUILD_DIR = bin/Universal32/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationTarget_OnIOS()
		_TARGET_OS = "ios"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
				SDKROOT = iphoneos;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationTarget_OnIOSMinVersion()
		_TARGET_OS = "ios"
		systemversion "8.3"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				IPHONEOS_DEPLOYMENT_TARGET = 8.3;
				PRODUCT_NAME = MyProject;
				SDKROOT = iphoneos;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationTarget_OnIOSMinMaxVersion()
		_TARGET_OS = "ios"
		systemversion "8.3:9.1"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				IPHONEOS_DEPLOYMENT_TARGET = 8.3;
				PRODUCT_NAME = MyProject;
				SDKROOT = iphoneos;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationTarget_OnIOSCodeSigningIdentity()
		_TARGET_OS = "ios"
		xcodecodesigningidentity "Premake Developers"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Premake Developers";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
				SDKROOT = iphoneos;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationTarget_OnIOSFamily()
		_TARGET_OS = "ios"
		iosfamily "Universal"
		prepare()
		xcode.XCBuildConfiguration_Target(tr, tr.products.children[1], tr.configs[1])
		test.capture [[
		FDC4CBFB4635B02D8AD4823B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
				CONFIGURATION_BUILD_DIR = bin/Debug;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				GCC_DYNAMIC_NO_PIC = NO;
				INSTALL_PATH = /usr/local/bin;
				PRODUCT_NAME = MyProject;
				SDKROOT = iphoneos;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		]]
	end


---------------------------------------------------------------------------
-- XCBuildConfiguration_Project tests
---------------------------------------------------------------------------

	function suite.XCBuildConfigurationProject_OnConsoleApp()
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnOptimizeSize()
		optimize "Size"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = s;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnOptimizeSpeed()
		optimize "Speed"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 3;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnStaticRuntime()
		staticruntime "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				STANDARD_C_PLUS_PLUS_LIBRARY_TYPE = static;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnTargetDir()
		targetdir "bin"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnDefines()
		defines { "_DEBUG", "DEBUG" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					_DEBUG,
					DEBUG,
				);
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnIncludeDirs()
		includedirs { "../include", "../libs", "../name with spaces" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				USER_HEADER_SEARCH_PATHS = (
					../include,
					../libs,
					"\"../name with spaces\"",
				);
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnExternalIncludeDirs()
		externalincludedirs { "../include", "../libs", "../name with spaces" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				SYSTEM_HEADER_SEARCH_PATHS = (
					../include,
					../libs,
					"\"../name with spaces\"",
					"$(inherited)",
				);
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnIncludeDirsAfter()
		includedirsafter { "../include", "../libs", "../name with spaces" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				SYSTEM_HEADER_SEARCH_PATHS = (
					../include,
					../libs,
					"\"../name with spaces\"",
					"$(inherited)",
				);
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnBuildOptions()
		buildoptions { "build option 1", "build option 2" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"build option 1",
					"build option 2",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnRunPathSearchPaths()
		runpathdirs { "plugins" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LD_RUNPATH_SEARCH_PATHS = (
					"@loader_path/../../plugins",
				);
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnLinks()
		links { "Cocoa.framework", "ldap" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_LDFLAGS = (
					"-lldap",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnLinkOptions()
		linkoptions { "link option 1", "link option 2" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_LDFLAGS = (
					"link option 1",
					"link option 2",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnNoWarnings()
		warnings "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				WARNING_CFLAGS = "-w";
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnHighWarnings()
		warnings "High"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				WARNING_CFLAGS = "-Wall";
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnExtraWarnings()
		warnings "Extra"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				WARNING_CFLAGS = "-Wall -Wextra";
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnEverythingWarnings()
		warnings "Everything"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_WARN_ASSIGN_ENUM = YES;
				CLANG_WARN_ATOMIC_IMPLICIT_SEQ_CST = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_COMPLETION_HANDLER_MISUSE = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_CXX0X_EXTENSIONS = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_FLOAT_CONVERSION = YES;
				CLANG_WARN_FRAMEWORK_INCLUDE_PRIVATE_FROM_PUBLIC = YES;
				CLANG_WARN_IMPLICIT_FALLTHROUGH = YES;
				CLANG_WARN_IMPLICIT_SIGN_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_EXPLICIT_OWNERSHIP_TYPE = YES;
				CLANG_WARN_OBJC_IMPLICIT_ATOMIC_PROPERTIES = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_INTERFACE_IVARS = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_MISSING_PROPERTY_SYNTHESIS = YES;
				CLANG_WARN_OBJC_REPEATED_USE_OF_WEAK = YES;
				CLANG_WARN_PRAGMA_PACK = YES;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_SEMICOLON_BEFORE_METHOD_BODY = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_IMPLICIT_CONVERSION = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				CLANG_WARN__EXIT_TIME_DESTRUCTORS = YES;
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_MISSING_FIELD_INITIALIZERS = YES;
				GCC_WARN_ABOUT_MISSING_NEWLINE = YES;
				GCC_WARN_ABOUT_MISSING_PROTOTYPES = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_HIDDEN_VIRTUAL_FUNCTIONS = YES;
				GCC_WARN_INHIBIT_ALL_WARNINGS = NO;
				GCC_WARN_INITIALIZER_NOT_FULLY_BRACKETED = YES;
				GCC_WARN_NON_VIRTUAL_DESTRUCTOR = YES;
				GCC_WARN_PEDANTIC = YES;
				GCC_WARN_SHADOW = YES;
				GCC_WARN_SIGN_COMPARE = YES;
				GCC_WARN_STRICT_SELECTOR_MATCH = YES;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES;
				GCC_WARN_UNKNOWN_PRAGMAS = YES;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_LABEL = YES;
				GCC_WARN_UNUSED_PARAMETER = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
				WARNING_CFLAGS = "-Weverything";
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnFatalWarningsViaFlag()
		flags { "FatalWarnings" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_TREAT_WARNINGS_AS_ERRORS = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnFatalWarningsViaAPI()
		fatalwarnings { "All" }
		linkerfatalwarnings { "All" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_TREAT_WARNINGS_AS_ERRORS = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnFloatFast()
		floatingpoint "Fast"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-ffast-math",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnOpenMP()
		openmp "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-fopenmp",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnFloatStrict()
		floatingpoint "Strict"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnNoEditAndContinue()
		editandcontinue "Off"
		symbols "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				COPY_PHASE_STRIP = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = YES;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnNoExceptions()
		exceptionhandling "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_ENABLE_CPP_EXCEPTIONS = NO;
				GCC_ENABLE_OBJC_EXCEPTIONS = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnNoFramePointer()
		omitframepointer "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-fomit-frame-pointer",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnOmitFramePointer()
		omitframepointer "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-fomit-frame-pointer",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnNoOmitFramePointer()
		omitframepointer "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				OTHER_CFLAGS = (
					"-fno-omit-frame-pointer",
				);
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnNoPCH()
		pchheader "MyProject_Prefix.pch"
		flags { "NoPCH" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnNoRTTI()
		rtti "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_ENABLE_CPP_RTTI = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnSymbols()
		symbols "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				COPY_PHASE_STRIP = NO;
				GCC_ENABLE_FIX_AND_CONTINUE = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = YES;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnLibDirs()
		libdirs { "mylibs1", "mylibs2" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LIBRARY_SEARCH_PATHS = (
					mylibs1,
					mylibs2,
				);
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnSysLibDirs()
		libdirs { "mylibs1", "mylibs2" }
		syslibdirs { "mysyslib3", "mysyslib4" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LIBRARY_SEARCH_PATHS = (
					mylibs1,
					mylibs2,
					mysyslib3,
					mysyslib4,
				);
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnPCH()
		pchheader "MyProject_Prefix.pch"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PRECOMPILE_PREFIX_HEADER = YES;
				GCC_PREFIX_HEADER = MyProject_Prefix.pch;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnUniversal()
		workspace("MyWorkspace")
		platforms { "Universal" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_64_BIT)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Universal/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Universal/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnUniversal32()
		workspace("MyWorkspace")
		platforms { "Universal32" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_BIT)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Universal32/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Universal32/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnUniversal64()
		workspace("MyWorkspace")
		platforms { "Universal64" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_64_BIT)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Universal64/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Universal64/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnNative()
		workspace("MyWorkspace")
		platforms { "Native" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Native/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Native/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnX86()
		workspace("MyWorkspace")
		platforms { "x86" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = i386;
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/x86/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/x86/Debug;
			};
			name = Debug;
		};
		]]
	end


	function suite.XCBuildConfigurationProject_OnX86_64()
		workspace("MyWorkspace")
		platforms { "x86_64" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = x86_64;
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/x86_64/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/x86_64/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnMultiplePlatforms()
		workspace("MyWorkspace")
		platforms { "Universal32", "Universal64" }
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(ARCHS_STANDARD_32_BIT)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Universal32/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Universal32/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCDefault()
		workspace("MyWorkspace")
		cdialect("Default")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = "compiler-default";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnC89()
		workspace("MyWorkspace")
		cdialect("C89")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c89;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnC90()
		workspace("MyWorkspace")
		cdialect("C90")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c90;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnC99()
		workspace("MyWorkspace")
		cdialect("C99")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnC11()
		workspace("MyWorkspace")
		cdialect("C11")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c11;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnC17()
		workspace("MyWorkspace")
		cdialect("C17")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c17;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnC23()
		workspace("MyWorkspace")
		cdialect("C23")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = c23;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnGnu89()
		workspace("MyWorkspace")
		cdialect("gnu89")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu89;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnGnu90()
		workspace("MyWorkspace")
		cdialect("gnu90")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu90;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnGnu99()
		workspace("MyWorkspace")
		cdialect("gnu99")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu99;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnGnu11()
		workspace("MyWorkspace")
		cdialect("gnu11")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnGnu17()
		workspace("MyWorkspace")
		cdialect("gnu17")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnGnu23()
		workspace("MyWorkspace")
		cdialect("gnu23")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_C_LANGUAGE_STANDARD = gnu23;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCppDefault()
		workspace("MyWorkspace")
		cppdialect("Default")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "compiler-default";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCpp98()
		workspace("MyWorkspace")
		cppdialect("C++98")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++98";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
    end

    function suite.XCBuildConfigurationProject_OnCpp11()
		workspace("MyWorkspace")
		cppdialect("C++11")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++11";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCpp0x()
		workspace("MyWorkspace")
		cppdialect("C++0x")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++11";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCpp14()
		workspace("MyWorkspace")
		cppdialect("C++14")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++14";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
    end

    function suite.XCBuildConfigurationProject_OnCpp1y()
		workspace("MyWorkspace")
		cppdialect("C++1y")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++14";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCpp17()
		workspace("MyWorkspace")
		cppdialect("C++17")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++17";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
    end

    function suite.XCBuildConfigurationProject_OnCpp1z()
		workspace("MyWorkspace")
		cppdialect("C++1z")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++1z";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCpp20()
		workspace("MyWorkspace")
		cppdialect("C++20")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++20";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
    end

    function suite.XCBuildConfigurationProject_OnCpp2a()
		workspace("MyWorkspace")
		cppdialect("C++2a")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++2a";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCpp2b()
		workspace("MyWorkspace")
		cppdialect("C++2b")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++2b";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCpp23()
		workspace("MyWorkspace")
		cppdialect("C++23")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "c++23";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu98()
		workspace("MyWorkspace")
		cppdialect("gnu++98")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++98";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu11()
		workspace("MyWorkspace")
		cppdialect("gnu++11")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++0x";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
    end

    function suite.XCBuildConfigurationProject_OnCppGnu0x()
		workspace("MyWorkspace")
		cppdialect("gnu++0x")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++0x";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu14()
		workspace("MyWorkspace")
		cppdialect("gnu++14")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
    end

    function suite.XCBuildConfigurationProject_OnCppGnu1y()
		workspace("MyWorkspace")
		cppdialect("gnu++1y")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu17()
		workspace("MyWorkspace")
		cppdialect("gnu++17")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++17";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
    end

    function suite.XCBuildConfigurationProject_OnCppGnu1z()
		workspace("MyWorkspace")
		cppdialect("gnu++1z")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++1z";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu20()
		workspace("MyWorkspace")
		cppdialect("gnu++20")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
    end

    function suite.XCBuildConfigurationProject_OnCppGnu2a()
		workspace("MyWorkspace")
		cppdialect("gnu++2a")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++2a";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnCppGnu2b()
		workspace("MyWorkspace")
		cppdialect("gnu++2b")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++2b";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
    end

	function suite.XCBuildConfigurationProject_OnCppGnu23()
		workspace("MyWorkspace")
		cppdialect("gnu++23")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++23";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
    end

	function suite.XCBuildConfigurationProject_OnUnsignedCharOn()
		workspace("MyWorkspace")
		unsignedchar "On"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_CHAR_IS_UNSIGNED_CHAR = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnUnsignedCharOff()
		workspace("MyWorkspace")
		unsignedchar "Off"
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_CHAR_IS_UNSIGNED_CHAR = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnRemoveXcodebuildSettings()
		xcodebuildsettings {
			ARCHS = false
		}
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnSwift4_0()
		workspace("MyWorkspace")
		swiftversion("4.0")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SWIFT_VERSION = 4.0;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnSwift4_2()
		workspace("MyWorkspace")
		swiftversion("4.2")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SWIFT_VERSION = 4.2;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

	function suite.XCBuildConfigurationProject_OnSwift5_0()
		workspace("MyWorkspace")
		swiftversion("5.0")
		prepare()
		xcode.XCBuildConfiguration_Project(tr, tr.configs[1])
		test.capture [[
		A14350AC4595EE5E57CE36EC /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ARCHS = "$(NATIVE_ARCH_ACTUAL)";
				CONFIGURATION_BUILD_DIR = "$(SYMROOT)";
				CONFIGURATION_TEMP_DIR = "$(OBJROOT)";
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_SYMBOLS_PRIVATE_EXTERN = NO;
				GCC_WARN_ABOUT_RETURN_TYPE = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				OBJROOT = obj/Debug;
				ONLY_ACTIVE_ARCH = NO;
				SWIFT_VERSION = 5.0;
				SYMROOT = bin/Debug;
			};
			name = Debug;
		};
		]]
	end

---------------------------------------------------------------------------
-- XCBuildConfigurationList tests
---------------------------------------------------------------------------

	function suite.XCBuildConfigurationList_OnNoPlatforms()
		prepare()
		xcode.XCBuildConfigurationList(tr)
		test.capture [[
/* Begin XCConfigurationList section */
		1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A14350AC4595EE5E57CE36EC /* Debug */,
				F3C205E6F732D818789F7C26 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
		8E187FB5316408E74C34D5F5 /* Build configuration list for PBXNativeTarget "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				FDC4CBFB4635B02D8AD4823B /* Debug */,
				C8EAD1B5F1258A67D8C117F5 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
/* End XCConfigurationList section */
		]]
	end


	function suite.XCBuildConfigurationList_OnSinglePlatforms()
		platforms { "Universal32" }
		prepare()
		xcode.XCBuildConfigurationList(tr)
		test.capture [[
/* Begin XCConfigurationList section */
		1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A14350AC4595EE5E57CE36EC /* Debug */,
				F3C205E6F732D818789F7C26 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
		8E187FB5316408E74C34D5F5 /* Build configuration list for PBXNativeTarget "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				FDC4CBFB4635B02D8AD4823B /* Debug */,
				C8EAD1B5F1258A67D8C117F5 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
/* End XCConfigurationList section */
		]]
	end


	function suite.XCBuildConfigurationList_OnMultiplePlatforms()
		workspace("MyWorkspace")
		platforms { "Universal32", "Universal64" }
		prepare()
		xcode.XCBuildConfigurationList(tr)
		test.capture [[
/* Begin XCConfigurationList section */
		1DEB928908733DD80010E9CD /* Build configuration list for PBXProject "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A14350AC4595EE5E57CE36EC /* Debug */,
				A14350AC4595EE5E57CE36EC /* Debug */,
				F3C205E6F732D818789F7C26 /* Release */,
				F3C205E6F732D818789F7C26 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
		8E187FB5316408E74C34D5F5 /* Build configuration list for PBXNativeTarget "MyProject" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				FDC4CBFB4635B02D8AD4823B /* Debug */,
				FDC4CBFB4635B02D8AD4823B /* Debug */,
				C8EAD1B5F1258A67D8C117F5 /* Release */,
				C8EAD1B5F1258A67D8C117F5 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
/* End XCConfigurationList section */
		]]
	end

function suite.defaultVisibility_settingIsFound()
	prepare()
	xcode.XCBuildConfiguration(tr)
	local str = p.captured()
	test.istrue(str:find('GCC_SYMBOLS_PRIVATE_EXTERN'))
end


function suite.defaultVisibilitySetting_setToNo()
	prepare()
	xcode.XCBuildConfiguration(tr)
	local str = p.captured()
	test.istrue(str:find('GCC_SYMBOLS_PRIVATE_EXTERN = NO;'))
end

function suite.releaseBuild_onlyDefaultArch_equalsNo()
	optimize "On"
	prepare()
	xcode.XCBuildConfiguration_Project(tr, tr.configs[2])
	local str = p.captured()
	test.istrue(str:find('ONLY_ACTIVE_ARCH = NO;'))
end

function suite.debugBuild_onlyDefaultArch_equalsYes()
	symbols "On"
	prepare()
	xcode.XCBuildConfiguration_Project(tr, tr.configs[1])

	local str = p.captured()
	test.istrue(str:find('ONLY_ACTIVE_ARCH = YES;'))
end
