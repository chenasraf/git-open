#!/usr/bin/env zsh

if [[ -z "$TERM" ]]; then
  export TERM=xterm-256color
fi

### Setup
echo "$(tput setaf 4)Setting up...$(tput sgr0)"

snapshot="${0:A:h}/snapshot.txt"
current_branch=$(git branch --show-current)
current_ref=$(git rev-parse HEAD)
remote_url=$(git remote -v | grep "(push)" | grep "^origin " | head -1 | awk '{print $2}')
if [[ -z "$remote_url" ]]; then
  remote_url=$(git remote -v | grep "(push)" | head -1 | awk '{print $2}')
fi

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

describe "git_open_file from subdirectory"
assert_value "https://github.com/chenasraf/git-open/blob/$current_branch/tests/test.zsh" $(cd "${0:A:h}" && git_open_file "" test.zsh)

describe "git_open_file from subdirectory (via git alias)"
assert_value "https://github.com/chenasraf/git-open/blob/$current_branch/tests/test.zsh" $(GIT_PREFIX=tests/ git_open_file "" test.zsh)

describe "git_open_commit"
assert_value "https://github.com/chenasraf/git-open/commit/1a4c2b6" $(git_open_commit "" 1a4c2b6)
assert_value "https://github.com/chenasraf/git-open/commit/$current_ref" $(git_open_commit)

describe "git_open_pr_list"
assert_value "https://github.com/chenasraf/git-open/pulls?q=is%3Apr+is%3Aopen" $(git_open_pr_list)

describe "git_open_new_pr"
assert_value "https://github.com/chenasraf/git-open/compare/develop...master" $(git_open_new_pr -f master develop)
assert_value "https://github.com/chenasraf/git-open/compare/master...develop" $(git_open_new_pr -f develop)
assert_value "https://github.com/chenasraf/git-open/compare/master...$current_branch" $(git_open_new_pr -f)
assert_value "https://github.com/chenasraf/git-open/compare/develop...master" $(git_open_new_pr -f "master " " develop ")
assert_value "https://github.com/chenasraf/git-open/compare/master...feature%2Flong-branch-name" $(git_open_new_pr -f "feature/long-branch-name" "master")

describe "git_open_pipelines"
assert_value "https://github.com/chenasraf/git-open/actions" $(git_open_pipelines)

describe "without args"
assert_value "$(cat $snapshot)" "$(git_open)"

### Multi-remote tests
echo ""
echo "$(tput setaf 4)Setting up multi-remote tests...$(tput sgr0)"
git remote add fake-upstream "https://github.com/fakeorg/git-open.git" 2>/dev/null

describe "git_get_remote prefers origin with multiple remotes"
git_remote_name=""
assert_value "$remote_url" $(git_get_remote)

describe "git_get_remote with --remote flag"
git_remote_name="fake-upstream"
assert_value "https://github.com/fakeorg/git-open.git" $(git_get_remote)

describe "git_open_project with --remote flag"
git_remote_name="fake-upstream"
assert_value "https://github.com/fakeorg/git-open" $(git_open_project)

describe "git_open_branch with --remote flag"
git_remote_name="fake-upstream"
assert_value "https://github.com/fakeorg/git-open/tree/$current_branch" $(git_open_branch)

describe "git_get_remote falls back to first when name not found"
git_remote_name="nonexistent"
result=$(git_get_remote)
assert_value 0 $([[ -n "$result" ]] && echo 0 || echo 1)

# Reset remote name
git_remote_name=""

echo ""
echo "$(tput setaf 4)Cleaning up multi-remote tests...$(tput sgr0)"
git remote remove fake-upstream 2>/dev/null

### Teardown
echo ''
echo "$(tput setaf 2)All tests passed!$(tput sgr0)"
unset -f assert_value describe

source "${0:A:h}/../unload.zsh"

