  # Oh My Bash Plugin for GitHub CLI (`gh`)

This plugin provides convenient aliases and functions for [GitHub CLI](https://cli.github.com/) (`gh`) when using **Oh My Bash**.

## Prerequisites

You must have GitHub CLI installed. Download it from the official site:
➡️ **[https://cli.github.com/](https://cli.github.com/)** ⬅️

After installation, authenticate with `gh auth login`.

## Aliases

| Alias    | Command                         | Description                         |
|----------|---------------------------------|-------------------------------------|
| `gh`     | `gh`                            | Base command                        |
| `ghrv`   | `gh repo view`                  | View repository                     |
| `ghrvw`  | `gh repo view --web`            | View repository in browser          |
| `ghrc`   | `gh-repo-clone` (function)      | Clone a repository                  |
| `ghrl`   | `gh repo list`                  | List repositories                   |
| `ghrel`  | `gh release`                    | Releases base command               |
| `ghrell` | `gh release list`               | List releases                       |
| `ghrelc` | `gh release create`             | Create release                      |
| `ghrelv` | `gh release view`               | View release                        |
| `ghpr`   | `gh-pr-list` (function)         | List PRs (open by default)          |
| `ghpro`  | `gh pr list --state open`       | List open PRs                       |
| `ghprc`  | `gh-pr-create` (function)       | Create a PR                         |
| `ghprco` | `gh pr checkout`                | Checkout a PR                       |
| `ghprs`  | `gh pr status`                  | PR status                           |
| `ghprch` | `gh pr checks`                  | View PR checks                      |
| `ghprv`  | `gh pr view`                    | View PR                             |
| `ghprvw` | `gh pr view --web`              | View PR in browser                  |
| `ghis`   | `gh-issue-list` (function)      | List issues (open by default)       |
| `ghio`   | `gh issue list --state open`    | List open issues                    |
| `ghic`   | `gh issue list --state closed`  | List closed issues                  |
| `ghisc`  | `gh issue create`               | Create issue                        |
| `ghisv`  | `gh issue view`                 | View issue                          |
| `ghisvw` | `gh issue view --web`           | View issue in browser               |
| `ghg`    | `gh gist`                       | Gists base command                  |
| `ghgl`   | `gh gist list`                  | List gists                          |
| `ghgc`   | `gh gist create`                | Create gist                         |
| `ghw`    | `gh workflow`                   | Workflows base command              |
| `ghwl`   | `gh workflow list`              | List workflows                      |
| `ghwr`   | `gh workflow run`               | Run workflow                        |
| `ghwv`   | `gh workflow view`              | View workflow                       |
| `gha`    | `gh api`                        | Call GitHub API                     |
| `ghal`   | `gh alias list`                 | List aliases                        |
| `ghst`   | `gh status`                     | Repository status                   |
| `ghauth` | `gh auth status`                | Authentication status               |
| `ghver`  | `gh-info` (function)            | Show version and auth info           |

## Functions

| Function          | Description                                      | Usage Example                                 |
|-------------------|--------------------------------------------------|-----------------------------------------------|
| `gh-info`         | Displays `gh` version and authentication status | `gh-info`                                     |
| `gh-pr-create`    | Creates a pull request with title and optional body, then opens in browser | `gh-pr-create "Title" "Description"` |
| `gh-issue-list`   | Lsts issues; optional state filter (open/closed) | `gh-issue-list closed`                       |
| `gh-repo-clone`   | Clones a repository in `owner/repo` format      | `gh-repo-clone octocat/Hello-World`           |
| `gh-pr-list`      | Lists pull requests; optional state filter      | `gh-pr-list closed`                           |
