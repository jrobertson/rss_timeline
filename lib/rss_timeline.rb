#!/usr/bin/env ruby

# file: rss_timeline.rb

require 'simple-rss'
require 'open-uri'
require 'rss_creator'
require 'rxfreadwrite'


class RSStimeline
  include RXFReadWriteModule

  attr_accessor :rssfile

  def initialize(feeds=[], rssfile: 'timeline.rss', xslt: nil,
                 filepath: '.', debug: false, target_filepath: nil)

    @source_feeds, @debug, @rssfile, @newupdate = feeds, debug, rssfile, false
    @target_filepath = target_filepath

    puts 'inside initialize' if @debug

    @filepath = File.join(filepath, 'rss_timeline')
    @cache_filepath = File.join(@filepath, 'cache')

    # create a cache directory if it doesn't already exist
    FileX.mkdir_p @cache_filepath

    if FileX.exists? rssfile then
      @timeline = RSScreator.new rssfile
    else

      @timeline = RSScreator.new
      self.title = 'My RSStimeline feed'
      self.description = 'Generated using the RSStimeline gem'

    end

    @timeline.xslt = xslt if xslt
    puts '@timeline.xslt : ' + @timeline.xslt.inspect if @debug

  end

  def update()

    # fetch the feeds from the web
    feeds = @source_feeds.map do |feed|
      #force_encoding('UTF-8')
      [feed, SimpleRSS.parse(URI.open(feed).read.force_encoding('UTF-8'))]
    end

    # check for each feed from the cache.
    # if the feed is in the cache, compare the 2 to find any new items.
    # New items should be added to the main timeline RSS feed

    updated = false

    feeds.each do |feed, rss|

      rssfile = File.join(@cache_filepath, feed[6..-1].gsub(/\W+/,'').\
                                             reverse.slice(0,40).reverse)

      if File.exists? rssfile then

        rss_cache = SimpleRSS.parse FileX.read(rssfile).force_encoding('UTF-8')

        fresh, old = [rss.items, rss_cache.items].map do |feed|
          feed.clone.each {|x| x.delete :guid }
        end


        new_items = fresh - old

        if @debug then
          puts 'fresh: ' + fresh.inspect
          puts 'old: ' + old.inspect
          puts 'new_items: ' + new_items.inspect
        end

        new_rss_items = new_items.map do |x|
          rss.items.find {|y| y[:title] == x[:title]}
        end

        new_rss_items.reverse.each {|item| add_new item}

        if new_rss_items.any? then
          puts 'new_rss_items: ' + new_rss_items.inspect if @debug
          updated = true
          FileX.write rssfile, rss.source
        end

      else

        updated = true
        add_new rss.items.first
        FileX.write rssfile, rss.source

      end
    end

    save() if updated

  end

  def description()
    @timeline.description
  end

  def description=(val)
    @timeline.description = val
  end

  def link(val)
    @timeline.link
  end

  def link=(val)
    @timeline = val
  end

  def title()
    @timeline.title
  end

  def title=(val)
    @timeline.title = val
  end

  protected

  def on_new_item(item)
    # you can override this method to create your
    #                                  own notifier, callback, or webhook
  end

  def on_update()
    # you can override this method to create your
    #                                  own notifier, callback, or webhook
  end

  private

  def add_new(item)

    puts 'inside add_new: ' + item.inspect if @debug

    @timeline.add item: new_item(item), id: nil
    @newupdate = true
    on_new_item(item)

  end

  def new_item(x)

    h = {
      title: x[:title],
      link: x[:link],
      description: x[:description],
      date: x[:date] || Time.now.strftime("%a, %d %b %Y %H:%M:%S %z")
    }

    puts 'inside new_item: ' + h.inspect if @debug

    h

  end

  def save()

    @newupdate = false

    @timeline.save File.join(@filepath, @rssfile)
    @timeline.save File.join(@target_filepath, @rssfile) if @target_filepath
    on_update()

  end

end
