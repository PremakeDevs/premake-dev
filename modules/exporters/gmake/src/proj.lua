---
-- GNU Makefile project exporter.
---

local array = require('array')
local export = require('export')
local path = require('path')
local premake = require('premake')
local set = require('set')

local gmake = select(1, ...)

local wl = export.writeLine

local proj = {}
proj.impl = {}

proj.elements = {
	project = function (prj)
		return {
			proj.header,
			proj.defaultConfigurations,
			proj.verbosity,
			proj.phonies,
			proj.shellType,
			proj.defines,
			proj.includeDirs,
			proj.targetDir,
			proj.intermediateDir,
			proj.targetName,
			proj.cppFlags,
			proj.cFlags,
			proj.cxxFlags,
			proj.linkFlags,
			proj.configurations,
			proj.linkCmd,
			proj.objects,
			proj.allRule,
			proj.targetRule,
			proj.targetDirRule,
			proj.objDirRule,
			proj.cleanRule,
			proj.prebuildRule,
			proj.fileRules
		}
	end,
	configurations = function (cfg)
		return {
			proj.targetDir,
			proj.intermediateDir,
			proj.targetName,
			proj.defines,
			proj.cppFlags,
			proj.cFlags,
			proj.cxxFlags,
			proj.includeDirs,
			proj.linkFlags,
			proj.configBuildCommands
		}
	end
}


proj.HEADER_FILES = array.join(premake.C_HEADER_EXTENSIONS, premake.CXX_HEADER_EXTENSIONS, premake.OBJC_HEADER_EXTENSIONS)
proj.SOURCE_FILES = array.join(premake.C_SOURCE_EXTENSIONS, premake.CXX_SOURCE_EXTENSIONS, premake.OBJC_SOURCE_EXTENSIONS)


---
-- Local helper function for determining if an object is a project.
--
-- @param obj
--  object to determine if is a project
-- @returns if the object is a project.  False can typically be interpretted that the object is a configuration.
---
local function isProject(obj)
	return obj.project == nil
end


---
-- Export the project's `.makefile` file.
--
-- @return
--	True if the target `.makefile` file was updated; false otherwise.
---
function proj.export(prj)
	export.eol('\r\n')
	export.indentString('\t')
	premake.export(prj, prj.exportPath, function()
		premake.callArray(proj.elements.project, prj)
	end)
end


---
-- Prints the header at the top of the project file.
--
-- @param prj
--  project to print header for
---
function proj.header(prj)
	wl('# GNU Makefile project file autogenerated by Premake')
	wl()
end


---
-- Prints the default configuration information for the project.
--
-- @param prj
--  project to print defaults for
---
function proj.defaultConfigurations(prj)
	wl('ifndef config')
	export.indent()
	wl('config=' .. prj.configs[1].name:lower())
	export.outdent()
	wl('endif')
	wl()
end


---
-- Prints verbosity flags to the makefile.
--
-- @param prj
--  project to print verbosity flags for
---
function proj.verbosity(prj)
	wl('ifndef verbose')
	export.indent()
	wl('SILENT = @')
	export.outdent()
	wl('endif')
	wl()
end


---
-- Prints the shell type to the makefile
--
-- @param prj
--  project to print shell type for
---
function proj.shellType(prj)
	wl('SHELLTYPE := posix')
	wl('ifeq (.exe,$(findstring .exe,$(ComSpec)))')
	export.indent()
	wl('SHELLTYPE := msdos')
	export.outdent()
	wl('endif')
	wl()
end


---
-- Prints the include directories for a project to the makefile.
--
-- @param prj
--  project to print include directories for
---
function proj.includeDirs(prj)
	if isProject(prj) then
		local includeDirs = prj:fetchAllIncludeDirs()
		if includeDirs ~= nil and #includeDirs > 0 then
			local includes = table.map(includeDirs, function(key, value)
				return '-I' .. path.getRelative(prj.location, value)
			end)

			wl('INCLUDES = %s', table.concat(includes, ' '))
		else
			wl('INCLUDES =')
		end
	else
		local cfg = prj
		local configIncludeDirs = cfg:fetchAllIncludeDirs()
		if configIncludeDirs ~= nil and #configIncludeDirs > 0 then
			local includeDirString = table.concat(table.map(configIncludeDirs, function(key, value)
				local relative = path.getRelative(cfg.project.location, value)
				return '-I' .. relative
			end), ' ')

			wl('INCLUDES += %s', includeDirString)
		end
	end
end


---
-- Prints the defines for the given project.
--
-- @param prj
--  project to print defines of
---
function proj.defines(prj)
	local defs = proj.impl.definesString(prj)
	if defs ~= nil then
		wl('DEFINES += %s', defs)
	else
		wl('DEFINES +=')
	end
end


---
-- Prints the target directory for the given project.
--
-- @param prj
--  project to print target directory for
---
function proj.targetDir(prj)
	if isProject(prj) then
		-- TODO: Project-level target directory
		wl('TARGETDIR =')
	else
		-- TODO: Check if this there is an override of the default dir before writing the TARGETDIR
		local project = prj.project
		local cfgName = prj.name
		local configTargetDir = path.getRelative(project.location, path.join(project.workspace.location, 'bin', project.name, cfgName))
		wl('TARGETDIR = %s', configTargetDir)
	end
end


---
-- Prints the intermediates directory for the given project.
--
-- @param prj
--  project to print intermediates directory for
---
function proj.intermediateDir(prj)
	if isProject(prj) then
		-- TODO: Project-level intermediate directory
		wl('OBJDIR =')
	else
		-- TODO: Check if this there is an override of the default dir before writing the OBJDIR
		local cfg = prj
		local project = cfg.project
		local cfgName = cfg.name
		local intDir = path.getRelative(project.location, path.join(project.workspace.location, 'obj', project.name, cfgName))
		wl('OBJDIR = %s', intDir)
	end
end


---
-- Prints the target name for the given project.
--
-- @param prj
--  project to print target name for
---
function proj.targetName(prj)
	if isProject(prj) then
		local name = prj.name
		wl('TARGET = $(TARGETDIR)/%s', name)
	else
		--- TODO: Override target name
	end
end


---
-- Prints the CPP flags for the given project.
--
-- @param prj
--  project to print CPP flags for
---
function proj.cppFlags(prj)
	if isProject(prj) then
		local toolset = prj.compiler
		local flags = toolset.getCppFlags(prj)

		if #flags > 0 then
			wl('ALL_CPPFLAGS += $(CPPFLAGS) -MMD -MP %s $(DEFINES) $(INCLUDES)', table.concat(flags, ' '))
		else
			wl('ALL_CPPFLAGS += $(CPPFLAGS) -MMD -MP $(DEFINES) $(INCLUDES)')
		end
	else
		local cfg = prj
		local toolset = cfg.compiler
		local flags = toolset.getCppFlags(cfg)
	
		if #flags > 0 then
			wl('ALL_CPPFLAGS += %s', table.concat(flags, ' '))
		end
	end	
end


---
-- Prints the C flags for the given project.
--
-- @param prj
--  project to print C flags for
---
function proj.cFlags(prj)
	if isProject(prj) then
		local toolset = prj.compiler
		local flags = toolset.getCFlags(prj)

		if #flags > 0 then
			wl('ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS) %s', table.concat(flags, ' '))
		else
			wl('ALL_CFLAGS += $(CFLAGS) $(ALL_CPPFLAGS)')
		end
	else
		local cfg = prj
		local toolset = cfg.compiler
		local flags = toolset.getCFlags(cfg)

		if #flags > 0 then
			wl('ALL_CFLAGS += %s', table.concat(flags, ' '))
		end
	end
end


---
-- Prints the CXX flags for the given project.
--
-- @param prj
--  project to print CXX flags for
---
function proj.cxxFlags(prj)
	if isProject(prj) then
		local toolset = prj.compiler
		local flags = toolset.getCxxFlags(prj)
	
		if #flags > 0 then
			wl('ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS) %s', table.concat(flags, ' '))
		else
			wl('ALL_CXXFLAGS += $(CXXFLAGS) $(ALL_CPPFLAGS)')
		end
	else
		local cfg = prj
		local toolset = cfg.compiler
		local flags = toolset.getCxxFlags(cfg)
	
		if #flags > 0 then
			wl('ALL_CXXFLAGS += %s', table.concat(flags, ' '))
		end
	end
end


---
-- Prints the linker flags for the given project.
--
-- @param prj
--  project to print linker flags for
---
function proj.linkFlags(prj)
	if isProject(prj) then
		local toolset = prj.linker
		local flags = toolset.getLinkerFlags(prj)

		if #flags > 0 then
			wl('ALL_LDFLAGS = $(LDFLAGS) %s', table.concat(flags, ' '))
		else
			wl('ALL_LDFLAGS = $(LDFLAGS)')
		end
	else
		local cfg = prj
		local toolset = cfg.linker
		local flags = toolset.getLinkerFlags(cfg)

		if #flags then
			wl('ALL_LDFLAGS += %s', table.concat(flags, ' '))
		end
	end
end


---
-- Prints all configurations for the project.
--
-- @param prj
--  project to print configurations for
---
function proj.configurations(prj)
	wl('# Configuration-level overrides')
	for _, cfg in ipairs(prj.configs) do
		local name = cfg.name:lower()

		local conditional = nil
		if _ == 1 then
			conditional = 'ifeq ($(config), ' .. name .. ')'
		else
			conditional = 'else ifeq ($(config), ' .. name .. ')'
		end

		wl(conditional)

		export.indent()
		premake.callArray(proj.elements.configurations, cfg)
		export.outdent()
	end

	if #prj.configs > 0 then
		wl('endif')
	end

	wl()
end


---
-- Prints the build commands for the given configuration.
--
-- @param cfg
--  configuration to print build commands of
---
function proj.configBuildCommands(cfg)
	export.outdent()
	wl('define PREBUILDCMDS')
	wl('endef')
	wl('define PRELINKCMDS')
	wl('endef')
	export.indent()
	wl()
end


---
-- Prints the link command for the given configuration.
--
-- @param cfg
--  configuration to print link command of
---
function proj.linkCmd(cfg)
	-- TODO: Switch on project types
	wl('LINKCMD = $(CXX) -o "$@" $(OBJECTS) $(RESOURCES) $(ALL_LDFLAGS) $(LIBS)')
end


---
-- Prints the phonies of the project.
--
-- @param prj
--  project to print phonies of
---
function proj.phonies(prj)
	wl('.PHONY: clean prebuild')
	wl()
end


---
-- Prints the prebuild rules of the project.
--
-- @param prj
--  project to print prebuild rules of
---
function proj.prebuildRule(prj)
	wl('prebuild: | $(OBJDIR)')
	export.indent()
	wl('$(PREBUILDCMDS)')
	export.outdent()
	wl()
	wl('$(OBJECTS): | prebuild')
	wl()
end


---
-- Prints the object directory rule.
--
-- @param prj
--  project to print object directory rule of
---
function proj.objDirRule(prj)
	wl('$(OBJDIR):')
	export.indent()
	wl('@echo "Creating $(OBJDIR)"')
	export.outdent()
	wl('ifeq (posix,$(SHELLTYPE))')
	export.indent()
	wl('$(SILENT) mkdir -p $(OBJDIR)')
	export.outdent()
	wl('else')
	export.indent()
	wl('$(SILENT) mkdir $(subst /,\\\\,$(OBJDIR))')
	export.outdent()
	wl('endif')
	wl()
end


---
-- Prints the target directory rule.
--
-- @param prj
--  project to print target directory rule of
---
function proj.targetDirRule(prj)
	wl('$(TARGETDIR):')
	export.indent()
	wl('@echo "Creating $(TARGETDIR)"')
	export.outdent()
	wl('ifeq (posix,$(SHELLTYPE))')
	export.indent()
	wl('$(SILENT) mkdir -p $(TARGETDIR)')
	export.outdent()
	wl('else')
	export.indent()
	wl('$(SILENT) mkdir $(subst /,\\\\,$(TARGETDIR))')
	export.outdent()
	wl('endif')
	wl()
end


---
-- Prints the target rule.
--
-- @param prj
--  project to print target rule of
---
function proj.targetRule(prj)
	wl('$(TARGET): $(OBJECTS) | $(TARGETDIR)')
	export.indent()
	wl('$(PRELINKCMDS)')
	wl('@echo "Linking %s"', prj.name)
	wl('$(SILENT) $(LINKCMD)')
	wl('$(POSTBUILDCMDS)')
	export.outdent()
	wl()
end


---
-- Prints the clean rule.
--
-- @param prj
--  project to print clean rule of
---
function proj.cleanRule(prj)
	wl('clean:')
	export.indent()
	wl('@echo "Cleaning %s"', prj.name)
	export.outdent()
	wl('ifeq (posix,$(SHELLTYPE))')
	export.indent()
	wl('$(SILENT) rm -f  $(TARGET)')
	wl('$(SILENT) rm -rf $(OBJDIR)')
	export.outdent()
	wl('else')
	export.indent()
	wl('$(SILENT) if exist $(subst /,\\\\,$(TARGET)) del $(subst /,\\\\,$(TARGET))')
	wl('$(SILENT) if exist $(subst /,\\\\,$(OBJDIR)) rmdir /s /q $(subst /,\\\\,$(OBJDIR))')
	export.outdent()
	wl('endif')
	wl()
end


---
-- Prints the all rule of the project.
--
-- @param prj
--  project to print all rule of
---
function proj.allRule(prj)
	wl('all: $(TARGET)')
	export.indent()
	wl('@:')
	export.outdent()
	wl()
end


---
-- Prints the object file definition.
--
-- @param prj
--  Project to print object files of
---
function proj.objects(prj)
	wl('OBJECTS :=')
	wl()

	local files = {}

	for _, file in ipairs(prj.files) do
		if string.endsWith(file, proj.SOURCE_FILES) then
			wl('OBJECTS += $(OBJDIR)/%s.o', path.getBaseName(file))
		end
	end
	wl()
end


---
-- File configuration rules.
--
-- @param prj
--  project to print file rules for
---
function proj.fileRules(prj)
	wl('# File Rules')
	wl()

	for _, file in ipairs(prj.files) do
		if string.endsWith(file, proj.SOURCE_FILES) then
			wl('$(OBJDIR)/%s.o: %s', path.getBaseName(file), path.getRelative(prj.location, file))
			export.indent()
			wl('@echo $(notdir $<)')
			-- TODO: This should be $(CC) for C builds
			wl('$(SILENT) $(CXX) $(ALL_CXXFLAGS) $(FORCE_INCLUDE) -o "$@" -MF "$(@:%%.o=%%.d)" -c "$<"')
			export.outdent()
			wl()
		end
	end

	wl()
end


---
-- Exports defines to a string
--
-- @param this
--  value to export defines of
---
function proj.impl.definesString(this)
	local defs = this.defines
	if defs ~= nil and #defs > 0 then
		local defines = table.map(defs, function(key, value)
			return '-D' .. value
		end)
		return table.concat(defines, ' ')
	else
		return nil
	end
end


return proj
