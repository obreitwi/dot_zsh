setkipproxy() {
    export no_proxy="localhost,127.0.0.1,.kip.uni-heidelberg.de"
    export http_proxy=http://proxy2.kip.uni-heidelberg.de:8080
    export ftp_proxy=http://proxy2.kip.uni-heidelberg.de:21
    export https_proxy=http://proxy2.kip.uni-heidelberg.de:8080
    export NO_PROXY="$no_proxy"
    export HTTP_PROXY="$http_proxy"
    export FTP_PROXY="$ftp_proxy"
    export HTTPS_PROXY="$http_proxy"
}

setnoproxy() {
    unset no_proxy
    unset http_proxy
    unset ftp_proxy
    unset https_proxy
    unset NO_PROXY
    unset http_proxy
    unset FTP_PROXY
    unset HTTPS_PROXY
}
