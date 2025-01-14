---
-- Premake 5.x build configuration script
-- Use this script to configure the project with Premake5.
---

--
-- Remember my location; I will need it to locate sub-scripts later.
--

	local corePath = _SCRIPT_DIR


--
-- Disable deprecation warnings for myself, so that older development
-- versions of Premake can be used to bootstrap new builds.
--

	premake.api.deprecations "off"


--
-- Register supporting actions and options.
--

	newaction {
		trigger = "embed",
		description = "Embed scripts in scripts.c; required before release builds",
		execute = function ()
			include (path.join(corePath, "scripts/embed.lua"))
		end
	}


	newaction {
		trigger = "package",
		description = "Creates source and binary packages",
		execute = function ()
			include (path.join(corePath, "scripts/package.lua"))
		end
	}


	newaction {
		trigger = "docs-check",
		description = "Validates documentation files for Premake APIs",
		execute = function ()
			include (path.join(corePath, "scripts/docscheck.lua"))
		end
	}


	newaction {
		trigger = "test",
		description = "Run the automated test suite",
		execute = function ()
			test = require "self-test"
			premake.action.call("self-test")
		end
	}


	newoption {
		trigger = "test-all",
		description = "Run all unit tests, including slower network and I/O"
	}


	newoption {
		trigger = "test-only",
		description = "When testing, run only the specified suite or test"
	}


	newoption {
		trigger = "to",
		value   = "path",
		description = "Set the output location for the generated files"
	}


	newoption {
		trigger = "curl-src",
		description = "Specify the source of the Curl 3rd party library",
		allowed = {
			{ "none", "Disables Curl" },
			{ "contrib", "Uses Curl in contrib folder" },
			{ "system", "Uses Curl from the host system" },
		},
		default = "contrib",
	}

	newoption {
		trigger = "no-curl",
		description = "Disable Curl 3rd party lib"
	}
	if _OPTIONS["no-curl"] then
		premake.warn("--no-curl is deprecated, please use --curl-src=none")
		_OPTIONS["curl-src"] = "none"
	end


	newoption {
		trigger = "zlib-src",
		description = "Specify the source of the Zlib/Zip 3rd party library",
		allowed = {
			{ "none", "Disables Zlib/Zip" },
			{ "contrib", "Uses Zlib/Zip in contrib folder" },
			{ "system", "Uses Zlib/Zip from the host system" },
		},
		default = "contrib",
	}

	newoption {
		trigger = "no-zlib",
		description = "Disable Zlib/Zip 3rd party lib"
	}
	if _OPTIONS["no-zlib"] then
		premake.warn("--no-zlib is deprecated, please use --zlib-src=none")
		_OPTIONS["zlib-src"] = "none"
	end

	newoption {
		trigger = "no-luasocket",
		description = "Disable Luasocket 3rd party lib"
	}

	newoption {
		trigger = "lua-src",
		description = "Specify the source of the Lua 3rd party library",
		allowed = {
			{ "contrib", "Uses Lua in contrib folder" },
			{ "system", "Uses Lua from the host system" },
		},
		default = "contrib",
	}

	newoption {
		trigger = "lib-src",
		description = "Specify the source of all 3rd party libraries",
		allowed = {
			{ "none", "Disables all optional 3rd party libraries" },
			{ "contrib", "Uses 3rd party libraries in contrib folder" },
			{ "system", "Uses 3rd party libraries from the host system" },
		}
	}

	if _OPTIONS["lib-src"] == "none" then
		_OPTIONS["curl-src"] = "none"
		_OPTIONS["zlib-src"] = "none"
		-- Lua is not optional
	elseif _OPTIONS["lib-src"] == "contrib" then
		_OPTIONS["curl-src"] = "contrib"
		_OPTIONS["zlib-src"] = "contrib"
		_OPTIONS["lua-src"] = "contrib"
	elseif _OPTIONS["lib-src"] == "system" then
		_OPTIONS["curl-src"] = "system"
		_OPTIONS["zlib-src"] = "system"
		_OPTIONS["lua-src"] = "system"
	end

	newoption {
		trigger     = "bytecode",
		description = "Embed scripts as bytecode instead of stripped source code"
	}

	newoption {
		trigger = "arch",
		value = "arch",
		description = "Set the architecture of the binary to be built.",
		allowed = {
			{ "ARM", "ARM (On macOS, same as ARM64.)" },
			{ "ARM64", "ARM64" },
			{ "x86", "x86 (On macOS, same as x86_64.)" },
			{ "x86_64", "x86_64" },
			{ "Universal", "Universal Binary (macOS only)" },
			--
			{ "Win32", "Same as x86" },
			{ "x64", "Same as x86_64" },
		},
		-- "Generates default platforms for targets, x86 and x86_64 projects for Windows." }
		default = nil,
	}

--
-- Define the project. Put the release configuration first so it will be the
-- default when folks build using the makefile. That way they don't have to
-- worry about the /scripts argument and all that.
--
-- TODO: Switch to these new APIs once they've had a chance to land everywhere
--
--    defaultConfiguration "Release"
--    symbols "On"
--

	solution "Premake5"
		configurations { "Release", "Debug" }
		location ( _OPTIONS["to"] )

		flags { "MultiProcessorCompile" }
		warnings "Extra"

		filter { "options:not zlib-src=none" }
			defines { "PREMAKE_COMPRESSION" }

		filter { "options:not curl-src=none" }
			defines { "PREMAKE_CURL" }
		filter { "options:curl-src=contrib" }
			defines { "CURL_STATICLIB" }

		filter { "options:lua-src=contrib" }
			defines { "LUA_STATICLIB" }

		filter { "system:macosx", "options:arch=ARM or arch=ARM64" }
			buildoptions { "-arch arm64" }
			linkoptions { "-arch arm64" }

		filter { "system:macosx", "options:arch=x86 or arch=x86_64 or arch=Win32 or arch=x64" }
			buildoptions { "-arch x86_64" }
			linkoptions { "-arch x86_64" }

		filter { "system:macosx", "options:arch=Universal" }
			buildoptions { "-arch arm64", "-arch x86_64" }
			linkoptions { "-arch arm64", "-arch x86_64" }

		filter { "system:windows", "options:arch=ARM" }
			platforms { "ARM" }

		filter { "system:windows", "options:arch=ARM64" }
			platforms { "ARM64" }

		filter { "system:windows", "options:arch=x86 or arch=Win32" }
			platforms { "Win32" }

		filter { "system:windows", "options:arch=x86_64 or arch=x64" }
			platforms { "x64" }

		filter { "system:windows", "options:not arch" }
			platforms { "x86", "x64" }

		filter "configurations:Debug"
			defines     "_DEBUG"
			symbols	    "On"

		filter "configurations:Release"
			defines     "NDEBUG"
			optimize    "Full"
			flags       { "NoBufferSecurityCheck", "NoRuntimeChecks" }

		filter "action:vs*"
			defines     { "_CRT_SECURE_NO_DEPRECATE", "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_WARNINGS" }

		filter { "system:windows", "configurations:Release" }
			flags       { "NoIncrementalLink" }

		-- MinGW AR does not handle LTO out of the box and need a plugin to be setup
		filter { "system:windows", "configurations:Release", "toolset:not mingw" }
			flags		{ "LinkTimeOptimization" }

		filter { "system:uwp" }
			systemversion "latest:latest"
			consumewinrtextension "false"

	project "Premake5"
		targetname  "premake5"
		language    "C"
		kind        "ConsoleApp"

		files
		{
			"*.txt", "**.lua",
			"src/**.h", "src/**.c",
			"modules/**"
		}

		excludes
		{
			"contrib/**.*",
			"binmodules/**.*"
		}

		filter { "options:lua-src=contrib" }
			includedirs { "contrib/lua/src", "contrib/luashim" }
			links       { "lua-lib" }

		filter { "options:lua-src=system" }
			links { "lua5.3" }

		-- optional 3rd party libraries
		filter { "options:zlib-src=contrib" }
			includedirs { "contrib/zlib", "contrib/libzip" }
			links { "zip-lib", "zlib-lib" }

		filter { "options:zlib-src=system" }
			links { "zip", "z" }

		filter { "options:curl-src=contrib" }
			includedirs { "contrib/curl/include" }
			links { "curl-lib" }

		filter { "options:curl-src=system" }
			links { "curl" }

		filter "configurations:Debug"
			targetdir   "bin/debug"
			debugargs   { "--scripts=%{prj.location}/%{path.getrelative(prj.location, prj.basedir)}", "test" }
			debugdir    "."

		filter "configurations:Release"
			targetdir   "bin/release"

		filter "system:windows"
			links       { "ole32", "ws2_32", "advapi32", "version" }
			files { "src/**.rc" }

		filter "toolset:mingw"
			links		{ "crypt32", "bcrypt" }

		filter "system:linux or bsd or hurd"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }
			links       { "m" }
			linkoptions { "-rdynamic" }

		filter "system:linux or hurd"
			links       { "dl", "rt" }

		filter { "system:not windows", "system:not macosx", "options:curl-src=contrib" }
			links       { "mbedtls-lib" }

		filter "system:macosx"
			defines     { "LUA_USE_MACOSX" }
			links       { "CoreServices.framework", "Foundation.framework", "Security.framework", "readline" }

		filter { "system:linux", "toolset:not cosmocc" }
			links		{ "uuid" }

		filter { "system:macosx", "action:gmake" }
			toolset "clang"

		filter { "system:solaris" }
			links       { "m", "socket", "nsl" }

		filter "system:aix"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN" }
			links       { "m" }

		filter "system:haiku"
			defines     { "LUA_USE_POSIX", "LUA_USE_DLOPEN", "_BSD_SOURCE" }
			links       { "network", "bsd" }

if premake.action.supports("None") then
	project "Web"
		kind "None"

		files
		{
			"website/blog/**",
			"website/community/**",
			"website/docs/**",
			"website/src/**",
			"website/static/**",
			"website/*"
		}
		-- ensure that "website/node_modules/**" is not there (generated files)

	project "Github"
		kind "None"

		files ".github/**"
end

	-- optional 3rd party libraries
	group "contrib"
		if _OPTIONS["lua-src"] == "contrib" then
			include "contrib/lua"
			include "contrib/luashim"
		end

		if _OPTIONS["zlib-src"] == "contrib" then
			include "contrib/zlib"
			include "contrib/libzip"
		end

		if _OPTIONS["curl-src"] == "contrib" then
			include "contrib/mbedtls"
			include "contrib/curl"
		end

	if _OPTIONS["lua-src"] == "contrib" and _OPTIONS["cc"] ~= "cosmocc" then
		group "Binary Modules"
			include "binmodules/example"

			if not _OPTIONS["no-luasocket"] then
				include "binmodules/luasocket"
			end
	end

--
-- A more thorough cleanup.
--

	if _ACTION == "clean" then
		os.rmdir("bin")
		os.rmdir("build")
	end
