Specifies extra paths to use when executing build commands

```lua
bindirs { "directories" }
```

### Parameters ###

`directories` - paths containing executable to run when building command.

### Applies To ###

The `config` scope.

### Availability ###

Premake 5.0.0 alpha 12 or later.

### Examples ###

```lua
bindirs { "bin/", "scripts/" }
```

