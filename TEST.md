# 测试
## 问题
+ [rank 1] 如何把一个空目录转化为git库
git init
+ [rank 1] 如何设置全局提交者邮箱和名字，这对于提交非常重要，和身份验证关系密切
git config --global user.email
+ [rank 1] 现在git目录中有一个名为 `README` 的文件，如何将它添加到git的暂存区
git add README
+ [rank 1] 现在 `README` 在暂存区，如何将它提交
git commit
+ [rank 1] 如何clone这个库 https://github.com/Gazler/cloneme
git clone https://github.com/Gazler/cloneme
+ [rank 1] 如何clone这个库 https://github.com/Gazler/cloneme 到名为 my_cloned_repo 的目录\
git clone https://github.com/Gazler/cloneme my_cloned_repo
+ [rank 1] 假如我们使用vim编辑文件，然后vim会生成 .swp 临时文件，如何让git库忽略这一类型的文件呢
echo '*.swp' >>.gitignore
+ [rank 1] 现在我们的目录种有很多*.a的文件，我们想要git库忽略这些文件除了lib.a，要怎么做呢
echo '*.a' >> .gitignore
echo '!lib.a' >> .gitignore
+ [rank 1] 现在有一个git库，如何察看哪个文件没有在git库中
```
$ git status
On branch master

Initial commit

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

	new file:   Guardfile
	new file:   README
	new file:   config.rb
	new file:   deploy.rb
	new file:   setup.rb

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	database.yml
```
显然是 database.yml
+ [rank 1] 当前git库的状态如下，几个文件会被提交
```
$ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	new file:   rubyfile1.rb
	modified:   rubyfile4.rb

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   rubyfile5.rb

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	rubyfile6.rb
	rubyfile7.rb
```
显然是两个
+ [rank 2] 我们从git的工作目录删除了一个文件，但没有从git库中删除它，请问是哪个文件,然后请删除它
```
$ git status
On branch master
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	deleted:    deleteme.rb

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	rubyfile6.rb
```
显然是deleteme.rb
git rm deleteme.rb

+ [rank 2] 我们不小心多添加了一个文件到暂存区，请从git删除它，但不要在文件系统删除它
```
$ git status
On branch master

Initial commit

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

	new file:   deleteme.rb

```
git rm --cached deleteme.rb

+ [rank 2] 你作了一些改动，但还没有完成，你想要暂存它们，但不提交，请问怎么做。
git stash

+ [rank 2] 我们有一个文件 `oldfile.txt` ,我们现在要将它改名为 `newfile.txt` ,并提到暂存区
git mv oldfile.txt newfile.txt

+ [rank 2] 我们有一个git库，里面放了一些html文件，现在我们需要重新调整目录结构，将这些html放到src的子目录下
mkdir src
git mv *.html src

+ [rank 2] 如何查看最后一次提交的hash值
git --no-pager log --oneline -1

+ [rank 2] 给当前HEAD打上名为 `new_tag` 的tag
git tag new_tag HEAD

+ [rank 2] 我们有一个名为 tag_to_be_pushed 的 tag,如何将它推送到远程库中
git push origin tag_to_be_pushed:refs/tags/tag_to_be_pushed

+ [rank 2] 我们刚刚提交了 `README` 文件，但是我们忘了同时提交 `forgotten_file.rb` 文件，请提交该文件到`README` 的那次提交中。
git add -A
git commit --amend

+ [rank 2] 提交一个明天的提交，就是指定提交的日期
date -R
git commit --date="Thu, 15 Apr 2016 11:49:03 +0800"

+ [rank 2] 修改了两个文件，to_commit_first.rb to_commit_second.rb，打算分两次提交，但已经都添加到暂存区了，请使用reset将to_commit_second.rb从暂存区移出。
git reset to_commit_second.rb




