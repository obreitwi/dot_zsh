# Usage:
#   host_to_ip <hostname>
#
# Prints the ip of the given hostname.
host_to_ip() {
    getent hosts "$1" | cut -d ' ' -f 1
}
