
# Get planned changes
tf-changes() {
    jq -r 'select( .type == "planned_change" ) | .change.resource.addr' <"$(tf-json)"
}

# Get temporary json file for the current terraform deployment
tf-json() {
    pwd | awk -v FS=/ '{printf("/tmp/tf-%s-%s.json", $(NF-1), $NF)}'
}

# Plan terraform
tf-plan() {
    terraform plan -json | tee "$(tf-json)" | jq -r '."@message",.diagnostic?.detail?'
}
