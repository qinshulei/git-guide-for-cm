# Git Guide For CM
## 版本控制系统

### 什么是版本控制系统?
是一种记录若干文件内容变化 , 以便将来查阅特定版本修订情况的系统

### 常见的版本控制系统有哪些?
+ 本地版本控制系统 (RCS)
+ 集中式版本控制系统 (CVS 、 SVN 、 Perforce)
+ 分布式版本控制系统 (Git 、 Mercurial 、 Bazaar 、 Darcs 、BitKeeper )

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

### 概念
+ sha-1                                   #是内容如 3d6051579e6434c62965b30583c67884f513acab 这样的字符串，用来唯一标识一段内容。类似与md5,在命令行下有sha1sum命令可以帮助生成文件的sha-1的值。其特点同样的内容生成出的sha-1值是一样的,而且不同的文件生成相同的sha-1概率是非常小的(到2014年为止，都没有听说有人遇到过碰撞的情况)。在 git 中，会通过 sha-1 去标识文件内容，提交内容，分支内容等等，也通过sha-1去查找文件内容.
+ blob                                    #git中保存文件内容的对象，存储在.git/objects目录下，会对文件内容的sha-1为文件名(准确的说是后38位，前两位为其所在子目录名)，并以zlib对文件内容进行压缩存储。
+ tree                                    #git中保存目录信息的对象，存储在.git/objects目录下，存储了目录和文件的层次信息也就是说会包含blob对象和子tree对象，同样会以这些信息的sha-1为文件名。
+ commit                                  #git中保存一次提交信息的对象，一次提交可以认为是工作目录所有文件的快照(很多人以为commit保存的是改动，其实不是)，这个快照记录了一个tree信息(整个工作目录以及文件内容的信息)，提交者，提交信息，修改时间，然后同样以这些信息得出的sha-1为文件名保存在.git/objects目录下。
+ ref                                     #可以理解为commit的别名。sha-1不利于记忆，因此我们更多的是给commit加上别名，这部份信息存储在.git/refs下
+ branch                                  #branch是ref的一种，含意是分支，每当用户在一个分支上有新的提交时，git会自动帮你把该branch指向的commit信息更新。
+ tag                                     #tag也是ref的一种，含意是标签，同样是给一个commit起别名，但这个别名是不可变的,同时还支持添加额外的描述信息，并保存为专用的tag对象(这也是为什么有时候tag不能直接当commit用的原因，而要tag^0来表示)
+ HEAD                                    #记录当前目录checkout出来的那个commit点或者是ref的点，保存在 .git/HEAD 里，git log 的时候，第一个点就是HEAD.

+ STASH                                   #git的五个存储区域之一，用来临时存储用户不想提交的内容，主要是将INDEX中的改动存到STASH中，这样用户就可以在INDEX区域开始新的工作。可以理解为将INDEX中的改动移动到STASH中，同样也有命令支持将STASH中的内容移动到WORKSPACE中
+ WORKSPACE                               #git的五个存储区域之一，主要是用户还没有加入道INDEX区域中的改动，这部份改动还没有存入到.git中，如果要提交这部份改动需要先将他们加入到INDEX区域中。我们直接修改一个文件，或者创建删除一个文件，这些改动都是在WORKSPACE区域
+ INDEX                                   #git的五个存储区域之一，已经存到.git中，但还没有提交的改动，所谓提交就是把在INDEX中的内容对应tree，加上提交的描述和提交的作者等信息创建一个新的commit对象，并清空INDEX区域。git add 命令就是将WORKSPACE中的改动移动到INDEX中。
+ LOCAL REPOSITORY                        #git的五个存储区域之一，指本地的git库,git commit可以理解为改动从INDEX区域提交到了LOCAL REPOSITORY。
+ UPSTREAM REPOSITORY                     #git的五个存储区域之一，指远程的git库.我们会使用一个服务器去集中管理多个人的提交。这时就存在这样一个UPSTREAM REPOSITORY，git push可以理解为将改动存到UPSTREAM REPOSITORY区域

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

将WORKSPACE的改动提交到INDEX区域，也可以说是将改动存到暂存区

```
# 将指定文件加到暂存区
$ git add <file>

# 将所有改动加到暂存区
$ git add -A

# 将除了删除以外的所有改动加到暂存区
$ git add .
```

### git branch

```
#列出所有分支
$ git branch -va

#列出所有已经合并的分支
$ git branch --merged
#列出所有没有合并的分支
$ git branch --no-merged

# 删除一个分支
$ git branch -D branch_name

```

### git am
### git checkout

```
# 检出本地的一个分支，如果为远程分支，HEAD将在一个游离的点上
$ git checkout master
# 检出本地的一个分支，并创建一个新的分支名
$ git checkout -b new_branch
# 检出上一次的分支
$ git checkout -

```

### git cherry-pick
### git clone

```
#通过http协议从远程下载一个git库，分支为默认的master
$ git clone https://...repo.git
```

### git clean

```
# 清理所有workspace下的改动
$ git clean -f -d

# 清理所有workspace下的改动，包含忽视的文件
$ git clean -f -d -x
```

### git commit

```
# 提交INDEX中的改动，并指定提交信息
$ git commit -m "Your commit message"

# 提交INDEX中的改动到上一次改动中
$ git commit --amend

# 提交一个空的提交
$ git commit -m "Big-ass commit" --allow-empty
```

### git diff

```
#比较两个分支代码的差别
$ git diff branch_1 branch_2
```

### git fetch

```
#下载最新远程的分支和标签
$ git fetch upstream

#下载gerrit上该库所有的change
$ git fetch origin '+refs/changes/*:refs/remotes/origin/changes/*'
```

### git format-patch
### git gc
### git grep

```
$ git grep aliases
$ git grep -e pattern --and -e anotherpattern
```

### git init

```
#创建一个新的git库
$ git init
```

### git merge

```
#将远程的master分支的改动合到当前分支中
$ git merge upstream/master
```

### git log

```
# 查看提交信息
$ git log

# 查看格式更好的提交信息
$ git log --all --graph --pretty=format:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
```

### git mv
### git pull

```
# 下载远程分支，并合并到当前分支中
$ git pull origin
```

### git push

```
# 将本地改动提交到 UPSTREAM REPOSITORY
$ git push origin master

# 将本地改动提交到指定的 UPSTREAM REPOSITORY
$ git push git@github.com:username/project.git

# 强制将本地改动提交到 UPSTREAM REPOSITORY，如果有冲突，会强制覆盖
$ git push origin master -f
```

### git rebase
### git reset

```
# 清空在INDEX和WORKSPACE的改动
$ git reset --hard
```

### git revert
### git rm

```
#从INDEX中删除一个文件
$ git rm --cached file.txt
#从INDEX删除一个目录的文件
$ git rm -r --cached ./

# 将WORKSPACE中删除的文件，在INDEX中删除
$ git rm $(git ls-files -d)
```

### git show

```
#查看一个commit的信息以及改动
$ git show 83fb499

#查看某个commit时，某文件当时的内容
$ git show 83fb499:path/fo/file.ext
```

### git status

```
#查看当前INDEX和WORKSPACE的状态
$ git status
#以简洁的形式显示当前INDEX和WORKSPACE的状态
$ git status -sb
```

### git stash
### git tag
### gitk
### git config

```
# 配置用户级别的git用户信息
$ git config --global user.name "John Doe"
$ git config --global user.email johndoe@example.com

# 配置默认的编辑器
$ git config --global core.editor emacs

# 配置彩色显示
$ git config --global color.ui true
```

### git mergetool
### git reflog
### git prune
### git remote

```
# 添加新的远程库
$ git remote add upstream git@github.com:name/repo.git
# 查看当前远程库
$ git remote -v
# 查看origin的远程库配置信息
$ git remote show origin
```

### git blame

```
# 查看文件中每一行是哪个提交谁改动的
$ git blame filename
```

### git fsck
### git rerere
### git apply
### git name-rev

```
# 查看一个提交所在的分支
$ git name-rev 97374dab58cffa8a7d81881377b386dc42c0dcba
```

### git show-ref

```
# 查看所有ref
$ git show-ref

# 删除除HEAD和master以外的所有ref,包括分支和标签
$ git show-ref | awk '{ print $2 }' | sed '/^HEAD$/d' | sed '/master$/d' | xargs -n 1 git update-ref -d --
```

### git daemon
### git http-backend

### git archive

```
# 导出库的内容，不包括.git, tar.gz格式
$ git archive master | tar -x -C /somewhere/else

# 导出库的内容，不包括.git, tar.bz2格式
$ git archive master | bzip2 >source-tree.tar.bz2

# 导出库的内容，不包括.git, zip格式
$ git archive --format zip --output /full/path/to/zipfile.zip master
```

## 常用变量
###  GIT_DIR
### GIT_WORK_TREE

## 例子

## 配置

## 技巧

+ fix up

```
$ git commit --fixup=abcde
$ git rebase abcde^ --autosquash -i
```

## 理念

## 参考资料
+ [Deep Dive into Git](https://www.youtube.com/watch?v=dBSHLb1B8sw) 视频讲解git的内部原理，五星推荐
+ [learnGitBranching](http://pcottle.github.io/lernGitBranchinng/?demo)
+ [沉浸式学Git](http://igit.linuxtoy.og/)
+ [git cheatsheet](http://ndpsoftware.com/git-cheatsheet.html) 通过交互式的界面显示命令，五星推荐
+ [github-cheat-sheet](https://github.com/tiimgreen/github-cheat-sheet)
+ [githug](https://github.com/Gazler/githug)
+ [git-style-guide](https://github.com/aseaday/git-style-guide)
+ [git-guide](https://github.com/rogerdudler/git-guide)
+ [git-magic](http://www-cs-students.stanford.edu/~blynn//gitmagic/)
+ [git-scm document](http://git-scm.com/doc)
+ [Git Internals](http://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain) Pro Git 讲解git原理的章节，并用ruby模拟git的一些实现的逻辑，五星推荐
+ [Official Git Video Tutorials](http://git-scm.com/videos)
+ [Code School Try Git](http://try.github.com/)
+ [Introductory Reference & Tutorial for Git](http://gitref.org/)
+ [Official Git Tutorial](http://git-scm.com/docs/gittutorial)
+ [Everyday Git](http://git-scm.com/docs/everyday)
+ [Git Immersion](http://gitimmersion.com/)
+ [Ry's Git Tutorial](http://rypress.com/tutorials/git/index)
+ [Git for Computer Scientists](http://eagain.net/articles/git-for-computer-scientists/)
+ [GitHub Training Kit](https://training.github.com/kit/)
+ [Git Visualization Playground](http://onlywei.github.io/explain-git-with-d3/#freeplay)
+ [Learn Git Branching](http://pcottle.github.io/learnGitBranching/)
+ [A collection of useful .gitignore templates](https://github.com/github/gitignore)
