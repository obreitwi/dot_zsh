slurm-get-job-ids() {
    if [[ $# > 1 ]]; then
        state=$1
    else
        state="PD"
    fi
    squeue -h | grep "${USER}" | grep "\b$state\b" | cut -d " " -f 3
}
