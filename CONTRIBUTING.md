# CONTRIBUTING GUIDELINES
Oh-My-Bash is Free and Open Source project under the terms of GNU General Public License v2.0 relying on contributions from third parties.

These guidelines are an attempt at better addressing the huge amount of pending
issues and pull requests. Please read them closely.

## Merge Requests
### Make a fork
You should be familiar with the basics of
[contributing on GitHub](https://help.github.com/articles/using-pull-requests) and have a fork
[properly set up](https://github.com/ohmybash/oh-my-bash/wiki/Contribution-Technical-Practices).

You MUST always create PRs with _a dedicated branch_ based on the latest upstream tree.

### Form of merge requests
All merge requests has to have following naming:
```
<FILE>: <Summary>

<Description>
<Fixes/Bug>: #<BUG_NUMBER>
Signed-off-by: <name> <surname> <e-mail>
```

Example:
```
theme/agnoster: Fixed naming

Agnoster theme is using wrong file naming which is fixed in this commit
Fixes: #70
Fixes: #59
Signed-off-by: Jacob Hrbek <werifgx@gmail.com>
```
Where signature is optional.

### Quality Assurance (QA)
All merge requests have to pass spellcheck (https://www.shellcheck.net/) unless stated otherwise.

If spellcheck fails on issue that can not be resolved then provide `# spellcheck :SC123` under shabang on your code and explain why is said spellcheck-skip used.

### Copyright
If you are using code that has been written by third party then make sure you have a permission to share it.

In terms of GNU General Public License you are required to credit original author in said files depending on licence used.

### Draft issues
If your merge request is not ready to be merged then submit it as draft.

## Issues
Rule of thumb is to do your best for others to help you which applies here as well
- Be professional or your issue will be closed as invalid.
- Provide helpful title and description
- Provide hardware/software info if they are relevant for the issues.
  - `neofetch` is recommended to provide hardware info.
  - Providing list of installed packages is recommended for software info (and configuration of package manager on high-end distros)
