repo-sh-wrapper
===============

A bash wrapper of google repo, to init, sync and checkout code freely

update-repo.sh
==============
used to init and sync code from network into the repo name you given

USAGE:

    update-repo.sh example.repo -u REMOTE_REPO_URL

try 'update-repo.sh --help' for more information

checkout-repo.sh
================
used to checkout the code from a exist repo-dir into a directory you pointed

USAGE:

    checkout-repo.sh REPO_DIR CHECKOUT_DIR


DOWNLOAD REPO FIRST
===================

THE $REPO_PATH is the path your repo util stored. you can get the 'repo' like
this way

    git clone git://android.git.kernel.org/tools/repo.git

or

    git clone https://gerrit.googlesource.com/git-repo

