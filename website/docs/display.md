Text to display for rule or property definition

```lua
display "value"
```

### Parameters ###

`value` - Text shown for the rule or property definition.

### Applies To ###

The `rule` scope.

### Availability ###

Premake 5.0.0 alpha 12 or later.

### Examples ###

```lua
rule "myrule"
  display "My custom rule"
  fileextension ".in"

  propertydefinition {
    name = "myoption",
    display = "My option",
    description = "Select the option to use",
    values = { [0] = "option1", [1] = "option2"},
    value = 1
  }

  buildmessage 'custom rule: {copy} %{file.relpath} %{file.basename}'
  buildoutputs { "%{sln.location}/%{file.basename}" }
  buildcommands { "MyScript {myoption} %[%{!file.abspath}] %[%{!sln.location}/%{file.basename}]" }
```

## See Also ##

* [Custom Rules](Custom-Rules.md)
