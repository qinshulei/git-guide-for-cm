#!/bin/bash
# sudo apt-get install -y pandoc
sed "s#https://github.com/qinshulei/git-guide-for-cm/raw/master/##g" README.md | pandoc -o ~/git-guid-for-cm.docx

# another way is use google docs to convert.
