#!/usr/bin/env ruby

# file: rss_timeline.rb

require 'simple-rss'
require 'open-uri'
require 'fileutils'
require 'rss_creator'


class RSStimeline
  
  attr_accessor :rssfile

  def initialize(feeds=[], rssfile: 'timeline.rss')

    @source_feeds = feeds

    # create a cache directory if it doesn't alread exist
    FileUtils.mkdir_p 'cache'

    if File.exists? rssfile then
      @timeline = RSScreator.new rssfile
    else
      @timeline = RSScreator.new
      @timeline.title = @title || 'My RSStimeline feed'
      @timeline.description = @description || \
                                'Generated using the RSStimeline gem'
    end
    
    @rssfile = rssfile
    @newupdate = false

  end

  def update()

    # fetch the feeds from the web
    feeds = @source_feeds.map {|feed| [feed, SimpleRSS.parse(open(feed))] }

    # check for each feed from the cache.
    # if the feed is in the cache, compare the 2 to find any new items.
    # New items should be added to the main timeline RSS feed

    feeds.each do |feed, rss|

      rssfile = File.join('cache', feed[6..-1].gsub(/\W+/,'').\
                                             reverse.slice(0,40).reverse)
      
      if File.exists? rssfile then

        rss_cache = SimpleRSS.parse File.read(rssfile)
        new_rss_items = rss.items - rss_cache.items        
        new_rss_items.each {|item| add_new item}
        
      else

        add_new rss.items.first
        File.write rssfile, rss.source
        
      end
    end
    
    if @newupdate then
      on_update()
      @newupdate = false
    end
    
    @timeline.save @rssfile    
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
    
    @timeline.add new_item(item)
    @newupdate = true
    on_new_item(item)
    
  end
  
  def new_item(x)
    
    {
      title: x[:title], 
      link: x[:link], 
      description: x[:description], 
      date: x[:date] || Time.now.strftime("%a, %d %b %Y %H:%M:%S %z")
    }
    
  end
  
end
