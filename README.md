# git-sync
## What is this?
This is just a simple script which enables git user to sync multiple branches on origin with origin/master.
All you need to do is to run following command (after following the steps given later in description):

`git sync <branch_suffix>`

With this, all the branches which end with `<branch_suffix>` will be synced with origin/master branch.

If there are any conflicts with some branch, those branches will be listed at the end of command.

e.g., If you want to sync all the branches which end with "Release-Module", something like "Test-Release-Module",
You will run `git sync Release-Module`

You can also sync all of the branches to master by just running "git sync".

This is neccessary usually after the releases, when different teams were working on different module branches.

## How does this work?
Steps followed in this script are as follow:

1. Remove all the branches with `<branch_suffix>` as suffix from local machine
2. Fetch all the branches from origin.
3. Checkout a fresh branch from the branch with `<branch_suffice>` as suffix from origin.
4. Merge origin/master into these branches
5. Push the newly synced branches on local to origin

## Easy ways to make use of this
There are two ways, you can use this script (I prefer 1st one):

1. Create custom git command so that you don't have to create `.sh` file everytime you want to sync your branchs (For Ubuntu)
    * Create a file named `git-sync` in directory `/bin` as sudo user. Copy code from `git-sync.sh` to that file and save it.
    * Do `chmod +x git-sync`
    * Make sure you have `PATH=$PATH:$HOME/bin` in `$HOME/.bashrc` file. If not, add it.
    * And its done :D. Now go to your git repo folder and just type `git sync`, that's it.
    * You can refer to this blog for details: http://thediscoblog.com/blog/2014/03/29/custom-git-commands-in-3-steps/

2. Create bash script file with following code and execute that as following (For Mac):
    * Copy code in `git-sync.sh` file in your repo directory (where we have .git).
    * Do `chmod 755 git-sync.sh`
    * Just run `./sync_all.sh <branch_suffix>` from command line. 

##  Don't just use it blindly. Things to keep in mind:

1. It will delete branches with suffix as `<branch_suffix>` from local machine first. So if you have some changes in some branch, that are not on origin, either change the branch name or push that branch to origin.
2. Before running the command or script, make sure you don't have any uncommited changes on current branch.

#### P.S. Suggestions for improvement are always welcomed. Feel free to leave comments or file PR with changes.
