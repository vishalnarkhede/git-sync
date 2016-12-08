#!/bin/bash

# In following script, we will sync all the Release-Modules
# Here I'm just taking Release-Module as an example.
# You will provide this branch siffix as command line argument.
# will origin/master and push them to origin.

validate_input () {
    if [[ $1 == "--" ]] || [[ $1 == "" ]]
    then
        echo "You haven't given any branch suffix. This will sync all your branches to master. Are you sure you want to continue [Yes]"
        read choice
        if [[ $choice != "yes" ]]
        then
            exit
        fi
    fi
}

remove_all_suffixed_modules_from_local () {
    # Checkout to master
    git checkout master

    # Get all the local branches that end with "Release-Module"
    if [[ $1 == "--" ]] || [[ $1 == "" ]]
    then
        output="$(git branch)"
    else
        output="$(git branch | grep $1$)"
    fi

    output="${output/\* /}"
    # Remove all those Release-Module branches on local.
    # While syncing, we will checkout new branch from origin.
    for branch in $output
    do
        echo Removing branch $branch
        branch="${branch/* /}"
        remove_branch="$(git branch -D $branch)"
        echo $remove_branch
        echo
    done
    echo All release module branches deleted
    echo ------------------------------------------------------------
    echo ------------------------------------------------------------
}

# Get all the branches on origin ending with "Release-Module"
# Output of following command will be something like this:
#
# remotes/origin/API-Changes-For-Mobile-Release-Module
# remotes/origin/API-Hotfix-Release-Module
# remotes/origin/Affiliate-Widgets-Release-Module
# remotes/origin/Affiliates-Release-Module
#
# We will remove "remotes/origin/" part later (on line 46)
sync_all_suffixed_branch_to_master () {
    if [[ $1 == "--" ]] || [[ $1 == "" ]]
    then
        release_modules_on_origin="$(git branch -a --list)"
    else
        release_modules_on_origin="$(git branch -a --list | grep $1$)"
    fi

    conflicted_branches=()

    # Loop through all these branches for syncing with master
    for branch in $release_modules_on_origin
    do
        echo $branch
        # Remove "remotes/origin/" from branch names
        what_to_replace=remotes/origin/
        what_to_replace_with=
        branch_name="${branch/$what_to_replace/$what_to_replace_with}"

        # Checkout branch from *-Release-Module
        # e.g., git checkout -b CV-Search-Release-Module origin/CV-Search-Release-Module
        checkout_cmd_output="$(git checkout -b $branch_name origin/$branch_name)"

        # We might run into error of 
        if [[ $checkout_cmd_output == *"fatal: Unable to create"* ]] && [[ $checkout_cmd_output == *"index.lock': File exists."* ]]
        then
            rm .git/index.lock
            git checkout master
            git branch -D $branch_name
            checkout_cmd_output="$(git checkout -b $branch_name origin/$branch_name)"
        fi
        echo $checkout_cmd_output
        merge_master_output="$(git merge origin/master)"
        # echo $merge_master_output
        if [[ $merge_master_output == *"CONFLICT (content): Merge conflict"* ]]
        then
            echo ----------------------------------------------------
            echo ----------------------------------------------------
            echo
            echo         Woah woah! There is a conflict in $branch
            echo         I will give you list of such branches in the end
            echo
            echo ----------------------------------------------------
            echo ----------------------------------------------------

            # Abort the merge if there was a conflict
            git merge --abort
            echo MERGE ABORTED

            # Append it to list of conflicted branches,
            # for displaying in the end
            conflicted_branches+=($branch_name)
         else
            echo "Merge successful on $branch_name";
            push_to_origin_cmd_output="$(git push origin $branch_name)"
            echo $push_to_origin_cmd_output
            echo ------------------------------------------------------------
            echo ------------------------------------------------------------
        fi
    done

    echo
    echo
    echo ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    echo
    echo THERE WAS CONFLICT IN FOLLOWING BRANCHES ... PLEASE RESOLVE THOSE MANUALLY:
    echo
    # List down all the release modules.
    for conflicted_branch in $conflicted_branches
    do
        echo $conflicted_branch
    done
    echo
    echo
}

fetch_origin () {
    #  Fetch origin
    git fetch origin
    echo Origin Fetched
    echo -----------------------------------------------------------
    echo -----------------------------------------------------------
    echo
}

validate_input $1

remove_all_suffixed_modules_from_local $1

fetch_origin

sync_all_suffixed_branch_to_master $1

