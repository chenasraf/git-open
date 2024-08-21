# git-open

git-open is a git alias which lets you open various repository URLs in a project in your
default browser. It makes it easy to find a project, a specific commit, a branch or PR on GitHub, GitLab and Bitbucket.

For example:

```sh
git open repo # open project main URL
git open prs # open PRs/MRs list
git open branch # open current branch URL
git open branch some/branch # open specific branch
git open commit # open current commit URL
git open commit abc123 # open specific commit URL
git open file .gitignore # open specific file URL
```

You can always use `git open` without arguments to see the list of possible options:

<!--HELP_OUTPUT_START-->
```sh
Usage: git open [-s] <command>

Opens various Git project related URLs in your browser.

Commands:
  project|repo[sitory]|open|.    Open the project
  branch                         Open the project at given (or current) branch
  commit                         Open the project at given (or current) commit
  file                           Open the project at given file
  file <branch|commit|ref>       Open the project at given file for given ref
  prs|mrs                        Open the PR list
  pr|mr                          Create a new PR or open existing one
  pr|mr <source branch>          Create a new PR or open existing one for given branch
  pr|mr <source> <target>        Create a new PR or open existing one for given branch
  actions|pipelines|ci           Open the CI/CD pipelines

Flags:
  -s, --silent                   Silent mode (no output)
```
<!--HELP_OUTPUT_END-->

## Installation

There are several methods to install git-open:

### Manually

1. Clone the git repository:
   ```sh
   cd $installpath
   git clone https://github.com/chenasraf/git-open.git
   ```

2. Load the entry file somewhere in your init (such as `~/.zshrc`):
   ```sh
   source /path/to/git-open/git-open.plugin.zsh
   ```

   Alternatively, you can add the following value to your git config to load manually:
   ```sh
   git config --global alias.open "!/path/to/git-open/git-open.zsh open"
   ```

### Zplug

```sh
zplug "chenasraf/git-open"
```

## Adding to LazyGit

You can add `git-open` to your `lazygit` config file and open selected files/refs with it.
Here is an example `customCommands` entry, but you can of course modify it or create your own:

```yaml
customCommands:
  - key: 'B'
    context: 'global'
    prompts:
      - type: 'menu'
        title: 'Choose an action'
        key: 'action'
        options:
          - name: 'Open Branch'
            value: 'branch'
          - name: 'Open Default Branch'
            value: 'project'
          - name: 'Open Commit'
            value: 'commit'
          - name: 'Open File'
            value: 'file'
          - name: 'Create Pull Request'
            value: 'pr'
          - name: 'Open Pull Requests'
            value: 'prs'
          - name: 'Open CI/Actions'
            value: 'ci'
    # pass selected contexts to `git open`, prefer file, then remote branch, then local branch
    command: 'git open {{.Form.action}} {{if .SelectedFile}}{{.SelectedFile.Name | quote}}{{else if .SelectedRemoteBranch}}{{.SelectedRemoteBranch.Name | quote}}{{else if .SelectedLocalBranch}}{{.SelectedLocalBranch.Name | quote}}{{end}}'
    loadingText: 'Opening...'
```

## Contributing

I am developing this package on my free time, so any support, whether code, issues, or just stars is
very helpful to sustaining its life. If you are feeling incredibly generous and would like to donate
just a small amount to help sustain this project, I would be very very thankful!

<a href='https://ko-fi.com/casraf' target='_blank'>
  <img height='36' style='border:0px;height:36px;'
    src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
    alt='Buy Me a Coffee at ko-fi.com' />
</a>

I welcome any issues or pull requests on GitHub. If you find a bug, or would like a new feature,
don't hesitate to open an appropriate issue and I will do my best to reply promptly.

