# Powerline Icon Theme

A theme derived from Powerline with emoji icons.

This is based on the Powerline theme. Please see also [the documentation of the
powerline theme](../powerline/README.md).

![Screenshot](./powerline-icon-dark.png?raw=true)

## Segments

The `powerline-icon` theme modifies the segments `user_info` and `cwd` of the
original Powerline theme so that they include icons.  This theme also inserts a
date string in `user_info`.

## Configuration

Icons can be configured by setting values to the following shell variables.

```
OMB_THEME_POWERLINE_ICON_USER
OMB_THEME_POWERLINE_ICON_HOME
OMB_THEME_POWERLINE_ICON_EXIT_FAILURE
OMB_THEME_POWERLINE_ICON_EXIT_SUCCESS
```

The time format shown in the `user_info` segment can be configured by the
following shell variable:

```
OMB_THEME_POWERLINE_ICON_CLOCK
```

The default value is `%X %D`.
