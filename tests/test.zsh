#!/usr/bin/env zsh

if [[ -z "$TERM" ]]; then
  export TERM=xterm-256color
fi

### Setup
echo "$(tput setaf 4)Setting up...$(tput sgr0)"

snapshot="${0:A:h}/snapshot.txt"
current_branch=$(git branch --show-current)
current_ref=$(git rev-parse HEAD)
remote_url=$(git remote -v | grep "(push)" | awk '{print $2}')

__UTILS_PATH="${0:A:h}/utils.mock.zsh" \
__UNLOAD_PATH="/dev/null" \
. "${0:A:h}/../git-open.zsh" > /dev/null

assert_value() {
  local expected="$1"
  local actual="$2"

  if [[ "$expected" != "$actual" ]]; then
    echo "$(tput setaf 1)❌"
    echo "Expected: $expected"
    echo "Actual: $actual$(tput sgr0)"
    echo "Debug Info:"
    git_open _debug
    exit 1
  fi

  printf "✅"
}

describe() {
  echo -n "\n$1: "
}

### Tests

echo "$(tput setaf 4)Running tests...$(tput sgr0)"

describe "git_open_project"
assert_value "https://github.com/chenasraf/git-open" $(git_open_project)

describe "git_get_remote"
assert_value $remote_url $(git_get_remote)

describe "git_get_repo_path"
assert_value "chenasraf/git-open" $(git_get_repo_path $(git_get_remote))
assert_value "chenasraf/git-open" $(git_get_repo_path "https://gitlab.com/chenasraf/git-open")
assert_value "chenasraf/git-open" $(git_get_repo_path "https://gitlab.com/chenasraf/git-open.git")
assert_value "chenasraf/git-open" $(git_get_repo_path "https://bitbucket.org/chenasraf/git-open")
assert_value "chenasraf/git-open" $(git_get_repo_path "https://bitbucket.org/chenasraf/git-open.git")
assert_value "chenasraf/git-open" $(git_get_repo_path "git@gitlab.com:chenasraf/git-open")
assert_value "chenasraf/git-open" $(git_get_repo_path "git@gitlab.com:chenasraf/git-open.git")
assert_value "chenasraf/git-open" $(git_get_repo_path "git@bitbucket.org:chenasraf/git-open.git")

describe "git_get_remote_type"
assert_value "github" $(git_get_remote_type $(git_get_remote))

describe "git_open_branch"
assert_value "https://github.com/chenasraf/git-open/tree/$current_branch" $(git_open_branch)
assert_value "https://github.com/chenasraf/git-open/tree/develop" $(git_open_branch "" develop)
assert_value "https://github.com/chenasraf/git-open/tree/feature/test" $(git_open_branch "" feature/test)

describe "git_open_file"
assert_value "https://github.com/chenasraf/git-open/blob/$current_branch/test.zsh" $(git_open_file "" test.zsh)
assert_value "https://github.com/chenasraf/git-open/blob/develop/test.zsh" $(git_open_file "" test.zsh develop)

describe "git_open_commit"
assert_value "https://github.com/chenasraf/git-open/commit/1a4c2b6" $(git_open_commit "" 1a4c2b6)
assert_value "https://github.com/chenasraf/git-open/commit/$current_ref" $(git_open_commit)

describe "git_open_pr_list"
assert_value "https://github.com/chenasraf/git-open/pulls?q=is%3Apr+is%3Aopen" $(git_open_pr_list)

describe "git_open_new_pr"
assert_value "https://github.com/chenasraf/git-open/compare/develop...master" $(git_open_new_pr -f master develop)
assert_value "https://github.com/chenasraf/git-open/compare/master...develop" $(git_open_new_pr -f develop)
assert_value "https://github.com/chenasraf/git-open/compare/master...$current_branch" $(git_open_new_pr -f)

describe "git_open_pipelines"
assert_value "https://github.com/chenasraf/git-open/actions" $(git_open_pipelines)

describe "without args"
assert_value "$(cat $snapshot)" "$(git_open)"

### Teardown
echo ''
echo "$(tput setaf 2)All tests passed!$(tput sgr0)"
unset -f assert_value describe

source "${0:A:h}/../unload.zsh"

