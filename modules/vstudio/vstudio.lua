--
-- vstudio.lua
-- Define the Visual Studio 200x actions.
-- Copyright (c) Jess Perkins and the Premake project
--

	local p = premake

	p.modules.vstudio = p.modules.vstudio or {}
	p.modules.vstudio._VERSION = p._VERSION

	-- for backwards compatibility.
	p.vstudio = p.modules.vstudio

	local vstudio = p.vstudio
	local project = p.project
	local config = p.config

--
-- Mapping tables from Premake systems and architectures to Visual Studio
-- identifiers. Broken out as tables so new values can be pushed in by
-- add-ons.
--

	vstudio.vs200x_architectures =
	{
		win32   = "x86",
		x86     = "x86",
		x86_64  = "x64",
		ARM     = "ARM",
		ARM64   = "ARM64",
	}

	vstudio.vs2010_architectures =
	{
		win32   = "x86",
	}

	local function architecture(system, arch)
		local result
		if _ACTION >= "vs2010" then
			result = vstudio.vs2010_architectures[arch] or vstudio.vs2010_architectures[system]
		end
		return result or vstudio.vs200x_architectures[arch] or vstudio.vs200x_architectures[system]
	end


--
-- Mapping from ISO locales to MS culture identifiers.
-- http://msdn.microsoft.com/en-us/library/system.globalization.cultureinfo%28v=vs.85%29.ASPX
--

	vstudio._cultures = {
		["af"] = 0x0036,
		["af-ZA"] = 0x0436,
		["sq"] = 0x001C,
		["sq-AL"] = 0x041C,
		["ar"] = 0x0001,
		["ar-DZ"] = 0x1401,
		["ar-BH"] = 0x3C01,
		["ar-EG"] = 0x0C01,
		["ar-IQ"] = 0x0801,
		["ar-JO"] = 0x2C01,
		["ar-KW"] = 0x3401,
		["ar-LB"] = 0x3001,
		["ar-LY"] = 0x1001,
		["ar-MA"] = 0x1801,
		["ar-OM"] = 0x2001,
		["ar-QA"] = 0x4001,
		["ar-SA"] = 0x0401,
		["ar-SY"] = 0x2801,
		["ar-TN"] = 0x1C01,
		["ar-AE"] = 0x3801,
		["ar-YE"] = 0x2401,
		["hy"] = 0x002B,
		["hy-AM"] = 0x042B,
		["az"] = 0x002C,
		["az-Cyrl-AZ"] = 0x082C,
		["az-Latn-AZ"] = 0x042C,
		["eu"] = 0x002D,
		["eu-ES"] = 0x042D,
		["be"] = 0x0023,
		["be-BY"] = 0x0423,
		["bg"] = 0x0002,
		["bg-BG"] = 0x0402,
		["ca"] = 0x0003,
		["ca-ES"] = 0x0403,
		["zh-HK"] = 0x0C04,
		["zh-MO"] = 0x1404,
		["zh-CN"] = 0x0804,
		["zh-Hans"] = 0x0004,
		["zh-SG"] = 0x1004,
		["zh-TW"] = 0x0404,
		["zh-Hant"] = 0x7C04,
		["hr"] = 0x001A,
		["hr-HR"] = 0x041A,
		["cs"] = 0x0005,
		["cs-CZ"] = 0x0405,
		["da"] = 0x0006,
		["da-DK"] = 0x0406,
		["dv"] = 0x0065,
		["dv-MV"] = 0x0465,
		["nl"] = 0x0013,
		["nl-BE"] = 0x0813,
		["nl-NL"] = 0x0413,
		["en"] = 0x0009,
		["en-AU"] = 0x0C09,
		["en-BZ"] = 0x2809,
		["en-CA"] = 0x1009,
		["en-029"] = 0x2409,
		["en-IE"] = 0x1809,
		["en-JM"] = 0x2009,
		["en-NZ"] = 0x1409,
		["en-PH"] = 0x3409,
		["en-ZA"] = 0x1C09,
		["en-TT"] = 0x2C09,
		["en-GB"] = 0x0809,
		["en-US"] = 0x0409,
		["en-ZW"] = 0x3009,
		["et"] = 0x0025,
		["et-EE"] = 0x0425,
		["fo"] = 0x0038,
		["fo-FO"] = 0x0438,
		["fa"] = 0x0029,
		["fa-IR"] = 0x0429,
		["fi"] = 0x000B,
		["fi-FI"] = 0x040B,
		["fr"] = 0x000C,
		["fr-BE"] = 0x080C,
		["fr-CA"] = 0x0C0C,
		["fr-FR"] = 0x040C,
		["fr-LU"] = 0x140C,
		["fr-MC"] = 0x180C,
		["fr-CH"] = 0x100C,
		["gl"] = 0x0056,
		["gl-ES"] = 0x0456,
		["ka"] = 0x0037,
		["ka-GE"] = 0x0437,
		["de"] = 0x0007,
		["de-AT"] = 0x0C07,
		["de-DE"] = 0x0407,
		["de-LI"] = 0x1407,
		["de-LU"] = 0x1007,
		["de-CH"] = 0x0807,
		["el"] = 0x0008,
		["el-GR"] = 0x0408,
		["gu"] = 0x0047,
		["gu-IN"] = 0x0447,
		["he"] = 0x000D,
		["he-IL"] = 0x040D,
		["hi"] = 0x0039,
		["hi-IN"] = 0x0439,
		["hu"] = 0x000E,
		["hu-HU"] = 0x040E,
		["is"] = 0x000F,
		["is-IS"] = 0x040F,
		["id"] = 0x0021,
		["id-ID"] = 0x0421,
		["it"] = 0x0010,
		["it-IT"] = 0x0410,
		["it-CH"] = 0x0810,
		["ja"] = 0x0011,
		["ja-JP"] = 0x0411,
		["kn"] = 0x004B,
		["kn-IN"] = 0x044B,
		["kk"] = 0x003F,
		["kk-KZ"] = 0x043F,
		["kok"] = 0x0057,
		["kok-IN"] = 0x0457,
		["ko"] = 0x0012,
		["ko-KR"] = 0x0412,
		["ky"] = 0x0040,
		["ky-KG"] = 0x0440,
		["lv"] = 0x0026,
		["lv-LV"] = 0x0426,
		["lt"] = 0x0027,
		["lt-LT"] = 0x0427,
		["mk"] = 0x002F,
		["mk-MK"] = 0x042F,
		["ms"] = 0x003E,
		["ms-BN"] = 0x083E,
		["ms-MY"] = 0x043E,
		["mr"] = 0x004E,
		["mr-IN"] = 0x044E,
		["mn"] = 0x0050,
		["mn-MN"] = 0x0450,
		["no"] = 0x0014,
		["nb-NO"] = 0x0414,
		["nn-NO"] = 0x0814,
		["pl"] = 0x0015,
		["pl-PL"] = 0x0415,
		["pt"] = 0x0016,
		["pt-BR"] = 0x0416,
		["pt-PT"] = 0x0816,
		["pa"] = 0x0046,
		["pa-IN"] = 0x0446,
		["ro"] = 0x0018,
		["ro-RO"] = 0x0418,
		["ru"] = 0x0019,
		["ru-RU"] = 0x0419,
		["sa"] = 0x004F,
		["sa-IN"] = 0x044F,
		["sr-Cyrl-CS"] = 0x0C1A,
		["sr-Latn-CS"] = 0x081A,
		["sk"] = 0x001B,
		["sk-SK"] = 0x041B,
		["sl"] = 0x0024,
		["sl-SI"] = 0x0424,
		["es"] = 0x000A,
		["es-AR"] = 0x2C0A,
		["es-BO"] = 0x400A,
		["es-CL"] = 0x340A,
		["es-CO"] = 0x240A,
		["es-CR"] = 0x140A,
		["es-DO"] = 0x1C0A,
		["es-EC"] = 0x300A,
		["es-SV"] = 0x440A,
		["es-GT"] = 0x100A,
		["es-HN"] = 0x480A,
		["es-MX"] = 0x080A,
		["es-NI"] = 0x4C0A,
		["es-PA"] = 0x180A,
		["es-PY"] = 0x3C0A,
		["es-PE"] = 0x280A,
		["es-PR"] = 0x500A,
		["es-ES"] = 0x0C0A,
		["es-ES_tradnl"]= 0x040A,
		["es-UY"] = 0x380A,
		["es-VE"] = 0x200A,
		["sw"] = 0x0041,
		["sw-KE"] = 0x0441,
		["sv"] = 0x001D,
		["sv-FI"] = 0x081D,
		["sv-SE"] = 0x041D,
		["syr"] = 0x005A,
		["syr-SY"] = 0x045A,
		["ta"] = 0x0049,
		["ta-IN"] = 0x0449,
		["tt"] = 0x0044,
		["tt-RU"] = 0x0444,
		["te"] = 0x004A,
		["te-IN"] = 0x044A,
		["th"] = 0x001E,
		["th-TH"] = 0x041E,
		["tr"] = 0x001F,
		["tr-TR"] = 0x041F,
		["uk"] = 0x0022,
		["uk-UA"] = 0x0422,
		["ur"] = 0x0020,
		["ur-PK"] = 0x0420,
		["uz"] = 0x0043,
		["uz-Cyrl-UZ"] = 0x0843,
		["uz-Latn-UZ"] = 0x0443,
		["vi"] = 0x002A,
		["vi-VN"] = 0x042A,
	}


--
-- Translate the system and architecture settings from a configuration
-- into a corresponding Visual Studio identifier. If no settings are
-- found in the configuration, a default value is returned, based on
-- the project settings.
--
-- @param cfg
--    The configuration to translate.
-- @param win32
--    If true, enables the "Win32" symbol. If false, uses "x86" instead.
-- @return
--    A Visual Studio architecture identifier.
--

	function vstudio.archFromConfig(cfg, win32)
		local isnative = project.isnative(cfg.project)

		local arch = architecture(cfg.system, cfg.architecture)
		if not arch then
			arch = iif(isnative, "x86", "Any CPU")
		end

		if cfg.system == p.WINDOWS or cfg.system == p.UWP then

			if win32 and isnative and arch == "x86" then
				arch = "Win32"
			end

		end

		return arch
	end


--
-- Attempt to translate a platform identifier into a corresponding
-- Visual Studio architecture identifier.
--
-- @param platform
--    The platform identifier to translate.
-- @return
--    A Visual Studio architecture identifier, or nil if no mapping
--    could be made.
--

	function vstudio.archFromPlatform(platform)
		local system = p.api.checkValue(p.fields.system, platform)
		local arch = p.api.checkValue(p.fields.architecture, platform)
		return architecture(system, arch or platform:lower())
	end


---
-- Given an ISO locale identifier, return an MS culture code.
---

	function vstudio.cultureForLocale(locale)
		if locale then
			local culture = vstudio._cultures[locale]
			if not culture then
				p.warnOnce("Locale" .. locale, 'Unsupported locale "%s"', locale)
			end
			return culture
		end
	end



---
-- Assemble the list of links just the way Visual Studio likes them.
--
-- @param cfg
--    The active configuration.
-- @param explicit
--    True to explicitly include sibling project libraries; if false Visual
--    Studio's default implicit linking will be used.
-- @return
--    The list of linked libraries, ready to be used in Visual Studio's
--    AdditionalDependencies element.
---

	function vstudio.getLinks(cfg, explicit)
		return p.tools.msc.getlinks(cfg, not explicit)
	end



--
-- Return true if the configuration kind is one of "Makefile" or "None". The
-- latter is generated like a Makefile project and excluded from the solution.
--

	function vstudio.isMakefile(cfg)
		return (cfg.kind == p.MAKEFILE or cfg.kind == p.NONE)
	end


--
-- If a dependency of a project configuration is excluded from that particular
-- build configuration or platform, Visual Studio will still try to link it.
-- This function detects that case, so that the individual actions can work
-- around it by switching to external linking.
--
-- @param cfg
--    The configuration to test.
-- @return
--    True if the configuration excludes one or more dependencies.
--

	function vstudio.needsExplicitLink(cfg)
		if not cfg._needsExplicitLink then
			local ex = cfg.flags.NoImplicitLink
			if not ex then
				local prjdeps = project.getdependencies(cfg.project, "linkOnly")
				local cfgdeps = config.getlinks(cfg, "dependencies", "object")
				ex = #prjdeps ~= #cfgdeps
			end
			cfg._needsExplicitLink = ex
		end
		return cfg._needsExplicitLink
	end


---
-- Prepare a path value for output in a Visual Studio project or solution.
-- Converts path separators to backslashes, and makes relative to the project.
--
-- @param cfg
--    The project or configuration which contains the path.
-- @param value
--    The path to be prepared.
-- @return
--    The prepared path.
---

	function vstudio.path(cfg, value)
		cfg = cfg.project or cfg
		local dirs = path.translate(project.getrelative(cfg, value))

		if type(dirs) == 'table' then
			dirs = table.filterempty(dirs)
		end

		return dirs
	end


--
-- Returns the Visual Studio project configuration identifier corresponding
-- to the given Premake configuration.
--
-- @param cfg
--    The configuration to query.
-- @param arch
--    An optional architecture identifier, to override the configuration.
-- @return
--    A project configuration identifier of the form
--    <project platform name>|<architecture>.
--

	function vstudio.projectConfig(cfg, arch)
		local platform = vstudio.projectPlatform(cfg)
		local architecture = arch or vstudio.archFromConfig(cfg, true)
		return platform .. "|" .. architecture
	end


---
-- Generates a Visual Studio project element for the current action.
---

	function vstudio.projectElement()
		p.push('<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">')
	end



--
-- Returns the full, absolute path to the Visual Studio project file
-- corresponding to a particular project object.
--
-- @param prj
--    The project object.
-- @return
--    The absolute path to the corresponding Visual Studio project file.
--

	function vstudio.projectfile(prj)
		local extension
		if project.iscsharp(prj) then
			extension = ".csproj"
		elseif project.isfsharp(prj) then
			extension = ".fsproj"
		elseif project.isc(prj) or project.iscpp(prj) then
			if prj.kind == p.SHAREDITEMS then
				extension = ".vcxitems"
			elseif prj.kind == p.PACKAGING then
				extension = ".androidproj"
			else
				extension = iif(_ACTION > "vs2008", ".vcxproj", ".vcproj")
			end
		end

		return p.filename(prj, extension)
	end


--
-- Returns a project configuration name corresponding to the given
-- Premake configuration. This is just the solution build configuration
-- and platform identifiers concatenated.
--

	function vstudio.projectPlatform(cfg)
		local platform = cfg.platform
		if platform then
			local pltarch = vstudio.archFromPlatform(cfg.platform) or platform
			local cfgarch = vstudio.archFromConfig(cfg)
			if pltarch == cfgarch then
				platform = nil
			end
		end

		if platform then
			return cfg.buildcfg .. " " .. platform
		else
			return cfg.buildcfg
		end
	end


--
-- Determine the appropriate Visual Studio platform identifier for a
-- solution-level configuration.
--
-- @param cfg
--    The configuration to be identified.
-- @return
--    A corresponding Visual Studio platform identifier.
--

	function vstudio.solutionPlatform(cfg)
		local platform = cfg.platform

		-- if a platform is specified use it, translating to the corresponding
		-- Visual Studio identifier if appropriate
		local platarch
		if platform then
			platform = vstudio.archFromPlatform(platform) or platform

			-- Value for 32-bit arch is different depending on whether this solution
			-- contains C++ or C# projects or both
			if platform ~= "x86" then
				return platform
			end
		end

		-- scan the contained projects to identify the platform
		local hasnative = false
		local hasnet = false
		local slnarch
		for prj in p.workspace.eachproject(cfg.workspace) do
			hasnative = hasnative or project.isnative(prj)
			hasnet    = hasnet    or project.isdotnet(prj)

			-- get a VS architecture identifier for this project
			local prjcfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
			if prjcfg then
				local prjarch = vstudio.archFromConfig(prjcfg)
				if not slnarch then
					slnarch = prjarch
				elseif slnarch ~= prjarch then
					slnarch = "Mixed Platforms"
				end
			end
		end


		if platform then
			return iif(hasnet, "x86", "Win32")
		elseif slnarch then
			return iif(slnarch == "x86" and not hasnet, "Win32", slnarch)
		elseif hasnet and hasnative then
			return "Mixed Platforms"
		elseif hasnet then
			return "Any CPU"
		else
			return "Win32"
		end
	end


--
-- Attempt to determine an appropriate Visual Studio architecture identifier
-- for a solution configuration.
--
-- @param cfg
--    The configuration to query.
-- @return
--    A best guess at the corresponding Visual Studio architecture identifier.
--

	function vstudio.solutionarch(cfg)
		local hasnative = false
		local hasdotnet = false

		-- if the configuration has a platform identifier, use that as default
		local arch = cfg.platform

		-- if the platform identifier matches a known system or architecture,
		--

		for prj in p.workspace.eachproject(cfg.workspace) do
			hasnative = hasnative or project.isnative(prj)
			hasnet    = hasnet    or project.isdotnet(prj)

			if hasnative and hasdotnet then
				return "Mixed Platforms"
			end

			if not arch then
				local prjcfg = project.getconfig(prj, cfg.buildcfg, cfg.platform)
				if prjcfg then
					if prjcfg.architecture then
						arch = vstudio.archFromConfig(prjcfg)
					end
				end
			end
		end

		-- use a default if no other architecture was specified
		arch = arch or iif(hasnative, "Win32", "Any CPU")
		return arch
	end


--
-- Returns the Visual Studio solution configuration identifier corresponding
-- to the given Premake configuration.
--
-- @param cfg
--    The configuration to query.
-- @return
--    A solution configuration identifier of the format BuildCfg|Platform,
--    corresponding to the Premake values of the same names. If no platform
--    was specified by the script, the architecture is used instead.
--

	function vstudio.solutionconfig(cfg)
		local platform = cfg.platform

		-- if no platform name was specified, use the architecture instead;
		-- since architectures are defined in the projects and not at the
		-- solution level, need to poke around to figure this out
		if not platform then
			platform = vstudio.solutionarch(cfg)
		end

		return string.format("%s|%s", cfg.buildcfg, platform)
	end


--
-- Returns the Visual Studio tool ID for a given project type.
--

	function vstudio.tool(prj)
		if project.iscsharp(prj) then
			return "FAE04EC0-301F-11D3-BF4B-00C04F79EFBC"
		elseif project.isfsharp(prj) then
			return "F2A71F9B-5D33-465A-A702-920D77279786"
		elseif project.isc(prj) or project.iscpp(prj) then
			if prj.kind == p.PACKAGING then
				return "39E2626F-3545-4960-A6E8-258AD8476CE5"
			else
				return "8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942"
			end
		end
	end



--
-- Load all required code, and return the module.
--

	include("vs200x_vcproj.lua")
	include("vs200x_vcproj_user.lua")
	include("vs2005_solution.lua")
	include("vs2005_dotnetbase.lua")
	include("vs2005_csproj.lua")
	include("vs2005_csproj_user.lua")
	include("vs2005_fsproj.lua")
	include("vs2005_fsproj_user.lua")
	include("vs2010_nuget.lua")
	include("vs2010_vcxproj.lua")
	include("vs2010_vcxproj_user.lua")
	include("vs2010_vcxproj_filters.lua")
	include("vs2010_rules_props.lua")
	include("vs2010_rules_targets.lua")
	include("vs2010_rules_xml.lua")
	include("vs2013_vcxitems.lua")
	include("vs2015_androidproj.lua")

	return p.modules.vstudio
