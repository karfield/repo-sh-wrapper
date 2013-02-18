#!/bin/bash
#
# copyright (c) Karfield Chen
#

# XXX export $REPO_PATH first!
test -z $REPO_PATH &&
    echo "Fatal: env \$REPO_PATH not found!" &&
    exit 0

do_help=0
if test $# -lt 1 ||
    test "$1" == "-h" || test "$1" == "--help"; then
    do_help=1
elif test ! -z $1 && test -e $(dirname $1); then
    bn=$(basename $1)
    if test "$bn" == "${bn/.repo/}"; then
        echo "Your repo-dir name will be changed to '$bn.repo'"
        repo_dir=$(dirname $1)/$bn.repo
    else
        repo_dir=$1
    fi
    shift 1
elif test -e $1; then
    repo_dir=$1
    shift 1
else
    echo "Error: give your repo-dir first!"
    do_help=1
fi

wrapper_version=`cat $REPO_PATH/repo|grep "^VERSION *= *(.*)"|sed -n 's/.*(\([0-9]*\), *\([0-9]*\)).*/\1.\2/p'`
repo_main() {
    main_py=$REPO_PATH/main.py
    test -z $repo_dir &&
        repo_dir=./
    exec $main_py --repo-dir=$repo_dir --wrapper-version=$wrapper_version \
        --wrapper-path=$REPO_PATH -- $*
}

helps=`repo_main help init`
_ifs=$IFS
IFS=$'\n'
for l in $helps; do
    if test ${#l} -gt 5 && test "${l:0:4}" == "    "; then
        repo_init_helps=$repo_init_helps$l$'\n'
        IFS=$_ifs
        for w in $l; do
            case $w in
                -*)
                    init_options=$init_options$' '${w/[,=]*/}
                    ;;
            esac
        done
        IFS=$'\n'
    fi
done
IFS=$_ifs

print_help() {
    cmd=`basename $0`
    echo "Init and update a source repostroy"
    echo "$cmd Usage:"
    echo "  $cmd REPO_DIR -u [URL]"
    echo "  $cmd REPO_DIR [options]"
    echo "Options:"
    echo "    -h, --help          print help information"
    echo "    -j, --jobs          sync as multi jobs"
    echo "    --clone-bundle      clone bundle"
    echo "$repo_init_helps"
}

test $do_help -eq 1 &&
    print_help &&
    exit 0

no_clone_bundle=--no-clone-bundle
njobs=1
while test $# -gt 0; do
    case $1 in
        -j|--jobs)
            njobs=$2
            shift 2
            ;;
        --clone-bundle)
            no_clone_bundle=""
            shift 1
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        -*)
            for o in $init_options; do
                test "$1" == "$o" &&
                    match=1
            done
            test -z $match &&
                echo "Illegal option: '$1'" &&
                print_help &&
                exit 0
            # append init options
            init_opt=$init_opt" "$1
            shift 1
            if test "${1:0:1}" != "-"; then
                init_opt=$init_opt" "$1
                shift 1
            fi
            ;;
        *)
            echo "Illegal option: '$1'"
            print_help
            exit 0
            ;;
    esac
done

###################

if test ! -e $repo_dir/manifests/.git/HEAD; then
    test -e $repo_dir/manifests.git &&
        rm -rf $repo_dir/manifests.git
    mkdir -p $repo_dir
    test ! -e $repo_dir &&
        echo "No permission to create $repo_dir" &&
        exit 0
    echo "Start to init repostory..."
    repo_main init $init_opt
fi

if test -e $repo_dir/manifests/.git/HEAD; then
    echo "Start to sync repo via network..."
    repo_main sync --network-only -j $njobs $no_clone_bundle
fi

