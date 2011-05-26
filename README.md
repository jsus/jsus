What is it?
=============

Ruby implementation of javascript packager / dependency resolver.

Why?
====

As a javascript programmer, you often need to split your code into
multiple files. When you have 50+ different modules / libraries, you
need some way to resolve complex dependencies and package all you need
and nil you don't. Jsus is an utility that allows you to do just that: 
package your libraries into one piece with all dependencies included.

Features
========

* Jsus works with mootools-style packages. That means you specify a
  package.yml / package.json file with package structure for every
  library/bigger module you have. Source files should also have special
  headers denoting their requirements and what they provide.
* Jsus automatically resolves dependencies, so you don't have to worry about
  order issues or anything else.
* Jsus allows you to make "extensions". Extension is a monkey-patch you can 
  apply to any other library. Because sometimes you want to make project-specific
  change to a library you don't have control over and you want to be able to
  update this library without applying manual patches from their source.
* Jsus uses [murdoc](https://github.com/markiz/murdoc) for doccu style docs 
  generation.
* Jsus generates special json files denoting source and resulting project
  structure which can be useful for later introspection.
* Jsus can also generate a special js file with loader for your dependencies,
  so that you don't need to repackage everything during development cycle.
  
Examples
========

* For simple examples, take a look at: https://github.com/markiz/jsus-examples
* You can try it yourself on mootools-core:
  * Get mootools-core from https://github.com/mootools/mootools-core
  * `cd mootools-core`
  * `jsus . Output`
  * Look at what Output directory contains

Use with Rails
==============
To play with jsus and rails you need just:
 
    rails new jsus_test
    cd jsus_test
    mkdir -p public/javascripts/Source
    git clone git://github.com/Inviz/mootools-ckeditor.git public/javascripts/Source

Add in Gemfile:
`gem 'jsus'`

So you can use it like http://localhost:3000/javascripts/jsus/include/CKEditor.js

You can override default settings creating intializer "config/initializers/jsus.rb"

    Jsus::Middleware.settings = {
      :cache         => true,
      :cache_path    => "#{Rails.root}/public/javascripts/jsus/require",
      :packages_dir  => "#{Rails.root}/public/javascripts/Source",
      :cache_pool    => false,
      :includes_root => "#{Rails.root}/public/javascripts/Source"
    }

Plans
=====

These are rather long-term, for when I get to have time and mood to do those:
* Rails integration
* npm packages support

NB:
* I don't have any particular roadmap or plans for more features
* However, I am open for any suggestions
  * Bonus points for suggestions with pull-requests


License
=======

Public Domain, details in UNLICENSE file.
