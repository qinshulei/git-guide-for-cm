# Git Guide For CM
## 版本控制系统

### 什么是版本控制系统?
是一种记录若干文件内容变化 , 以便将来查阅特定版本修订情况的系统.

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

可以在本文最后的参考资料中找到优秀的教程链接。比如 [learnGitBranching](http://pcottle.github.io/lernGitBranchinng/?demo) ，讲解加练习，支持中文，请一定要过一遍。

作为 linus 这样的技术大神设计的工具，本身就是非常技术化的思路。因此最好了解其内部原理，这样学习起来会更轻松，记忆也会更深刻。 Kent Beck(JUnit作者) 说他最终发现git的命令其实都是图算法中节点的创建删除和移动.  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/kent_beck_tweet.jpg)

讲解原理的推荐看，pro git 的相关章节  [Git 内部原理](http://git-scm.com/book/zh/v2/Git-%E5%86%85%E9%83%A8%E5%8E%9F%E7%90%86-%E5%BA%95%E5%B1%82%E5%91%BD%E4%BB%A4%E5%92%8C%E9%AB%98%E5%B1%82%E5%91%BD%E4%BB%A4)  或者 相关youtube视频 [Deep Dive into Git](https://www.youtube.com/watch?v=dBSHLb1B8sw)

本文档主要作为提纲，罗列一些工作中常用的知识点，以帮助用户，发现自己的不足，去学习更多相关内容。因此若还没有对git有基本的理解，请先完成上面提到的教程的学习.

### 概念
#### git中的对象

Git 作为版本控制系统，主要需要存储文件内容，目录结构，提交信息，分支信息的数据。这些数据分别对应着git中的对象。下面介绍这些对象相关的名词:

+ sha-1                                   #是内容如 3d6051579e6434c62965b30583c67884f513acab 这样的字符串，用来唯一标识一段内容。类似与md5,在命令行下有sha1sum命令可以帮助生成文件的sha-1的值。其特点同样的内容生成出的sha-1值是一样的,而且不同的文件生成相同的sha-1概率是非常小的(到2014年为止，都没有听说有人遇到过碰撞的情况)。在 git 中，会通过 sha-1 去标识文件内容，提交内容，分支内容等等，也通过sha-1去查找文件内容.
+ blob                                    #git中保存文件内容的对象，存储在.git/objects目录下，会对文件内容的sha-1为文件名(准确的说是后38位，前两位为其所在子目录名)，并以zlib对文件内容进行压缩存储。
+ tree                                    #git中保存目录信息的对象，存储在.git/objects目录下，存储了目录和文件的层次信息也就是说会包含blob对象和子tree对象，同样会以这些信息的sha-1为文件名。
+ commit                                  #git中保存一次提交信息的对象，一次提交可以认为是工作目录所有文件的快照(很多人以为commit保存的是改动，其实不是)，这个快照记录了一个tree信息(整个工作目录以及文件内容的信息)，提交者，提交信息，修改时间,父节点信息，然后同样以这些信息得出的sha-1为文件名保存在.git/objects目录下。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/graphs-and-git.png)

+ ref                                     #可以理解为commit的别名。sha-1不利于记忆，因此我们更多的是给commit加上别名，这部份信息存储在.git/refs下
+ branch                                  #branch是ref的一种，含意是分支，每当用户在一个分支上有新的提交时，git会自动帮你把该branch指向的commit信息更新。因此branch和svn中的branch相比要轻量级很多。不用考虑会有额外的开销。用户可以随时拉出一个分支去做自己想要做的工作，随时合并回主分支. 分支是用来将特性开发绝缘开来的。在你创建仓库的时候，master 是“默认的”分支。在其他分支上进行开发，完成后再将它们合并到主分支上。
+ tag                                     #tag也是ref的一种，含意是标签，同样是给一个commit起别名，但这个别名是不可变的,同时还支持添加额外的描述信息，并保存为专用的tag对象(这也是为什么有时候tag不能直接当commit用的原因，而要tag^0来表示)
+ HEAD                                    #记录当前目录checkout出来的那个commit点或者是ref的点，保存在 .git/HEAD 里，git log 的时候，第一个点就是HEAD.也是你当前工作的那个点。你的改动也都是基于这个点。


#### git中的几个区域

+ STASH                                   #git的五个存储区域之一，用来临时存储用户不想提交的内容，主要是将INDEX中的改动存到STASH中，这样用户就可以在INDEX区域开始新的工作。可以理解为将INDEX中的改动移动到STASH中，同样也有命令支持将STASH中的内容移动到WORKSPACE中.这个区域在开发过程中很实用。

+ WORKSPACE                               #git的五个存储区域之一，主要是用户还没有加入道INDEX区域中的改动，这部份改动还没有存入到.git中，如果要提交这部份改动需要先将他们加入到INDEX区域中。我们直接修改一个文件，或者创建删除一个文件，这些改动都是在WORKSPACE区域

+ LOCAL REPOSITORY                        #git的五个存储区域之一，指本地的git库,git commit可以理解为改动从INDEX区域提交到了LOCAL REPOSITORY。

+ INDEX                                   #git的五个存储区域之一，已经存到.git中，但还没有提交的改动，所谓提交就是把在INDEX中的内容对应tree，加上提交的描述和提交的作者等信息创建一个新的commit对象，并清空INDEX区域。git add 命令就是将WORKSPACE中的改动移动到INDEX中。这个区域也是git和其他版本控制系统最大的区别。下图就是workspace区域 Index区域 和 LOCAL REPOSITORY区域之间相互交互的方式。在Workspace修改，然后通过git add 加到 Index,再通过commit，将Index中的改动提交到LOCAL REPOSITORY中.  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/trees.png)


+ UPSTREAM REPOSITORY                     #git的五个存储区域之一，指远程的git库.我们会使用一个服务器去集中管理多个人的提交。这时就存在这样一个UPSTREAM REPOSITORY，git push可以理解为将改动存到UPSTREAM REPOSITORY区域


#### git中的操作
+ commit                                  #commit就是普通的提交。会在当前分支上增加一个新的点。
+ merge                                   #将两个分支的改动合并到一个点上.  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/branches.png)

+ rebase                                  #改变改动的次序,修改改动历史，让改动更清晰，更有意义。
+ push                                    #将本地新增的commit同步到远程分支上
+ fetch                                   #将远程分支的改动同步的本地的远程分支上，不改变本地分支
+ pull                                    #将远程分支的改动同步到本地分支上，如果本地分支有改动则自动merge
+ remote                                  #一般指服务器，用来存储提交，和其他用户协作。其内容就是你git库的备份。但一般用户没有修改其历史的权限，因此需要用户提交时注意自己所有修改的历史必需是还没有提交的remote的.远程一般在本地以远程分支出现，远程分支不能直接修改，需要我们检出一个本地分支，在进行修改。
+ 工作流                                   #你的本地仓库由 git 维护的三棵“树”组成。第一个是你的 工作目录，它持有实际文件；第二个是 暂存区（Index），它像个缓存区域，临时保存你的改动；最后是 HEAD，它指向你最后一次提交的结果
+ 相对引用                                 # 形如 HEAD^^ 或者 HEAD~2 ,指当前commit的上上个commit.这样不用去记忆长长的sha-1值

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

### git commit

一个简单的提交的例子:
+ 当前在master分支上  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_commit_1.png)

+ 做简单的改动，然后 `git commit` ，结果如下图所示，新增一个C2的commit ，而且master自动的指向这个新的点。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_commit_2.png)

```
# 提交INDEX中的改动，并指定提交信息
$ git commit -m "Your commit message"

# 提交INDEX中的改动到上一次改动中
$ git commit --amend

# 提交一个空的提交
$ git commit -m "Big-ass commit" --allow-empty
```

### git branch

查看分支相关信息，或者创建分支等.

一个创建分支，并提交新改动的例子:
+ 如下图，我们有一个master分支，指定C1,其中星号表示当前检出的分支是master  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_branch_1.png)

+ 执行 `git branch newImage master` , 创建新分支，结果如下  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_branch_2.png)

+ 执行 `git commit` ,我们会看到 master 向前走了一个点。这是因为我们检出的是master分支，因此提交也会往master分支提.  
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

### git checkout
将一个commit或者一个branch检出到工作目录。这样后续工作的提交就会提交在新检出的分支上。

下面是一个简单的例子:
+ 该git库，有两个分支，如图所示，检出在master分支上  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_checkout_1.png)

+ 执行 `git checkout newImage` ,然后再提交。结果如下图所示，新的提交在 newImage 分支上  
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
将其他分支的一个改动拿到另一个分支上。这个功能非常重要。几乎是CM的主要工作。

+ 下面是一个例子，有side 和 master 两个分支，现在将 side的部份改动通过cherry-pick的方式拿道master上  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_cherry_pick_1.png)

+ 执行 `git cherry-pick C2 C4` ,如下图，我们得到了 C2' 和 C4'两个新提交。由于git的commit是包含所有文件信息的快照，其实C2和C2'差别很大。他们唯一的关系是 diff C5..C2' 和 diff C1..C2内容相同.  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_cherry_pick_2.png)

首先我们知道每一个commit其实是包含所有文件的内容的，也可以理解为是完整的快照，cherry-pick的原理是将要拿的那个commit和那个commit的上一个commit进行diff，然后把diff再打到目标分支上。

+ 下图是一个cherry-pick详细流程的例子，这个例子要将C D E 提交cherry-pick 到 H后面。cherry-pick的内部流程第一步,就是比较 B..C 的改动。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-1.png)

+ 然后将B..C 的改动打到H后面，成为新的提交C'  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-2.png)

+ 比较得到 C..D 的改动  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-3.png)

+ 将 C..D 的改动打到 C'后面，成为 D'  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-4.png)

+ 比较得到 D..E 的改动  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-5.png)

+ 将 D..E 的改动打到 D'上，成为 E'  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-6.png)

+ 至此，`git cherry-pick C D E` 完成。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/cherry-pick-step-7.png)


### git clone
主要用来从远程库下载一个新的库到本地.

```
#通过http协议从远程下载一个git库，分支为默认的master
$ git clone https://...repo.git

# bare库是不带workspace的库，一般单纯用来存储改动，或者在本地做远程库的镜像
$ git clone https://...repo.git --bare
```

### git clean
清理workspace中自己的改动，比如代码被自己改乱了，想要重新开始

```
# 清理所有workspace下的改动
$ git clean -f -d

# 清理所有workspace下的改动，包含忽视的文件
$ git clean -f -d -x

# 指定清理的路径，可以很方便的去掉指定的一个目录或多个文件的新改动
$ git clean -f -d <Path>
```

### git fetch
从远程分支同步最新提交的本地的远程分支。

+ 左边是本地分支，o/master指origin/master.右边是远程分支，有两个新提交。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_fetch_1.png)

+ 现在执行 `git fetch` , 会将远程分支的新提交同步到o/master这个本地远程分支上，但并不会改动本地的master  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_fetch_2.png)

```
#下载最新远程的分支和标签
$ git fetch upstream

#下载gerrit上该库所有的change
$ git fetch origin '+refs/changes/*:refs/remotes/origin/changes/*'
```


### git diff
比较两个commit之间的差别。前面的参数是base,后面的参数是target.

一个常见的错误是想看连续的commit1 commit2 commit3三个提交一共改了哪些东西，会被错写成 git diff commit1..commit3,实际上应该是 git diff commit1^..commit3 ,因为你应该拿什么都没改的commit作为base.

```
#比较两个分支代码的差别
$ git diff branch_1 branch_2

# only show file name change
$ git diff --name-status branch_1 branch_2

# only show file name and modify numbers
$ git diff --stat branch_1 branch_2

$ git diff branch_1 branch_2

# find out modify files number
git --no-pager diff --name-status branch_1 branch_2 | grep -E  '^M' | wc -l

# find out file changes number
git diff --stat branch_1 branch_2 -- file_name  | head -1 | awk -F'|' '{print $2}' | awk '{print $1}'

```

### git format-patch
将commit存为特殊格式的patch文件,用git am可以再把这些patch拿进来

```
$ git format-patch commit1^..commit2
```

### git apply
将patch打进分支，但不提交

```
git apply xxx.patch
```

### git am
将patch打进分支，并直接提交

```
git am xxx.patch
```

### git grep
git提供的搜索工具,自动排除.git目录，并可以指定在INDEX或者具体的某个commit中进行搜索。

```
$ git grep aliases
$ git grep -e pattern --and -e anotherpattern
```

### git init
创建一个空的git库。空的git库，可以做很多事，比如像要同步远程的一个分支，就可以通过修改空库的配置文件，限定要同步的分支，和远程地址。

```
#创建一个新的git库
$ git init
```

### git merge
merge是git中团队协作的时候最常见的操作之一。比如两个人并行的在一个base上开发独立的新功能，那么在他们提交的时候就需要merge,再合到一起。下面是一个最简单的例子。

+ 当前主分支为master,我们在C1的时候拉出了一个bugFix的分支，单独解bug,提交了C2  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_merge_1.png)

+ 执行 `git merge bugFix` ,git 会自动把C2 C3的改动合到一起得到C4.并将master指向C4.这就是 merge 的过程。同时我们可以看出，使用merge的方式，bugFix这一分支以及内容都是被保留的。而且C4有了两个父节点。可以考虑一下 master^ 和 master^^ 分别指向谁。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_merge_2.png)

```
#将远程的master分支的改动合到当前分支中
$ git merge upstream/master
```

### git log
显示指定分支或提交相关的提交历史

```
# 查看提交信息
$ git log

# 查看格式更好的提交信息
$ git log --all --graph --pretty=format:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
```

### git mv
在git中移动一个文件或目录。

### git pull
将远程分支同步到本地的远程分支，并合并到本地分支上。

+ 如下图，左边实线的是本地库，o/master指本地远程分支，master为当前分支，有一个新的本地提交，右边虚线为远程库，远程master分支要比本地领先一个提交C3  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_pull_1.png)

+ 我们执行 `git pull` ,我们会将远程的master同步到本地的o/master上，然后本地的master再merge 分支 o/master, 结果如下图。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_pull_2.png)


```
# 下载远程分支，并合并到当前分支中
$ git pull origin

# 使用rebase的方式合并远程分支
$ git pull --rebase
```

### git push
将本地的改动同步到远程分支。

普通提交的例子。
+ 下图，左为本地库，右为远程库。本地库比远程库领先一个提交  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_push_1.png)

+ 执行 `git push` ,便自动将本地的C2同步到远程分支上了，结果如下。值得注意的时，如果远程分支有新提交，我们会提交失败。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_push_2.png)



我们也可以指定本地的一个分支名，推送到远端的一个分支名。以便更精确的推送。 下面就是这样的例子
+ 下图，左为本地库，右为远程库。本地库比远程库领先两个提交。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_push_clearly_1.png)

+ 执行 `git push origin foo^:master` ,可以精准的将自己的一部分提交，同步到远程分支  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_push_clearly_2.png)


在远端创建新分支的例子
+ 下图种，左为本地库，右为远程库。本地领先一个提交。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_create_branch.png)

+ 执行 `git push origin master:newBranch`,指定了要推送的分支和目标分支。由于远程没有该目标分支，于是创建了这个新的远程分支。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_create_branch_2.png)


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
rebase是一个修改历史的命令，是将另一个分支作为起点，将自己分支上的改动cherry-pick到新的起点上

+ 如下图，有两个分支，一个master,一个bugFix。假如我们需要继续在bugFix上工作，而且master上新的C2改动对我们也很重要，需要拿进来，这个时候就可以用rebase.  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_1.png)

+ 执行 `git rebase master bugFix`,git会先找到公共的C1,然后将C1..bugFix之间的所有提交cherry-pick到master后面。结果如下:  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_2.png)

+ 如果两个分支在一条线上，则rebase的过程会很简单。如果我们就在刚刚的库上继续操作  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_3.png)

+ 执行 `git rebase bugFix master`,master会直接移动到bugFix指向的点，结果如图:  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_4.png)

+ rebase的另一个用途是修改提交的历史，比如想要去掉历史的某个提交,或者改变提交的词序。初始状态如下。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_i_1.png)

+ 执行 `git rebase -i` ,并从编辑器中重新调整提交的词序。 git 会自动根据新的词序cherry-pick之前的提交并生成新的提交。结果如下  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_rebase_i_2.png)

```
$ git rebase master
$ git rebase -i
```
### git describe
显示离得最近的一个tag

### git reset
一般有两个用途，一个是清理目录中的改动，一个是回退到以前的一个点。

+ 下图是一个普通的库，当前master在C2这个点上  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_reset_1.png)

+ 执行 `git reset --hard C1`,可以回退到C1这个点。结果如下图所示。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_reset_2.png)

```
# 清空在INDEX和WORKSPACE的改动
$ git reset --hard
```

### git revert
revert主要用来冲掉以前的一个错误提交。有这个命令主要是因为，git有远程库，这个远程库可能是集中式的，如果你的提交已经提交到了远程库，这时候再用git rebase或者reset修改历史来解决，就需要所有用户修改历史，这个代价太大了。因此有了git revert,它会生成一个包含目标提交相反的新提交。这样对其他用户影响较小。

+ 下图演示一般revert的效果。我们的C2提交是错误的，并已经同步到远程分支，因此不适合通过rebase的方式修改  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_revert_1.png)

+ 执行 `git revert C2`,生成了新的 C2' 提交，冲掉之前 C2 的改动，结果如下  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_revert_2.png)

### git rm
从 git 中删除一个文件。

```
#从INDEX中删除一个文件
$ git rm --cached file.txt
#从INDEX删除一个目录的文件
$ git rm -r --cached ./

# 将WORKSPACE中删除的文件，在INDEX中删除
$ git rm $(git ls-files -d)
```

### git show
显示某个提交的具体信息

```
#查看一个commit的信息以及改动
$ git show 83fb499

#查看某个commit时，某文件当时的内容
$ git show 83fb499:path/fo/file.ext
```

### git status
显示当前工作目录的状态，比如改动了哪些文件，改了多少行

```
#查看当前INDEX和WORKSPACE的状态
$ git status
#以简洁的形式显示当前INDEX和WORKSPACE的状态
$ git status -sb
```

### git stash
暂存自己在工作目录的改动

```
# 暂存改动
$ git stash
# 取出改动
$ git stash pop
# 列出所有暂存的改动
$ git stash list
```

### git tag
给某个commit打上标签。标签一般来说是不可变的，用来记录一些项目中关键的节点。

+ 比如下图中的C1点是一个测试完全通过的点，我们需要记录这个点，我们可以记住C1这个sha-1号，但不容易记忆，于是我们可以打上tag.  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_tag.png)

+ 执行 `git tag v1 C1`, 就在 C1 上打上了tag,示意图如下  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_tag_2.png)



### git config
配置git的配置文件，配置文件分为用户配置，库配置。用户配置在 ~/.gitconfig 中，库配置在 .git/config中，库配置覆盖用户配置。

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
使用指定的merge工具处理merge.

### git reflog
显示最近操作的ref的日志，主要应用的场景时，误删了某个分支，又忘记了之前那个分支的commit信息。在git gc以前都是可以通过reflog找到相关信息，查到commit号的，然后就可以利用commit号重新建误删的分支了。

### git remote
git remote主要用来显示远程分支的信息，以及添加或改动远程分支信息

+ 比如我们有一个本地库，我们想要用一个集中的代码服务器帮忙管理，比如github.于是我们就可以在github上新建一个库  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_remote_1.png)

+ 执行 `git remote add origin git://xxxxx.git;git push` ,结果如下,虚线为远程分支。  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_remote_2.png)

+ 我们可以看到，在关联了远程分支以后，本地会自动多出一个名为 origin/master (o/master)的分支，这就是本地远程分支，这个分支不能被检出，只会在同步远程分支的时候被改变.  
![](https://github.com/qinshulei/git-guide-for-cm/raw/master/images/git_remote_3.png) 

+ 执行 `git checkout o/master;echo " " > edit.txt;git commit`,结果如下，如上所说，o/master不变。  
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
查看文件中每一行是哪个提交谁改动的,有利于根据改动的内容找到负责的人

```
# 查看文件中每一行是哪个提交谁改动的
$ git blame filename
```

### git fsck
检察git数据库中objects的完整性

### git gc
所谓gc就是垃圾回收，写过java的应该都有了解，分配了内存不用自己维护，而让虚拟机自己管理，虚拟机会定期清理不用的内存。同理git的提交，会存到.git目录下，git不会删除任何提交，而是在gc的时候才自动判断哪些commit已经用不到了，然后删除掉。清理不能被分支和标签引用到的commit(每一个commit都有一个或多个父commit,形成有向的图，当我们删除一个分支时，分支指向的commit不会被直接删除，而是等到gc时才开始删除).

### git prune
一般直接运行git gc就可以了，git gc会调用git prune.

### git rerere
打开后，会记录同一个文件解冲突的方法，再遇到该文件相同的冲突时，会自动merge.适合经常做rebase的用户

### git name-rev
查看某个commit相关的ref名字，可以用来查询一个commit再哪些分支上

```
# 查看一个提交所在的分支
$ git name-rev 97374dab58cffa8a7d81881377b386dc42c0dcba
```

### git show-ref
显示所有branch和tag的信息。包括gerrit的提交其实也是一种ref, 形如ref/changes/xxxx

```
# 查看所有ref
$ git show-ref

# 删除除HEAD和master以外的所有ref,包括分支和标签
$ git show-ref | awk '{ print $2 }' | sed '/^HEAD$/d' | sed '/master$/d' | xargs -n 1 git update-ref -d --
```

### git archive
用来导出git库

```
# 导出库的内容，不包括.git, tar.gz格式
$ git archive master | tar -x -C /somewhere/else

# 导出库的内容，不包括.git, tar.bz2格式
$ git archive master | bzip2 >source-tree.tar.bz2

# 导出库的内容，不包括.git, zip格式
$ git archive --format zip --output /full/path/to/zipfile.zip master
```

### git daemon
一个简单的git server.

### git http-backend
一个简单的git http server

### gitk
一个常用的git GUI工具，如果不习惯命令行操作，可以使用这个工具代替。但如果是目标能够写脚本的人，还是掌握命令行操作比较重要。

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
+ [Pro Git](http://git-scm.com/book/zh/v2) Pro Git 官方推荐的书，中文,五星推荐,系统学习git必看
+ [git cheatsheet](http://ndpsoftware.com/git-cheatsheet.html) 通过交互式的界面显示命令的cheatsheet,非常方便查询命令，可以用作日常命令查询备忘，五星推荐
+ [Deep Dive into Git](https://www.youtube.com/watch?v=dBSHLb1B8sw) 视频讲解git的内部原理，五星推荐
+ [Think Like (a) Git](http://think-like-a-git.net/) 用图论讲解git,git cherry-pick,以及git rebase都讲的不错，适合进一步提高理解
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
