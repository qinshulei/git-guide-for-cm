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

### 如何学习
Git 作为如今开源世界的基础，优秀教程多如牛毛。随意挑其中几个教程走上一遍，就能很好的掌握基本内容。

但作为 linus 这样的技术天神设计的工具，本身就是非常技术化的思路。了解其内部原理，无论对于记忆命令还是掌握高阶技巧都很有必要。

Kent Beck(JUnit作者) 说他最终发现git的命令其实都是图算法中节点的创建删除和移动.

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/kent_beck_tweet.jpg)

### 概念

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/graphs-and-git.png)

+ sha-1                                   #是内容如 3d6051579e6434c62965b30583c67884f513acab 这样的字符串，用来唯一标识一段内容。类似与md5,在命令行下有sha1sum命令可以帮助生成文件的sha-1的值。其特点同样的内容生成出的sha-1值是一样的,而且不同的文件生成相同的sha-1概率是非常小的(到2014年为止，都没有听说有人遇到过碰撞的情况)。在 git 中，会通过 sha-1 去标识文件内容，提交内容，分支内容等等，也通过sha-1去查找文件内容.
+ blob                                    #git中保存文件内容的对象，存储在.git/objects目录下，会对文件内容的sha-1为文件名(准确的说是后38位，前两位为其所在子目录名)，并以zlib对文件内容进行压缩存储。
+ tree                                    #git中保存目录信息的对象，存储在.git/objects目录下，存储了目录和文件的层次信息也就是说会包含blob对象和子tree对象，同样会以这些信息的sha-1为文件名。
+ commit                                  #git中保存一次提交信息的对象，一次提交可以认为是工作目录所有文件的快照(很多人以为commit保存的是改动，其实不是)，这个快照记录了一个tree信息(整个工作目录以及文件内容的信息)，提交者，提交信息，修改时间,父节点信息，然后同样以这些信息得出的sha-1为文件名保存在.git/objects目录下。
+ ref                                     #可以理解为commit的别名。sha-1不利于记忆，因此我们更多的是给commit加上别名，这部份信息存储在.git/refs下
+ branch                                  #branch是ref的一种，含意是分支，每当用户在一个分支上有新的提交时，git会自动帮你把该branch指向的commit信息更新。因此branch和svn中的branch相比要轻量级很多。不用考虑会有额外的开销。用户可以随时拉出一个分支去做自己想要做的工作，随时合并回主分支. 分支是用来将特性开发绝缘开来的。在你创建仓库的时候，master 是“默认的”分支。在其他分支上进行开发，完成后再将它们合并到主分支上。
+ tag                                     #tag也是ref的一种，含意是标签，同样是给一个commit起别名，但这个别名是不可变的,同时还支持添加额外的描述信息，并保存为专用的tag对象(这也是为什么有时候tag不能直接当commit用的原因，而要tag^0来表示)
+ HEAD                                    #记录当前目录checkout出来的那个commit点或者是ref的点，保存在 .git/HEAD 里，git log 的时候，第一个点就是HEAD.也是你当前工作的那个点。你的改动也都是基于这个点。
+ STASH                                   #git的五个存储区域之一，用来临时存储用户不想提交的内容，主要是将INDEX中的改动存到STASH中，这样用户就可以在INDEX区域开始新的工作。可以理解为将INDEX中的改动移动到STASH中，同样也有命令支持将STASH中的内容移动到WORKSPACE中
+ WORKSPACE                               #git的五个存储区域之一，主要是用户还没有加入道INDEX区域中的改动，这部份改动还没有存入到.git中，如果要提交这部份改动需要先将他们加入到INDEX区域中。我们直接修改一个文件，或者创建删除一个文件，这些改动都是在WORKSPACE区域
+ INDEX                                   #git的五个存储区域之一，已经存到.git中，但还没有提交的改动，所谓提交就是把在INDEX中的内容对应tree，加上提交的描述和提交的作者等信息创建一个新的commit对象，并清空INDEX区域。git add 命令就是将WORKSPACE中的改动移动到INDEX中。
+ LOCAL REPOSITORY                        #git的五个存储区域之一，指本地的git库,git commit可以理解为改动从INDEX区域提交到了LOCAL REPOSITORY。
+ UPSTREAM REPOSITORY                     #git的五个存储区域之一，指远程的git库.我们会使用一个服务器去集中管理多个人的提交。这时就存在这样一个UPSTREAM REPOSITORY，git push可以理解为将改动存到UPSTREAM REPOSITORY区域

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/trees.png)

+ merge                                   #将两个来自于同一个父亲节点然后有不同改动的点，合并成一个点.
+ rebase                                  #改变改动的次序,修改改动历史，让改动更清晰，更有意义
+ remote                                  #一般指服务器，用来存储提交，和其他用户协作。其内容就是你git库的备份。但一般用户没有修改其历史的权限，因此需要用户提交时注意自己所有修改的历史必需是还没有提交的remote的.远程一般在本地以远程分支出现，远程分支不能直接修改，需要我们检出一个本地分支，在进行修改。

+ 工作流                                   #你的本地仓库由 git 维护的三棵“树”组成。第一个是你的 工作目录，它持有实际文件；第二个是 暂存区（Index），它像个缓存区域，临时保存你的改动；最后是 HEAD，它指向你最后一次提交的结果
+ 相对引用                                 # 形如 HEAD^^ 或者 HEAD~2 ,指当前commit的上上个commit.这样不用去记忆长长的sha-1值

## Git基本流程

Git流程简单示意图:

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/branches.png)


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

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_branch_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_branch_2.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_branch_3.png)

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

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_checkout_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_checkout_2.png)


```
# 检出本地的一个分支，如果为远程分支，HEAD将在一个游离的点上
$ git checkout master
# 检出本地的一个分支，并创建一个新的分支名
$ git checkout -b new_branch
# 检出上一次的分支
$ git checkout -

```

### git cherry-pick

+ 例1

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_cherry_pick_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_cherry_pick_2.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_cherry_pick_n_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_cherry_pick_n_2.png)

+ 例2

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-2.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-3.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-4.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-5.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-6.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-7.png)

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

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_commit_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_commit_2.png)

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

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_fetch_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_fetch_2.png)

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

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_merge_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_merge_2.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_merge_3.png)

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

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_master_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_master_2.png)


![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_pull_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_pull_2.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_pull_3.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_pull_4.png)


```
# 下载远程分支，并合并到当前分支中
$ git pull origin
```

### git push


![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_push_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_push_2.png)



![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_create_branch.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_create_branch_2.png)


![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_push_clearly_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_push_clearly_2.png)



```
# 将本地代码推送到远程分支。
$ git push <remote> <place>

# 将本地改动提交到 UPSTREAM REPOSITORY
$ git push origin master

# 将本地改动提交到指定的 UPSTREAM REPOSITORY
$ git push git@github.com:username/project.git

# 强制将本地改动提交到 UPSTREAM REPOSITORY，如果有冲突，会强制覆盖
$ git push origin master -f
```

### git rebase

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_2.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_3.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_4.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_i_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_i_2.png)

```
$ git rebase master
$ git rebase -i
```
### git describe

### git reset

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_reset_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_reset_2.png)

```
# 清空在INDEX和WORKSPACE的改动
$ git reset --hard
```

### git revert

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_revert_1.png)

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

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_tag.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_tag_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_tag_2.png)

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

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_remote_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_remote_2.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_remote_3.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_remote_4.png)

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

+ 本地和远程分支的关联。通过git checkout origin/master -b master,切换出来的分支，默认是会建立，master和origin/master之间的关系。就是master的upstream是origin/master.
在建立了这种联系以后。在master分支上git pull或者git push都可以省略远程目标，因为git会默认使用关联的远程分支做目标。类似命令还有 git branch -u o/master master,手动指定 upstream

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_local_master_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_local_master_2.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_local_master_3.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_local_master_4.png)

![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_upstream_1.png)
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_upstream_2.png)

+ sha-1值可以只写前几位，只要能够区分不同的commit就行，比如 fed2da64c0efc5293610bdd892f82a58e8cbc5d8 就可以简写为 fed2 。
我们可以用4位以上的位数的sha-1的前缀去表示一个sha-1,只要能保证唯一.当然只用四位唯一标识一个提交在android一些比较大的库还是有可能重复的，
所以一般 git log --oneline 等显示sha-1缩写的地方都是7位。即便是在linux kernel这样庞大的项目中写 12 位也足够了.

+ 误删了某个分支，可以找回

只要提交过的commit，在git下次进行垃圾回收之前，都是会被保留的。因此误删了一个分支，但分支相关的commit还在，只要查看，最近操作过的commit信息，然后重新在这个commit上创建分支就可以了。

```
# 查看最近操作过的commit
$ git reflog
7a098ac HEAD@{0}: commit: add same command
3d60515 HEAD@{1}: commit: 添加基本流程
5b83d2b HEAD@{2}: commit (amend): first commit
c309a5f HEAD@{3}: commit (initial): first commit
# 重新在某个commit上创建分支
$ git checkout 3d60515 -b target-branch
```

+ fix up

```
$ git commit --fixup=abcde
$ git rebase abcde^ --autosquash -i
```

## 理念

### Branches

* 选择*简短*和*具有描述性*的名字来命名分支：

  ```shell
  # 好
  $ git checkout -b oauth-migration

  # 不好，过于模糊
  $ git checkout -b login_fix
  ```

* 来自外部的标识符也适合用作分支的名字，例如来自 Github 的 Issue 序号。

  ```shell
  # GitHub issue #15
  $ git checkout -b issue-15
  ```

* 用破折号分割单词。

* 当不同的人围绕同一个特性开发时，维护整个团队的特性分支与每个人的独立分支是比较方便的做法。使用如下的命名方式：

  ```shell
  $ git checkout -b feature-a/master # team-wide branch
  $ git checkout -b feature-a/maria # Maria's branch
  $ git checkout -b feature-a/nick # Nick's branch
  ```

  合并时，由每个人的独立分支向全队的功能分支合并，最后合并到主分支。见[合并](#merging) 。

* 合并之后，除非有特殊原因，从上游仓库中删除你的分支。使用如下命令查看已合并的分支：

  ```shell
  $ git branch --merged | grep -v "\*"
  ```

### Commits

* 每个提交应当只包含一个简单的逻辑改动，不要在一个提交里包含多个逻辑改动。比如，如果一个补丁修复了一个 Bug，又优化了一个特性的性能，就将其拆分。
* 不要将一个逻辑改动拆分提交。例如一个功能的实现及其对应的测试应当一并提交。
* 尽早、尽快提交。出问题时，短小、完整的提交更容易发现并修正。
* 提交应当依*逻辑*排序。例如，如果 X 提交依赖于 Y，那么 Y 提交应该在 X 前面。

### Messages

* 使用编辑器编写提交信息，而非命令行。

  ```shell
  # 好
  $ git commit

  # 不好
  $ git commit -m "Quick fix"
  ```

  使用命令行会鼓励试图用一行概括提交內容的风气，而这会令提交信息难以理解。

* 概要行（即第一行）应当简明扼要。它最好不超过 50 个字符，首字母大写，使用现在时祈使语气。不要以句号结尾, 因为它相当于*标题*。

  ```shell
  # 好
  Mark huge records as obsolete when clearing hinting faults

  # 不好
  fixed ActiveModel::Errors deprecation messages failing when AR was used outside of Rails.
  ```

* 在那之后空一行，然后填写详细描述。每行不超过 *72 字符*，解释*为什么*需要改动, *如何*解决了这个 issue 以及它有什么*副作用*。

  最好提供相关资源的链接，例如 bug tracker 的 issue 编号：
  ```shell
  Short (50 chars or fewer) summary of changes

  More detailed explanatory text, if necessary. Wrap it to
  72 characters. In some contexts, the first
  line is treated as the subject of an email and the rest of
  the text as the body.  The blank line separating the
  summary from the body is critical (unless you omit the body
  entirely); tools like rebase can get confused if you run
  the two together.

  Further paragraphs come after blank lines.

  - Bullet points are okay, too

  - Use a hyphen or an asterisk for the bullet,
    followed by a single space, with blank lines in
    between

  Source http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
  ```

  最后，编写提交信息时，设想一下你一年以后再看这段提交信息时，希望获取什么信息。

* 如果 *提交 A* 依赖于另一个 *提交 B* ，在前者的 commit message 中应当指明。援引对应提交的 Hash。

  同理，如果 *提交 A* 解决了 *提交 B* 引入的 bug，这应当也被在 *提交 A* 提及。
* 如果将一个提交 squash 到另一个提交，分别使用 `--squash` 和 `--fixup` 来强调目的。
  ```shell
  $ git commit --squash f387cab2
  ```
  *（Rebase 时使用 `--autosquash` 参数，标记的提交就会自动 squash。）*

### Merging

* **不要篡改提交历史。**仓库的历史本身就很宝贵，重要的是它能够还原*实际发生了什么*。对任何参与项目的人来说，修改历史是万恶之源。
* 尽管如此，有些时候还是可以重写历史，例如：
  * 你一个人孤军奋战，而且你的代码不会被人看到。
  * 你希望整理分支（例如使用 squash），以便日后合并。
  最重要的，*不要重写你的 master 分支历史* 或者任何有特殊意义的分支（例如发布分支或 CI 分支）。
* 保持你的提交历史*干净*、*简单*。*在你 merge* 你的分支之前：
  1. 确保它符合风格指南，如果不符合就执行相应操作，比如 squash 或重写提交信息。
  2. 将其 rebase 到目标分支：
     ```shell
     [my-branch] $ git fetch
     [my-branch] $ git rebase origin/master
     # then merge
     ```
  这样会在 master 后直接添加一个新版本，令提交历史更简洁。

  *（这个策略更适合较短生命周期的分支，否则还是最好经常合并而不是 rebase。）*

* 如果你的分支包含多个 commmit , 不要使用快进模式。
  ```shell
  # 好；注意添加合并信息
  $ git merge --no-ff my-branch

  # 不好
  $ git merge my-branch
  ```

### Misc.

* 有许多工作流，每一个都有好有坏。一个工作流是否符合你的情况，取决于你的团队，项目，和你的开发规律。

  也就是说，重要的是认真 *选择* 合适的工作流并且坚持。
* *保持统一*， 这涉及到从工作流到你的提交信息，分支名还有标签。 在整个 Repository 中保持统一的命名风格有助于辨认工作进度。
* *push 前测试*， 不要提交未完成的工作。
* 使用 [annotated tags](http://git-scm.com/book/en/v2/Git-Basics-Tagging#Annotated-Tags) 标记发布版本或者其他重要的时间点。

  个人开发可以使用 [lightweight tags](http://git-scm.com/book/en/v2/Git-Basics-Tagging#Lightweight-Tags)，例如为以后参考做标记。
* 定期维护，保证你的仓库状态良好，包括本地还有远程的仓库。

  * [`git-gc(1)`](http://git-scm.com/docs/git-gc)
  * [`git-prune(1)`](http://git-scm.com/docs/git-prune)
  * [`git-fsck(1)`](http://git-scm.com/docs/git-fsck)

### REFERENCES MAKE COMMITS REACHABLE

git 会清理不用的commit.那哪些是不用的commit呢？首先我们知道ref包括branch tag head,其中每个ref都会指向一个commit,而每个commit中包含一个或者多个父节点。这样我们从所有的ref出发不断找父节点，可以徧历出能够到达的commit列表。而不在这个列表的commit就是不能到达的，会在 `git gc` 后被删除。

### commit 是不可变的

git commit --amend 将改动提交到上一次提交，表面来看是改变上一个提交，但其实没有，git其实是创建了一个新的提交包含了上一个提交的改动和你这次提交的改动，然后替换了上一个提交。就和java的字符串一样，每一次改动都是创建新的副本然后替换老的。类似命令包括 git rebase ,git reset.因此在使用这些命令的时候并不需要担心操作失误导致改动丢失。这样在 git 进行下一次垃圾回收之前，你 rebase 或 reset 之前的提交都是存在的.

## 参考资料
+ [git-guide](http://rogerdudler.github.io/git-guide/index.zh.html) 最简洁的中文教程，不过内容有点太少了
+ [learnGitBranching](http://pcottle.github.io/lernGitBranchinng/?demo) 交互式教程，边做练习边动态展示git命令的作用，非常适合自学，可以切换中文, 五星推荐
+ [git cheatsheet](http://ndpsoftware.com/git-cheatsheet.html) 通过交互式的界面显示命令的cheatsheet,非常方便查询命令，五星推荐
+ [Deep Dive into Git](https://www.youtube.com/watch?v=dBSHLb1B8sw) 视频讲解git的内部原理，五星推荐
+ [Git Internals](http://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain) Pro Git 讲解git原理的章节，并用ruby模拟git的一些实现的逻辑，五星推荐
+ [Think Like (a) Git](http://think-like-a-git.net/) 用图论讲解git,git cherry-pick,以及git rebase都讲的不错，适合加深理解
+ [沉浸式学Git](http://igit.linuxtoy.og/) 中文教程
+ [github-cheat-sheet](https://github.com/tiimgreen/github-cheat-sheet)
+ [githug](https://github.com/Gazler/githug)
+ [git-style-guide](https://github.com/aseaday/git-style-guide)
+ [git-magic](http://www-cs-students.stanford.edu/~blynn//gitmagic/)
+ [git-scm document](http://git-scm.com/doc)
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
+ [图解Git](http://marklodato.github.io/visual-git-guide/index-zh-cn.html) 中文教程

