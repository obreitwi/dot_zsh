# Open pickle file in python with name derived from argument
pklopen() {
    if [[ $# == 0 ]]; then
        ipython -ic "import pickle"
    elif [[ $# == 1 ]]; then
        ipython -ic "import pickle; ${1:t:r} = pickle.load( open( '${1}', 'r' ))"
    else
        ipython -ic "import pickle; ${2} = pickle.load( open( '${1}', 'r' ))"
    fi
}
