
bb-current-project() {
    git remote get-url origin | awk -v FS=/ '{ print $(NF-1)}'
}

bb-current-repo() {
    git remote get-url origin | awk -v FS=/ '{ print $NF}'
}

bb-current-domain() {
    git remote get-url origin | awk -v FS=/ '{ print $3}'
}

bb-current-url() {
    echo "https://$(bb-current-domain)/rest/api/1.0/projects/$(bb-current-project)/repos/$(bb-current-repo)"
}

bb-get() { # <endpoint>
    curl -H "authorization: Bearer $(cat ~/.config/bitbucket/cli.token)" "$(bb-current-url)/$1"
}

bb-post() { # <endpoint>
    curl --json @- -H "authorization: Bearer $(cat ~/.config/bitbucket/cli.token)" "$(bb-current-url)/$1"
}

