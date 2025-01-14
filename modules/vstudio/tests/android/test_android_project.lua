	local p = premake
	local suite = test.declare("test_android_project")
	local vc2010 = p.vstudio.vc2010
	local android = p.modules.android


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2015")
		system "android"
		wks, prj = test.createWorkspace()
	end

	local function prepare()
		local cfg = test.getconfig(prj, "Debug")
		vc2010.clCompile(cfg)
	end

	local function prepareGlobals()
		prj = test.getproject(wks, 1)
		vc2010.globals(prj)
	end

	local function prepareOutputProperties()
		local cfg = test.getconfig(prj, "Debug")
		vc2010.outputProperties(cfg)
	end

	function suite.minVisualStudioVersion_14()
		prepareGlobals()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Android</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<MinimumVisualStudioVersion>14.0</MinimumVisualStudioVersion>
	<ApplicationType>Android</ApplicationType>
	<ApplicationTypeRevision>2.0</ApplicationTypeRevision>]]
	end

	function suite.minVisualStudioVersion_15()
		p.action.set("vs2017")
		prepareGlobals()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Android</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<MinimumVisualStudioVersion>15.0</MinimumVisualStudioVersion>
	<ApplicationType>Android</ApplicationType>
	<ApplicationTypeRevision>3.0</ApplicationTypeRevision>]]
	end

	function suite.minVisualStudioVersion_16()
		p.action.set("vs2019")
		prepareGlobals()
		test.capture [[
<PropertyGroup Label="Globals">
	<ProjectGuid>{42B5DBC6-AE1F-903D-F75D-41E363076E92}</ProjectGuid>
	<Keyword>Android</Keyword>
	<RootNamespace>MyProject</RootNamespace>
	<MinimumVisualStudioVersion>16.0</MinimumVisualStudioVersion>
	<ApplicationType>Android</ApplicationType>
	<ApplicationTypeRevision>3.0</ApplicationTypeRevision>]]
	end

	function suite.noOptions()
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
</ClCompile>]]
	end

	function suite.rttiOff()
		rtti "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
</ClCompile>]]
	end

	function suite.rttiOn()
		rtti "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
	<RuntimeTypeInfo>true</RuntimeTypeInfo>
]]
	end

	function suite.exceptionHandlingOff()
		exceptionhandling "Off"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
</ClCompile>]]
	end

	function suite.exceptionHandlingOn()
		exceptionhandling "On"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<Optimization>Disabled</Optimization>
	<ExceptionHandling>Enabled</ExceptionHandling>
]]
	end

	function suite.cppdialect_cpp11()
		cppdialect "C++11"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<CppLanguageStandard>c++11</CppLanguageStandard>
	<Optimization>Disabled</Optimization>
]]
	end

	function suite.cppdialect_cpp14()
		cppdialect "C++14"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<CppLanguageStandard>c++1y</CppLanguageStandard>
	<Optimization>Disabled</Optimization>
]]
	end

	function suite.cppdialect_cpp17()
		cppdialect "C++17"
		prepare()
		test.capture [[
<ClCompile>
	<PrecompiledHeader>NotUsing</PrecompiledHeader>
	<CppLanguageStandard>c++1z</CppLanguageStandard>
	<Optimization>Disabled</Optimization>
]]
	end

	function suite.externalIncludeDirs()
		externalincludedirs { "externalincludedirs" }
		prepareOutputProperties()
		test.capture [[
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|x86'">
	<IntDir>obj\Debug\</IntDir>
	<TargetName>MyProject</TargetName>
	<TargetExt>
	</TargetExt>
	<IncludePath>externalincludedirs;$(IncludePath)</IncludePath>
]]
	end
