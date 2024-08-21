#!/usr/bin/env zsh

if [[ -z "$__UTILS_PATH" ]]; then
  __UTILS_PATH="${0:A:h}/utils.zsh"
fi
. "$__UTILS_PATH"
silent=""

uriencode() {
  len="${#1}"
  for ((n = 0; n < len; n++)); do
    c="${1:$n:1}"
    case $c in
      [a-zA-Z0-9.~_-]) printf "$c" ;;
                    *) printf '%%%02X' "'$c"
    esac
  done
}

git_get_remote() {
  remote=$(git remote -v | grep "(push)" | awk '{print $2}')
  echo $remote
}

git_get_repo_path() {
  remote=$1
  repo_path=''

  if [[ $remote =~ ^git@ ]]; then
      repo_path=$(echo "$remote" | sed -E 's|^git@[^:]+:([^:]+)\.git$|\1|')
      repo_path=$(echo "$repo_path" | sed -E 's|^git@[^:]+:([^:]+)$|\1|')
  elif [[ $remote =~ ^https?:// ]]; then
      repo_path=$(echo "$remote" | sed -E 's|^https?://[^/]+/([^\.]+)\.git$|\1|')
      repo_path=$(echo "$repo_path" | sed -E 's|^https?://[^/]+/([^\.]+)$|\1|')
  fi
  echo $repo_path
}

git_get_remote_type() {
  remote=$1
  repo_path=$(git_get_repo_path $remote)
  remote_type='github'
  case $remote in
    *github.com*) remote_type='github' ;;
    *gitlab.com*) remote_type='gitlab' ;;
    *bitbucket.org*) remote_type='bitbucket' ;;
    *) return 1 ;;
  esac

  echo $remote_type
  return 0
}

git_open_project() {
  remote=$(git_get_remote)
  if [[ -z $remote ]]; then
    echo "No remote found"
    return 1
  fi

  repo_path=$(git_get_repo_path $remote)
  remote_type=$(git_get_remote_type $remote)
  if [[ -z $remote_type ]]; then
    echo "Unknown remote type for $remote"
    return 1
  fi

  case "$remote_type" in
    github) open_url "$silent" "https://github.com/$repo_path" ;;
    gitlab) open_url "$silent" "https://gitlab.com/$repo_path" ;;
    bitbucket) open_url "$silent" "https://bitbucket.org/$repo_path" ;;
    *)
      echo "Unknown remote type: $remote_type"
      return 2
      ;;
  esac

  return 0
}

git_open_branch() {
  remote=$(git_get_remote)
  if [[ -z $remote ]]; then
    echo "No remote found"
    return 1
  fi

  remote_type=$(git_get_remote_type $remote)
  if [[ -z $remote_type ]]; then
    echo "Unknown remote type for $remote"
    return 1
  fi

  repo_path=$(git_get_repo_path $remote)
  branch=$([[ ! -z $2 ]] && echo "$2" || git branch --show-current)

  case "$remote_type" in
    github) open_url "$silent" "https://github.com/$repo_path/tree/$branch" ;;
    gitlab) open_url "$silent" "https://gitlab.com/$repo_path/-/tree/$branch" ;;
    bitbucket) open_url "$silent" "https://bitbucket.org/$repo_path/branch/$branch" ;;
  esac

  return 0
}

git_open_file() {
  remote=$(git_get_remote)
  if [[ -z $remote ]]; then
    echo "No remote found"
    return 1
  fi

  remote_type=$(git_get_remote_type $remote)
  if [[ -z $remote_type ]]; then
    echo "Unknown remote type for $remote"
    return 1
  fi

  repo_path=$(git_get_repo_path $remote)
  file=$([[ ! -z $2 ]] && echo "$2" || echo "")
  branch=$([[ ! -z $3 ]] && echo "$3" || git branch --show-current)

  case "$remote_type" in
    github) open_url "$silent" "https://github.com/$repo_path/blob/$branch/$file" ;;
    gitlab) open_url "$silent" "https://gitlab.com/$repo_path/-/blob/$branch/$file" ;;
    bitbucket) open_url "$silent" "https://bitbucket.org/$repo_path/src/$file" ;;
  esac

  return 0
}

git_open_commit() {
  remote=$(git_get_remote)
  if [[ -z $remote ]]; then
    echo "No remote found"
    return 1
  fi

  remote_type=$(git_get_remote_type $remote)
  if [[ -z $remote_type ]]; then
    echo "Unknown remote type for $remote"
    return 1
  fi

  repo_path=$(git_get_repo_path $remote)
  commit=$([[ ! -z $2 ]] && echo "$2" || git rev-parse HEAD)

  case "$remote_type" in
    github) open_url "$silent" "https://github.com/$repo_path/commit/$commit" ;;
    gitlab) open_url "$silent" "https://gitlab.com/$repo_path/-/commit/$commit" ;;
    bitbucket) open_url "$silent" "https://bitbucket.org/$repo_path/commit/$commit" ;;
  esac

  return 0
}

git_open_pr_list() {
  remote=$(git_get_remote)
  if [[ -z $remote ]]; then
    echo "No remote found"
    return 1
  fi

  remote_type=$(git_get_remote_type $remote)
  if [[ -z $remote_type ]]; then
    echo "Unknown remote type for $remote"
    return 1
  fi

  repo_path=$(git_get_repo_path $remote)

  case "$remote_type" in
    github) open_url "$silent" "https://github.com/$repo_path/pulls?q=is%3Apr+is%3Aopen" ;;
    gitlab) open_url "$silent" "https://gitlab.com/$repo_path/merge_requests?scope=all&state=opened" ;;
    bitbucket) open_url "$silent" "https://bitbucket.org/$repo_path/pull-requests?state=OPEN" ;;
    *)
      echo "Unknown remote type: $remote_type"
      return 2
      ;;
  esac

  return 0
}

git_open_new_pr() {
  existing="$(git_find_pr)"
  if [[ -n $existing ]]; then
    echo "PR already exists: $existing"
    open_url "$silent" $existing
    return 0
  fi
  remote=$(git_get_remote)
  if [[ -z $remote ]]; then
    echo "No remote found"
    return 1
  fi

  remote_type=$(git_get_remote_type $remote)
  if [[ -z $remote_type ]]; then
    echo "Unknown remote type for $remote"
    return 1
  fi

  repo_path=$(git_get_repo_path $remote)
  branch=$([[ ! -z $1 ]] && echo "$1" || git branch --show-current)
  default_branch=$([[ ! -z $2 ]] && echo "$2" || echo $(git remote show $remote | grep "HEAD branch" | awk '{print $3}'))
  if [[ -z $default_branch ]]; then
    default_branch="master"
  fi

  branch=$(uriencode $branch)
  default_branch=$(uriencode $default_branch)

  case "$remote_type" in
    github) open_url "$silent" "https://github.com/$repo_path/compare/$default_branch...$branch" ;;
    gitlab) open_url "$silent" "https://gitlab.com/$repo_path/-/merge_requests/new?merge_request%5Bsource_branch%5D=$branch&merge_request%5Btarget_branch%5D=$default_branch" ;;
    bitbucket) open_url "$silent" "https://bitbucket.org/$repo_path/pull-requests/new?source=$branch&t=1" ;;
  esac

  return 0
}

git_find_pr() {
  remote=$(git_get_remote)
  if [[ -z "$remote" ]]; then
    echo "No remote found"
    return 1
  fi

  remote_type=$(git_get_remote_type $remote)
  if [[ -z "$remote_type" ]]; then
    echo "Unknown remote type for $remote"
    return 1
  fi

  repo_path=$(git_get_repo_path $remote)
  commit="$(git rev-parse HEAD)"

  case "$remote_type" in
    github) prrefs="pulls/*/head"; prfilt="pulls" ;;
    gitlab) prrefs="merge-requests/*/head"; prfilt="merge-requests" ;;
    bitbucket) prrefs="pull-requests/*/head"; prfilt="pull-requests" ;;
  esac

  prid="$(git ls-remote origin $prrefs | grep "refs/$prfilt" | grep $commit | awk '{print $2}' | cut -d'/' -f3)"

  if [[ -z $prid ]]; then
    return 1
  fi

  case "$remote_type" in
    github) echo "https://github.com/$repo_path/pulls/$prid" ;;
    gitlab) echo "https://gitlab.com/$repo_path/-/merge_requests/$prid" ;;
    bitbucket) echo "https://bitbucket.org/$repo_path/pull-requests/$prid" ;;
  esac

  return 0
}

git_open_pipelines() {
  branch=$1
  if [[ -z $branch ]]; then
    branch=$(git branch --show-current)
  fi

  remote=$(git_get_remote)
  if [[ -z $remote ]]; then
    echo "No remote found"
    return 1
  fi

  remote_type=$(git_get_remote_type $remote)
  if [[ -z $remote_type ]]; then
    echo "Unknown remote type for $remote"
    return 1
  fi

  repo_path=$(git_get_repo_path $remote)
  case "$remote_type" in
    github) open_url "$silent" "https://github.com/$repo_path/actions" ;;
    gitlab) open_url "$silent" "https://gitlab.com/$repo_path/pipelines?scope=all" ;;
    bitbucket) open_url "$silent" "https://bitbucket.org/$repo_path/addon/pipelines/home" ;;
  esac

  return 0
}

git_open() {
  if [[ -z $1 ]]; then
    echo "Usage: git open [-s] <command>"
    echo
    echo "Commands:"
    echo "  project|repo|repository|open|.     Open the project"
    echo "  branch                             Open the project at given (or current) branch"
    echo "  commit                             Open the project at given (or current) commit"
    echo "  file                               Open the project at given file. Can also append ref hash"
    echo "  prs|mrs                            Open the PR list"
    echo "  pr|mr                              Create a new PR or open existing one"
    echo "  actions|pipelines|ci               Open the CI/CD pipelines"
    echo
    echo "Flags:"
    echo "  -s, --silent                       Silent mode (no output)"
    return 1
  fi

  case $1 in
    project|repo|repository|\.) git_open_project ;;
    branch) git_open_branch $@ ;;
    file) git_open_file $@ ;;
    commit) git_open_commit $@ ;;
    prs|mrs) shift; git_open_pr_list ;;
    pr|mr) shift; git_open_new_pr $@ ;;
    actions|pipelines|ci) shift; git_open_pipelines ;;
    --version|-V)
      u="$(tput smul)"
      r="$(tput sgr0)"
      echo "git-open v$(cat "${0:A:h}/version.txt")"
      echo "${u}https://github.com/chenasraf/git-open${r}"
      echo "Copyright \xC2\xA9 2024 Chen Asraf" ;;
    _debug)
      inf="Getting info"
      y=$(tput setaf 3)
      g=$(tput setaf 2)
      r=$(tput sgr0)

      echo -n "$r- ${y}$inf\r"
      remote=$(git_get_remote)
      echo -n "$r\\ ${y}$inf.\r"
      info=$(git remote show $remote)
      echo -n "$r| ${y}$inf..\r"
      branch=$(git branch --show-current)
      echo -n "$r/ ${y}$inf...\r"
      commit=$(git rev-parse HEAD)
      echo "${g}Done\e[0K$r\n"
      echo "Remote: $remote"
      echo "Repo Path: $(git_get_repo_path $remote)"
      echo "Remote Type: $(git_get_remote_type $remote)"
      echo "Current Branch: $branch"
      echo "Default Branch: $(echo $info | grep "HEAD branch" | awk '{print $3}')"
      echo "Current Ref: $commit"
      ;;
    *)
      echo "Unknown command: $1"
      return 1
      ;;
  esac
}

while true; do
  case "$1" in
    open) shift ;;
    -s|--silent) shift; silent="-s" ;;
    *) break ;;
  esac
done

git_open $@

if [[ -z "$__UNLOAD_PATH" ]]; then
  __UNLOAD_PATH="${0:A:h}/unload.zsh"
fi

. "$__UNLOAD_PATH"
