# CONTRIBUTING GUIDELINES

Oh-My-Bash is a community-driven project. Contribution is welcome, encouraged and appreciated.
It is also essential for the development of the project.

These guidelines are an attempt at better addressing the huge amount of pending
issues and pull requests. Please read them closely.

Foremost, be so kind as to [search](#use-the-search-luke). This ensures any contribution
you would make is not already covered.

* [Issues](#reporting-issues)
  * [You have a problem](#you-have-a-problem)
  * [You have a suggestion](#you-have-a-suggestion)
* [Pull Requests](#pull-requests)
  * [Getting started](#getting-started)
  * [You have a solution](#you-have-a-solution)
  * [New Theme](#new-theme)
  * [New Plugin](#new-plugin)
  * [Copyright and responsibility](#copyright-and-responsibility)
  * [Improving PR](#improving-pr)
* [Information sources (_aka_ search)](#use-the-search-luke)

**BONUS:** [Volunteering](#you-have-spare-time-to-volunteer)

## Reporting Issues

### You have a problem

Please be so kind as to [search](#use-the-search-luke) for any open issue already covering
your problem.

If you find one, comment on it so we can know there are more people experiencing it.

If not, look at the [Troubleshooting](https://github.com/ohmybash/oh-my-bash/wiki/Troubleshooting)
page for instructions on how to gather data to better debug your problem.

Then, you can go ahead and create an issue with as much detail as you can provide.
It should include the data gathered as indicated above, along with:

1. How to reproduce the problem
2. What the correct behavior should be
3. What the actual behavior is

Please copy to anyone relevant (e.g. plugin maintainers) by mentioning their GitHub handle
(starting with `@`) in your message.

We will do our very best to help you.

### You have a suggestion

Please be so kind as to [search](#use-the-search-luke) for any open issue already covering
your suggestion.

If you find one, comment on it so we can know there are more people supporting it.

If not, you can go ahead and create an issue. Please copy to anyone relevant (_eg_ plugin
maintainers) by mentioning their GitHub handle (starting with `@`) in your message.

## Pull Requests

The code should work with Bash 3.2.  Make all the changes to be
POSIX-compatible for external tools unless it is related to a plugin that
clearly targets specific tools or environment such as "GNU make" or "macOS".

### Getting started

Before starting to work on it, please be so kind as to
[search](#use-the-search-luke) for any open issues, and any
pending/merged/rejected PRs covering or related to what you are going to
change.

- If you try to solve a [problem](#you-have-a-problem) and a solution to the
  problem is already reported, try it out and +1 the pull request if the
  solution works OK. On the other hand, if you think your solution is better,
  post it with a reference to the other one so we can have both solutions to
  compare.
- If you find an existing PR that is related, try it out and work with the
  author on a common solution.
- If not, then go ahead and submit a PR. Please copy to anyone relevant
  (e.g. plugin maintainers) by mentioning their GitHub handle (starting with
  `@`) in your message.

You should be familiar with the basics of
[contributing on GitHub](https://help.github.com/articles/using-pull-requests) and have a fork
[properly set up](https://github.com/ohmybash/oh-my-bash/wiki/Contribution-Technical-Practices).

You MUST always create a PR with _a dedicated branch_ (i.e., a branch that is
NOT `master`) based on the latest upstream tree.

The commit message typically has the following form (with the first word in the
verbal phrase being in the infinitive and capitalized):

```
<section>: <Verb phrase to describe the change>

<detailed description if any>
```

The conventional commits are also accepted:

```
<type>(<section>): <verb phrase to describe the change>

<detailed description if any>
```

When you open a new PR, please make sure you do it right. Also, reference in
the PR description body any issues that would be solved by the PR, [for
instance](https://help.github.com/articles/closing-issues-via-commit-messages/)
_"Fixes #XXXX"_ for issue number XXXX.

### You have a solution

If you try to fix a problem or solve an issue in a specific
plugin/theme/aliases, please also check the other modules if they have a
similar issue or can be improved in a similar way.

### New Theme

A new theme is often created by modifying an existing theme.  In that case,
please clarify from which theme the new theme is derived from.  If possible, it
is recommended to source the original theme file
`"$OSH"/themes/<original>/<original>.base.sh` or
`"$OSH"/themes/<original>/<original>.theme.sh` in the new theme file
`"$OSH"/themes/<new>/<new>.theme.sh` and include only the new parts in the new
theme file.

The theme needs to have exactly one image file.  The image size needs to be
height ~290px and width 600..800px to make the theme gallery aligned and also
to keep the repository size small. The filename should be `<theme
name>-dark.png` or `<theme name>-light.png` depending on the dark or light
background of the terminal used to make the image.  The image should be
unscaled screen shot of a terminal.  If the terminal size is larger than the
expecte image size, the image should be clipped instead of being resized and
downscaled.

When you add a new theme, please also update
[themes/THEMES.md](https://github.com/ohmybash/oh-my-bash/blob/master/themes/THEMES.md).
After your new theme is merged, the list in
[Themes](https://github.com/ohmybash/oh-my-bash/wiki/Themes) in the wiki also
needs to be updated.

### New Plugin

A new plugin is accepted when it is needed to implement features in themes or
when it provides significantly useful tools for interactive uses.  To show that
it is worth including in Oh My Bash, you will have to find testers to +1 your
PR.

When you add a new plugin, please also update
[plugins/README.md](https://github.com/ohmybash/oh-my-bash/blob/master/plugins/README.md)

### Copyright and responsibility

If you submit codes derived from other's work, please confirm that the license
is compatible with the MIT license.  Please clarify which part is your own work
and which is not in the code and include **the copyright notice of the original
authors**.  You may also include your own copyright notice, but we may omit
them because we can track them in the Git history.

You can provide codes under any licenses which are compatible with the MIT
license.  When you submit and update a PR (*NOT when the PR is merged*), unless
otherwise specified, **we assume that you provide the codes/texts under the MIT
license**.  If you would like to provide the codes/texts with another license,
please specify it in the codes/texts.  If you forgot to declare the license
that is not MIT, you can later declare it for the part you contributed.

Do not submit AI-generated codes/documentation unless you understand both the
generated codes/documentation and the related **exiting codebase**.  You are
required to be responsible for requests to the changes and reports of the
issues for the submitted codes/documentation.  Also, please confirm that the
generated codes/texts can be included in Oh My Bash **with your own copyright
under the MIT license**.

### Improving PR

After opening PRs, you will usually receive requests for changes.  It is rare
for a PR to be merged without any modifications.  Please be so kind as to
respond to the requests.  If you have any questions, please feel free to ask
further.  If you become busy, please tell us that instead of ignoring our
messages.  You are expected to notify when you will be available again, hand
over the PR to others, or to notify that you would discard the PR.

After the final version of the PR is settled, the fix-up commits that fix
problems introduced in earlier commits in the same PR will be squashed.  Also,
the commits whose purposes heavily overlap will be squashed.

For this reason, a weight of one commit is not equal for different types of
contributions.  For the new theme/plugin/aliases, the PR is likely to be
squashed into a single commit unless the changes are properly separated into
commits for respective purposes.  On the other hand, PRs including several
minor fixes to the exiting codebase will not be squashed because each commit
gives a separate fix to the exiting code.

### Naming convention of functions and global variables

Initially, we haven't cared about the naming convention very much, but we now
try to improve it.  In particular, the new codes should follow this naming
convention.  The contributions to improve old codes are also welcome, but we
also need to keep the backward compatibility.  See [Discussion
#280](https://github.com/ohmybash/oh-my-bash/discussions/280) for background.

The functions/aliases that are supposed to be used as interactive commands can
have arbitrary names including short ones.

The functions that are used from the other functions have the names of the form
`_omb_*`.

* The functions defined by libraries has the form `_omb_${namespace}_${funcname}`
* The functions defined by a specific plugin has the form `_omb_plugin_${plugin_name}_${funcname}`
* The functions defined by a specific theme has the form `_omb_theme_${theme_name}_${funcname}`
* Some important functions might have the name `_omb_${funcname}` directly put under `_omb` namespace.

Public global variables that can be used to configure the behavior of
oh-my-bash have the form `OMB_*`.

* The settings for the main oh-my-bash behavior have the names of the form `OMB_${config^^}`
* The settings for the detailed behavior have the names of the form `OMB_${namespace^^}_${config^^}`
* The settings for a specific plugin has the form `OMB_PLUGIN_${plugin_name^^}_${config^^}`
* The settings for a specific theme has the form `OMB_THEME_${theme_name^^}_${config^^}`

Internal global variables put into global variables used by oh-my-bash has the form `_omb_*`

* The internal variables defined by libraries has the form `_omb_${namespace}_${varname}`
* The internal variables used by a specific plugin has the form `_omb_plugin_${plugin_name}_${varname}`
* The internal variables used by a specific theme has the form `_omb_theme_${theme_name}_${varname}`
* Some important variables might have the name `_omb_${varname}` directly put under `_omb` namespace.

There are no restrictions on the local variable names.  A prefix like
`_omb_${namespace}_` is unnecessary because the namespace of the local
variables is separated for each function call.

----

## Use the Search, Luke

_May the Force (of past experiences) be with you_

GitHub offers [many search features](https://help.github.com/articles/searching-github/)
to help you check whether a similar contribution to yours already exists. Please search
before making any contribution, it avoids duplicates and eases maintenance. Trust me,
that works 90% of the time.

You can also take a look at the [FAQ](https://github.com/ohmybash/oh-my-bash/wiki/FAQ)
to be sure your contribution has not already come up.

If all fails, your thing has probably not been reported yet, so you can go ahead
and [create an issue](#reporting-issues) or [submit a PR](#submitting-pull-requests).

----

### You have spare time to volunteer

Very nice!! :)

Please have a look at the [Volunteer](https://github.com/ohmybash/oh-my-bash/wiki/Volunteers)
page for instructions on where to start and more.
