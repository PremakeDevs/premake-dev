/**
 * \file   premake.h
 * \brief  Program-wide constants and definitions.
 * \author Copyright (c) 2002-2024 Jess Perkins and the Premake project
 */

#define lua_c
#ifdef LUA_STATICLIB
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#else
#include <lua5.3/lua.h>
#include <lua5.3/lauxlib.h>
#include <lua5.3/lualib.h>
#endif

#include <stdint.h>
#include <stdlib.h>

#ifndef PREMAKE_VERSION
# define PREMAKE_VERSION "5.0.0-dev"
#endif

#define PREMAKE_COPYRIGHT      "Copyright (C) 2002-2024 Jess Perkins and the Premake Project"
#define PREMAKE_PROJECT_URL    "https://github.com/premake/premake-core/wiki"

#if defined(__linux__)
#define PLATFORM_LINUX    (1)
#define PLATFORM_OS   "linux"
#elif defined(__FreeBSD__) || defined(__FreeBSD_kernel__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__DragonFly__)
#define PLATFORM_BSD      (1)
#define PLATFORM_OS   "bsd"
#elif defined(__APPLE__) && defined(__MACH__)
#define PLATFORM_MACOSX   (1)
#define PLATFORM_OS   "macosx"
#elif defined(__sun__) && defined(__svr4__)
#define PLATFORM_SOLARIS  (1)
#define PLATFORM_OS   "solaris"
#elif defined(__HAIKU__)
#define PLATFORM_HAIKU    (1)
#define PLATFORM_OS   "haiku"
#elif defined (_AIX)
#define PLATFORM_AIX  (1)
#define PLATFORM_OS  "aix"
#elif defined (__GNU__)
#define PLATFORM_HURD  (1)
#define PLATFORM_OS  "hurd"
#elif defined (__COSMOPOLITAN__)
#define PLATFORM_COSMO  (1)
#define PLATFORM_OS  "cosmopolitan"
#elif defined(_WIN32) || defined(_WIN64)
#define PLATFORM_WINDOWS  (1)
#define PLATFORM_OS   "windows"
#else
#error Unknown platform detected
#endif

#define PLATFORM_POSIX  (PLATFORM_LINUX || PLATFORM_BSD || PLATFORM_MACOSX || PLATFORM_SOLARIS || PLATFORM_HAIKU || PLATFORM_COSMO)

#if defined(__x86_64__) || defined(__x86_64) || defined(__amd64__) || defined(__amd64) || \
    defined(_M_X64) || defined(_M_AMD64)
#define PLATFORM_ARCHITECTURE "x86_64"
#elif defined(i386) || defined(__i386) || defined(__i386__) || defined(__i486__) || defined(__i586__) || \
    defined(__i686__) || defined(_M_IX86)|| defined(__X86__) || defined(_X86_)
#define PLATFORM_ARCHITECTURE "x86"
#elif defined(__aarch64__) || defined(_M_ARM64) || defined(__AARCH64EL__) || defined(__arm64)
#define PLATFORM_ARCHITECTURE "ARM64"
#elif defined(__arm__) || defined(__thumb__) || defined(__TARGET_ARCH_ARM) || defined(__TARGET_ARCH_THUMB) || \
    defined(__ARM) || defined(_M_ARM) || defined(_M_ARM_T) || defined(__ARM_ARCH)
#define PLATFORM_ARCHITECTURE "ARM"
#elif defined(_M_RISCV64) || (defined(__riscv) && __riscv_xlen == 64)
#define PLATFORM_ARCHITECTURE "RISCV64"
#elif (defined(__loongarch__) && __loongarch_grlen == 64) || defined(__loongarch64)
#define PLATFORM_ARCHITECTURE "loongarch64"
#elif defined(__e2k__)
#define PLATFORM_ARCHITECTURE "e2k"
#elif !defined(RC_INVOKED)
#error Unknown architecture detected
#endif

/* Pull in platform-specific headers required by built-in functions */
#if PLATFORM_WINDOWS
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#else
#include <unistd.h>
#endif

/* not all platforms define this */
#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

/* Fill in any missing bits */
#ifndef PATH_MAX
#define PATH_MAX   (4096)
#endif

/* A success return code */
#define OKAY   (0)

/* Bitmasks for the different script file search locations */
enum FileSearchMask
{
    SEARCH_LOCAL    =  0x01,
    SEARCH_SCRIPTS  =  0x02,
    SEARCH_PATH     =  0x04,
    SEARCH_EMBEDDED =  0x08
};

/* If a /scripts argument is present, its value */
extern const char* scripts_path;

/* Bootstrapping helper functions */
int do_chdir(lua_State* L, const char* path);
uint32_t do_hash(const char* str, int seed);
void do_getabsolute(char* result, const char* value, const char* relative_to);
int do_getcwd(char* buffer, size_t size);
int do_isabsolute(const char* path);
int do_absolutetype(const char* path);
int do_isfile(lua_State* L, const char* filename);
int do_locate(lua_State* L, const char* filename, const char* path);
void do_normalize(lua_State* L, char* buffer, const char* path);
int do_pathsearch(lua_State* L, const char* filename, const char* path);
void do_translate(char* value, const char sep);

int term_doGetTextColor();
void term_doSetTextColor(int color);

/* Built-in functions */
int criteria_compile(lua_State* L);
int criteria_delete(lua_State* L);
int criteria_matches(lua_State* L);
int debug_prompt(lua_State* L);
int path_getabsolute(lua_State* L);
int path_getrelative(lua_State* L);
int path_isabsolute(lua_State* L);
int path_join(lua_State* L);
int path_deferred_join(lua_State* L);
int path_has_deferred_join(lua_State* L);
int path_resolve_deferred_join(lua_State* L);
int path_normalize(lua_State* L);
int path_translate(lua_State* L);
int path_wildcards(lua_State* L);
int os_chdir(lua_State* L);
int os_chmod(lua_State* L);
int os_comparefiles(lua_State* L);
int os_copyfile(lua_State* L);
int os_getcwd(lua_State* L);
int os_getnumcpus(lua_State* L);
int os_getpass(lua_State* L);
int os_getWindowsRegistry(lua_State* L);
int os_listWindowsRegistry(lua_State* L);
int os_getversion(lua_State* L);
int os_host(lua_State* L);
int os_hostarch(lua_State* L);
int os_is64bit(lua_State* L);
int os_isdir(lua_State* L);
int os_isfile(lua_State* L);
int os_islink(lua_State* L);
int os_linkdir(lua_State* L);
int os_linkfile(lua_State* L);
int os_locate(lua_State* L);
int os_matchdone(lua_State* L);
int os_matchisfile(lua_State* L);
int os_matchname(lua_State* L);
int os_matchnext(lua_State* L);
int os_matchstart(lua_State* L);
int os_mkdir(lua_State* L);
int os_pathsearch(lua_State* L);
int os_realpath(lua_State* L);
#if PLATFORM_WINDOWS
// utf8 versions
int os_remove(lua_State* L);
int os_rename(lua_State* L);
#endif
int os_rmdir(lua_State* L);
int os_stat(lua_State* L);
int os_uuid(lua_State* L);
int os_writefile_ifnotequal(lua_State* L);
int os_touchfile(lua_State* L);
int os_compile(lua_State* L);
int premake_getEmbeddedResource(lua_State* L);
int string_endswith(lua_State* L);
int string_hash(lua_State* L);
int string_sha1(lua_State* L);
int string_startswith(lua_State* L);
int buffered_new(lua_State* L);
int buffered_write(lua_State* L);
int buffered_writeln(lua_State* L);
int buffered_close(lua_State* L);
int buffered_tostring(lua_State* L);
int term_getTextColor(lua_State* L);
int term_setTextColor(lua_State* L);

#ifdef PREMAKE_CURL
int http_get(lua_State* L);
int http_post(lua_State* L);
int http_download(lua_State* L);
#endif

#ifdef PREMAKE_COMPRESSION
int zip_extract(lua_State* L);
#endif

/* Engine interface */

typedef struct
{
	const char*          name;
	const unsigned char* bytecode;
	size_t               length;
} buildin_mapping;

extern const buildin_mapping builtin_scripts[];
extern void  registerModules(lua_State* L);

int premake_init(lua_State* L);
int premake_pcall(lua_State* L, int nargs, int nresults);
int premake_execute(lua_State* L, int argc, const char** argv, const char* script);

int premake_load_embedded_script(lua_State* L, const char* filename);
const buildin_mapping* premake_find_embedded_script(const char* filename);

int premake_locate_executable(lua_State* L, const char* argv0);
int premake_locate_file(lua_State* L, const char* filename, int searchMask);
void premake_handle_lua_error(lua_State* L);

// Overridden Lua functions
int premake_luaL_loadfilex(lua_State *L, const char *filename, const char *mode);
int premake_luaB_loadfile(lua_State* L);
int premake_luaB_dofile(lua_State* L);
int premake_searcher_Lua(lua_State *L);

#define premake_luaL_loadfile(L,f)	premake_luaL_loadfilex(L,f,NULL)
#define premake_luaL_dofile(L, fn) \
	(premake_luaL_loadfile(L, fn) || lua_pcall(L, 0, LUA_MULTRET, 0))
