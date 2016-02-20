# Git Guide For CM
## 版本控制系统

### 什么是版本控制系统?
是一种记录若干文件内容变化 , 以便将来查阅特定版本修订情况的系统

### 常见的版本控制系统有哪些?
本地版本控制系统 (RCS)
集中式版本控制系统 (CVS 、 SVN 、 Perforce)
分布式版本控制系统 (Git 、 Mercurial 、 Bazaar 、 Darcs 、BitKeeper )

### Git 诞生
Git 有着显赫的身世 : Git 是 Linux 之父 Linus Torvalds的伟大作品。在 Linux 早期, Linus 顶着开源社区一大波精英们的口诛笔伐,选择的是一个商业版本控制系统 BitKeeper 作为 Linux 内核的代码管理工具。

转折 : 2005 年一件大事导致了 git 的诞生。 Samba 的作者 ( 澳大利亚人 Andrew Tridgell) 试图对 BitKeeper反向工程,希望可以开发出一个能与 BitKeeper 交互的开源工具。于是商业软件公司决定收回对 Linux 开源社区免费使用 BitKeeper 的授权。于是 Linus 盛怒之下开发出了分布式版本控制系统 git 。

### Git 优点
+ 开源:可以自由使用,无需授权、无专利费用
+ 非线性开发:支持多个并行开发分支
+ 完全分布式:既是客户端也是服务端
+ 离线、速度快:本地和远程独立操作,可以后期再同步
+ 兼容各种协议: git 、 ssh 、 http 等
+ 时刻保证数据的完整性:所有数据都要进行内容计算和校验,并将结果作为数据的唯一标识和索引
+ 有能力高效管理类似 Linux 内核一样的超大规模的项目( 速度和数据量 )

## Git基本流程

```
# Step 1: 安装git
$ sudo apt-get install git

## 验证: 现在应该可以在命令行使用git命令，结果如下
$ git --version
git version 1.7.9.5


# Step 2: 配置git基本个人信息, 必需配置，并要和以后的目标git服务器上的用户一致
$ git config --global user.name "Your Name"
$ git config --global user.email "Your Email"
### 配置默认的编辑器考虑到服务器，最常用的是vi
$ git config --global core.editor vi

## 验证: 执行完以上命令后，git会生成用户的git配置文件 ~/.gitconfig ,查看.gitconfig，应该有如下内容
$ cat ~/.gitconfig
[user]
	name = Your Name
	email = Your Email
[core]
	editor = vi

# Step 3: 创建git库,并新建README.md文件，并提交到本地git库中。
$ cd /path/to/your/git
$ mkdir project-directory
$ cd project-directory
$ git init
$ touch README.md
$ git add .
$ git commit -s -m "init"

## 验证: 成功提交后，可以通过git log查看刚刚提交的信息,类似信息如下:
$ git --no-pager log
commit 42be96853b5249f7a5f3432bd1d5f72ed25dc08e
Author: Your Name <Your Email>
Date:   Sat Feb 20 07:24:54 2016 +0000

    init

    Signed-off-by: vagrant <vagrant@precise64.(none)>

# git是分布式的版本控制系统，因此我们模拟用户A和用户B，同时修改README.md,来讲解提交，推送到服务端，合并冲突等话题

## 不过首先，一个远程的库，必须是bare的，否则，我们无法提交。这里使用手动的修改配置文件的方式，将普通库修改为bare库
$ mv .git .. && rm -fr *
$ mv ../.git .
$ mv .git/* .
$ rmdir .git
$ git config --bool core.bare true
$ cd ..
$ mv project-directory project-directory.git

# Step 4: 我们假设 project-directory 是远程的git服务器，我们用户A，用户B将分别从远程下载这个库，然后同时进行改动。

## 用户A,克隆，并改动
$ mkdir user-a
$ cd user-a
$ git clone ../project-directory.git
$ cd project-directory
$ echo "change by user A" >README.md
$ git add -A
$ git commit -m "add change by user a"

## 用户B,克隆，并改动
$ cd ..
$ mkdir user-b
$ git clone ../project-directory.git
$ cd project-directory
$ echo "change by user B" >README.md
$ git add -A
$ git commit -m "add change by user B"
$ cd ..

### 现在我们同时修改了README.md,然后我们开始提交这个改动，首先提交用户A的改动
### 查看当前远程分支
$ git remote -v
origin	/home/vagrant/user-a/../project-directory.git (fetch)
origin	/home/vagrant/user-a/../project-directory.git (push)
## 使用默认的配置提交代码，写全了是 git push origin HEAD:master
$ git push
Counting objects: 5, done.
Writing objects: 100% (3/3), 259 bytes, done.
Total 3 (delta 0), reused 0 (delta 0)
Unpacking objects: 100% (3/3), done.
To /home/vagrant/user-a/../project-directory.git
   ce8348e..3073a5d  master -> master

### 现在我们再来提交B的改动
$ cd ../../user-b/project-directory
### 因为A提交过了，远程的master已经有了变化，直接提交是会失败的。
$ git commit -m "add change by user B"
[master 390ecfc] add change by user B
 1 file changed, 1 insertion(+)
vagrant@precise64:~/user-b/project-directory$ git push
To /home/vagrant/user-b/../project-directory/
 ! [rejected]        master -> master (non-fast-forward)
error: failed to push some refs to '/home/vagrant/user-b/../project-directory/'
To prevent you from losing history, non-fast-forward updates were rejected
Merge the remote changes (e.g. 'git pull') before pushing again.  See the
'Note about fast-forwards' section of 'git push --help' for details.

### 我们需要，先将A的改动拉下来，合到我们的改动中，并解决合并时产生的冲突
$ git pull
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
Automatic merge failed; fix conflicts and then commit the result.
### 解决冲突 CONFLICT (content): Merge conflict in README.md
$ cat README.md
<<<<<<< HEAD
change by user B
=======
change by user A
>>>>>>> 3073a5d81acd2c2d8075f493ef3f53ecd32e63fd
### 一个典型的冲突如上面所示，git已经帮我们用 <<<<<<< ======= >>>>>>标出了冲突，需要我们，自行编辑这部份内容，比如用A的改动，或者用B的改动，或者同时保留两个改动，或者写全新的改动都是可以的。
### 我们用编辑器将该文本改为如下，就是保留两个改动
$ cat README.md
change by user B
change by user A

### 添加这次改动，再重新提交
$ git add -A
$ git commit
$ git push
Counting objects: 10, done.
Delta compression using up to 2 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (6/6), 577 bytes, done.
Total 6 (delta 0), reused 0 (delta 0)
Unpacking objects: 100% (6/6), done.
To /home/vagrant/user-b/../project-directory.git
   3073a5d..828e81d  master -> master

### 至此，一个git最常见的流程就走完了

# 验证: 我们就进最开始的那个库中检查我们的提交是否在master中了
cd ../../project-directory.git
$ git log master
commit 828e81d33b5dc3dcf10ec58d7c09a3c0ad767f67
Merge: 390ecfc 3073a5d
Author: Your Name <Your Email>
Date:   Sat Feb 20 09:45:02 2016 +0000

    Merge branch 'master' of /home/vagrant/user-b/../project-directory

    Conflicts:
        README.md

commit 390ecfc16afdae323b16dcf132a5e332afd5708e
Author: Your Name <Your Email>
Date:   Sat Feb 20 09:32:52 2016 +0000

    add change by user B

commit 3073a5d81acd2c2d8075f493ef3f53ecd32e63fd
Author: Your Name <Your Email>
Date:   Sat Feb 20 08:47:32 2016 +0000

    add change by user a

commit ce8348ea824b1f4c4605733d5e74348735bea835
Author: Your Name <Your Email>
Date:   Sat Feb 20 07:24:54 2016 +0000

    init

    Signed-off-by: vagrant <vagrant@precise64.(none)>

# 如上所示，最终我们得到了A B两个人的提交

```

## 常用命令
### git add
### git branch
### git am
### git checkout
### git cherry-pick
### git clone
### git clean
### git commit
### git diff
### git fetch
### git format-patch
### git gc
### git grep
### git init
### git merge
### git log
### git mv
### git pull
### git push
### git rebase
### git reset
### git revert
### git rm
### git show
### git status
### git stash
### git tag
### gitk
### git config
### git mergetool
### git reflog
### git prune
### git remote
### git blame
### git fsck
### git rerere
### git apply
### git-name-rev
### git-show-ref
### git daemon
### git-http-backend

## 常用变量
###  GIT_DIR
### GIT_WORK_TREE

## 例子

## 配置

## 技巧

## 理念

## 参考资料
### [learnGitBranching](http://pcottle.github.io/learnGitBranching/?demo)
### [沉浸式学Git](http://igit.linuxtoy.org/)
### [git-cheatsheet](https://github.com/trufa/git-cheatsheet)
### [git cheatsheet](http://ndpsoftware.com/git-cheatsheet.html)
通过交互式的界面显示命令，五星推荐
### [github-cheat-sheet](https://github.com/tiimgreen/github-cheat-sheet)
### [githug](https://github.com/Gazler/githug)
### [git-style-guide](https://github.com/aseaday/git-style-guide)
### [git-guide](https://github.com/rogerdudler/git-guide)
### [git-magic](http://www-cs-students.stanford.edu/~blynn//gitmagic/)
### [Deep Dive into Git](https://www.youtube.com/watch?v=dBSHLb1B8sw)
视频讲解git的内部原理，五星推荐
### [git-scm document](http://git-scm.com/doc)
### [Git Internals](http://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain)
Pro Git 讲解git原理的章节，并用ruby模拟git的一些实现的逻辑，五星推荐
