---
title: What's New in 5.0
---

*We haven't been doing a great job of keeping this up-to-date, but it does still hit the major highlights.*

## Name Changes ##

* The executable is now named **premake5**
* The default project script is now **premake5.lua**; premake4.lua remains as a fallback.

## Flags and Actions ##

* --interactive (open an interactive command prompt)
* vs2012, vs2013, vs2015, vs2019 (Visual Studio 2012, 2013, 2015, 2019)

## Major Features ##

* [Custom Rules](Custom-Rules.md) (still experimental)
* [Makefile Projects](Makefile-Projects.md)
* [Modules](Developing-Modules.md)
* [Per-Configuration File Lists](files.md)
* [Per-File Configurations](configuration.md)
* [Per-Project Configurations](Configurations-and-Platforms.md)
* [Platforms](Configurations-and-Platforms.md)
* [Removes](Removing-Values.md)
* [System Scripts](System-Scripts.md)
* [Tokens](Tokens.md)
* [HTTP support](http/http.download.md)

## New or Modified Globals ##

* [_MAIN_SCRIPT](globals/premake_MAIN_SCRIPT.md)
* [_MAIN_SCRIPT_DIR](globals/premake_MAIN_SCRIPT_DIR.md)
* [_PREMAKE_DIR](globals/premake_PREMAKE_DIR.md)

## New or Modified API calls ##

* [architecture](architecture.md) (new)
* [buildaction](buildaction.md) (new values)
* [buildcommands](buildcommands.md) (new)
* [builddependencies](builddependencies.md) (new)
* [buildlog](buildlog.md) (new)
* [buildmessage](buildmessage.md) (new)
* [buildoutputs](buildoutputs.md) (new)
* [characterset](characterset.md) (new)
* [callingconvention](callingconvention.md) (new)
* [cleancommands](cleancommands.md) (new)
* [cleanextensions](cleanextensions.md) (new)
* [clr](clr.md) (new, replaces flags `Managed` and `Unsafe`)
* [configfile](configfile.md) (new)
* [configmap](configmap.md) (new)
* [configuration](configuration.md) (retired)
* [configurations](configurations.md) (modified)
* [copylocal](copylocal.md) (new)
* [debugcommand](debugcommand.md) (new)
* [debugconnectcommands](debugconnectcommands.md) (new)
* [debugextendedprotocol](debugextendedprotocol.md) (new)
* [debugport](debugport.md) (new)
* [debugremotehost](debugremotehost.md) (new)
* [debugsearchpaths](debugsearchpaths.md) (new)
* [debugstartupcommands](debugstartupcommands.md) (new)
* [dependson](dependson.md) (new)
* [disablewarnings](disablewarnings.md) (new)
* [dotnetframework](dotnetframework.md) (new)
* [editandcontinue](editandcontinue.md) (new, replaces flag `NoEditAndContinue`)
* [editorintegration](editorintegration.md) (new)
* [enablewarnings](enablewarnings.md) (new)
* [endian](endian.md) (new)
* [entrypoint](entrypoint.md) (new)
* [exceptionhandling](exceptionhandling.md) (new)
* [external](external.md) (new)
* [externalanglebrackets](externalanglebrackets.md) (new)
* [externalincludedirs](externalincludedirs.md) (new)
* [externalwarnings](externalwarnings.md) (new)
* [externalproject](externalproject.md) (new)
* [externalrule](externalrule.md) (new)
* [fatalwarnings](fatalwarnings.md) (new)
* [fileextension](fileextension.md) (new)
* [filename](filename.md) (new)
* [filter](filter.md) (new)
* [flags](flags.md) (new values)
* [floatingpoint](floatingpoint.md) (new, replaces flags `FloatFast` and `FloatStrict`)
* [forceincludes](forceincludes.md) (new)
* [forceusings](forceusings.md) (new)
* [fpu](fpu.md) (new)
* [gccprefix](gccprefix.md) (new)
* [group](group.md) (new)
* [icon](icon.md) (new)
* [inlining](inlining.md) (new)
* [kind](kind.md) (Makefile, None)
* [linkbuildoutputs](linkbuildoutputs.md) (new)
* [links](links.md)
* [language](language.md) (new values)
* [locale](locale.md) (new)
* [makesettings](makesettings.md) (new)
* [namespace](namespace.md) (new)
* [nativewchar](nativewchar.md) (new, replaces flag `NativeWChar`)
* [newaction](newaction.md) (modified)
* [nuget](nuget.md) (new)
* [objdir](objdir.md) (modified)
* [optimize](optimize.md) (new, replaces flags `OptimizeSize` and `OptimizeSpeed`)
* [pic](pic.md) (new)
* [platforms](platforms.md) (modified)
* [postbuildmessage](postbuildmessage.md) (new)
* [prebuildmessage](prebuildmessage.md) (new)
* [prelinkmessage](prelinkmessage.md) (new)
* [project](project.md) (modified)
* [propertydefinition](propertydefinition.md) (new)
* [rebuildcommands](rebuildcommands.md) (new)
* [rtti](rtti.md) (new, replaces flag `NoRTTI`)
* [rule](rule.md) (new)
* [rules](rules.md) (new)
* [runtime](runtime.md) (new)
* [solution](workspace.md) (name changed)
* [startproject](startproject.md) (new)
* [strictaliasing](strictaliasing.md) (new)
* [sysincludedirs](sysincludedirs.md) (new)
* [syslibdirs](syslibdirs.md) (new)
* [system](system.md) (new)
* [toolset](toolset.md) (new)
* [toolsversion](toolsversion.md) (new)
* [undefines](undefines.md) (new)
* [vectorextensions](vectorextensions.md) (new, replaces flags `EnableSSE` and `EnableSSE2`)
* [warnings](warnings.md) (new, replaces flags `ExtraWarnings` and `NoWarnings`)
* [workspace](workspace.md) (new)

## New or Modified Lua library calls ##

* [includeexternal](globals/includeexternal.md) (new)
* [require](globals/require.md) (modified)

* [debug.prompt](debug.prompt.md) (new)

* [http.download](http/http.download.md) (new)
* [http.get](http/http.get.md) (new)

* [os.chmod](os/os.chmod.md) (new)
* [os.islink](os/os.islink.md) (new)
* [os.realpath](os/os.realpath.md) (new)
* [os.uuid](os/os.uuid.md) (can now generated deterministic name-based UUIDs)

* [path.getabsolute](path/path.getabsolute.md) (new "relative to" argument)

* [string.hash](string/string.hash.md) (new)

## Deprecated Values and Functions ##

* [flags](flags.md):
	* Component
	* EnableSSE, EnableSSE2: use [vectorextensions](vectorextensions.md) instead
	* ExtraWarnings, NoWarnings: use [warnings](warnings.md) instead
	* FloatFast, FloatStrict: use [floatingpoint](floatingpoint.md) instead
	* Managed, Unsafe: use [clr](clr.md) instead
	* NativeWChar: use [nativewchar](nativewchar.md) instead
	* NoEditAndContinue: use [editandcontinue](editandcontinue.md) instead
	* NoRTTI: use [rtti](rtti.md) instead.
	* OptimizeSize, OptimizeSpeed: use [optimize](optimize.md) instead
