# Gradle plugin

This plugin adds completions and aliases for [Gradle](https://gradle.org/).

To use it, add `gradle` to the plugins array in your bashrc file:

```bash
plugins=(... gradle)
```

## Usage

This plugin creates a function called `gradle-or-gradlew`, which is aliased
to `gradle`, which is used to determine whether the current project directory
has a gradlew file. If `gradlew` is present it will be used, otherwise `gradle`
is used instead. Gradle tasks can be executed directly without regard for
whether it is `gradle` or `gradlew`. It also supports being called from
any directory inside the root project directory.

Examples:

```bash
gradle test
gradle build
```
