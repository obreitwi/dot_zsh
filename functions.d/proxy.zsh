setkipproxy() {
    export no_proxy="localhost,127.0.0.1,.kip.uni-heidelberg.de"
    export http_proxy=http://proxy2.kip.uni-heidelberg.de:8080
    export ftp_proxy=http://proxy2.kip.uni-heidelberg.de:21
    export https_proxy=http://proxy2.kip.uni-heidelberg.de:8080
}

setnoproxy() {
    unset no_proxy
    unset http_proxy
    unset ftp_proxy
    unset https_proxy
}
