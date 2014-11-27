# Change Agent

*A Git-backed key-value store, for tracking changes to documents and other files over time.*

[![Gem Version](https://badge.fury.io/rb/change_agent.svg)](http://badge.fury.io/rb/change_agent) [![Build Status](https://travis-ci.org/benbalter/change_agent.svg)](https://travis-ci.org/benbalter/change_agent)

### A git-backed key value store sounds like a terrible idea. Why would you do that?

Let's say you're building a scraper to see when Members of Congress post press releases to their websites and to track how those press releases change over time. You could build a purpose-built application, store each revision in a database, and then build an interface to view all the known press releases and compare their history. Stop the insanity!

But wait. What if I told you you could just commit each press release to Git, and let Git/GitHub do the heavy lifting. Without writing a single line of HTML you can browse all the press releases, see when they were changed, diff exactly how they were changed, and you've got hosting baked in.

Having built the first app more times then I'd like to admit, I thought I'd make a Gem to facilitate building lightweight apps that use Git to track changes to scraped documents (or whatever you want, really).

Want to see it in action? Check out [this lightweight demo](https://github.com/benbalter/change_agent_demo), scrapping the White House RSS feed.

## Okay, I'm sold. How do I use it?

ChangeAgent writes values to the file system based on a given key, and immediately commits the file to Git, providing you with both a snapshot and a timestamp for every change.

### Basic usage

```ruby
change_agent = ChangeAgent.init "path/to/repo"
=> #<ChangeAgent::Client repo="path/to/repo">

change_agent.set "foo", "bar"
=> #<ChangeAgent::Document key="foo">

change_agent.get "foo"
=> "bar"
```

### Namespaced usage

Keys (files) are intended to be namespaced when logically grouped. In the above example, if you were storing congressional press releases, you might store Rep. Balter's Nov 26th press release on puppies as "balter/2014/11/26/puppies.html", or just "balter/2014-11-26-puppies.txt" or even just "balter/puppies".

```ruby
change_agent.set "foo/bar", "baz"
=> #<ChangeAgent::Document key="foo">

change_agent.get "foo/bar"
=> "baz"
```

It's really up to you, but you'll get performance and usability bumps the more you namespace. I'd recommend thinking about what you want the Git repo to look like when browse, and work backwards from there.

### Cloning an existing repo / datastore

```ruby
repo = "https://github.com/benbalter/change_agent_demo"
directory = "data"
change_agent = ChangeAgent::Client.new(directory, repo)

change_agent.get("foo")
=> "bar"
```

### Pushing and pulling

Ready to push your Git repo to a server? Assuming you've already got a remote set up, it's as simple as

```ruby
# add a remote (if there's not already one from the clone)
change_agent.add_remote "origin", "https://github.com/benbalter/change_agent_demo"

# pull in the latest data
change_agent.pull

# push the data
change_agent.push

# do both
change_agent.sync
```

## Project status

Initial proof of concept

## Installation

Add this line to your application's Gemfile:

gem 'change_agent'

And then execute:

$ bundle

Or install it yourself as:

$ gem install change_agent

## Contributing

1. Fork it ( https://github.com/[my-github-username]/change_agent/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
