---
layout: post
title: "决定转战Octopress"
date: 2014-01-10 17:26
comments: true
categories: [tools]
tags: octopress
---
最近看了很多牛人的博客,很有感触和收获! 牛人们都不是一开始就是牛人，都是一朝一夕的积累起来的，他们都建议自己写博客，这对自己能力提升有很大的帮助。之前我都是闲麻烦，一直在博客园写博客，博客也是简单的记录一些东西，质量相当不高！ 所以我打算要建设一个属于自己的博客，在这里认真的记录一些属于自己的心得和积累。我想对自己是有帮助的。之前搭建好了octopress，当时还折腾了很久，终于能够使用一些基本功能了。 但是搭建好后一直就没有用了，直到现在我决定开始在这上面写东西。又开始重新研究，这篇文章记录一下整个过程，走了一些弯路，但是还是有一定的收获! <!-- more --> 

###一、安装

安装可参照 <a href="http://octopress.org/docs/setup/">官方文档</a>，原文是英文。 不想读英文的还可以参照<a href="http://aiku.me/bar/10622861">从零开始在github上安装octopress</a>这篇博客，讲的很详细。
安装中的一些注意事项:

  * Octopress要求ruby的版本至少为1.9.3,安装ruby时，如果你的Mac使用的是10.9, 那么是满足要求的，不必再安装rvm来控制ruby版本。可在终端输入<code>ruby --version</code>查看版本是否满足要求。
  * 在 <code>gem bundler install</code>后，bundler会自动安装好所需要的一系列插件，但是存在一个问题，bundler安装的rake是0.9.2.2，但是10.9的系统下，当你使用rake命令时会有以下错误
  
  {% img /images/install_octopress_rake_error.png %}
  
原来这个是要告诉你在__rake__之前加上__bundle exec__这两个词，害我折腾了半天，加上之后则可以成功运行了。

但是每次执行__rake__时都要加上这玩意，麻烦！干脆用别名把常用的命令替代吧！

	alias rg='bundle exec rake generate'
	alias rp='bundle exec rake preview'
	alias rd='bundle exec rake deploy'
	alias or='bundle exec rake'
保存为.bashrc 存到用户根目录下，以后就永远生效了（记得要在根目录的.bash_profiled文件里面加上<code>source ~/.bashrc</code> 这行代码，没有这个文件的话就手动创建一个）。 

###二、用github展示生成的页面和保管资源代码

在github上新建一个代码库保管自己的博客资源，这个过程推荐的两篇文章里都有，就不在说了。值得注意的是，你的博客代码库不仅保管了生成的页面还保管了你的博客资源，当你deploy时会把生成的文章push到master发布，而博客资源则保管到source分支。source分支生成的_deploy目录在gitignore里，不会提交到source分支里。之前一直以为只会把生成的页面保管到github上，还一直用网盘保管博客资源，太二逼了！ 看来对git的分支操作是太生疏了！

###三、写博客、生成本地博客、预览


	rake new_post[’your_post_title’] //由于建立了别名，可以用or代替rake

命令可以新建一篇文章，生成的目录在代码库里的__source/_posts__里，现在你就可以用vi或者其他编辑器打开编辑了。文件是markdown的语法，markdown语法是兼容html的，具体语法可参照[这里](http://wowubuntu.com/markdown/#philosophy)。 我比较推荐去看一些别人博客的markdown文件,这样能很快掌握什么语句会达到什么功能。推荐一个牛人:[唐巧](http://blog.devtang.com/)的博客,他文章托管的[地址](https://github.com/tangqiaoboy/tangqiaoboy.github.com),可以做下参考。

由于绑定了别名现在使用 <code>__rg__</code> 命令这可生成博客，<code>__rp__</code>命令则可预览，浏览器输入 http://127.0.0.1:4000 则可预览，safari很多情况下不能预览，不知道为什么，chrome则可以。在写文章时，还可以编写边刷新浏览器实时查看效果，不用再rake generate。

###四、自定义博客的UI

  主要说一下更换主题，[这里](https://github.com/imathis/octopress/wiki/3rd-Party-Octopress-Themes)是官方wiki推荐的第三方主题，还可以预览效果。大致的步骤是 git clone 到自己博客代码库根目录的__.theme__目录下，然后 __rake install[‘your_theme_name’]__ 安装主题即可，有些主题安装要复杂一两个步骤，具体可以查看它的readme文件。
  其他界面定制还有插件使用，官方的[wiki](https://github.com/imathis/octopress/wiki)上都有说明，[前一篇文章](/blog/2013/05/14/octopress-pei-zhi/)也推荐了相关的一篇文章，很不错。 另外我自己也去掉了一下不适用的东西，比如那个3d标签云，看着倒是很酷但是不能提供很快捷的点击操作。如遇到问题，也可取别人的博客资源里查看一下别人怎么配置的，很有用。

###总结
算是第一篇正式的文章吧，就写到这里了,关于octopress我自己也还有很多东西要折腾才能搞的更清楚，以后还要坚持的多写一些东西！
