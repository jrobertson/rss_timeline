# Introducing the RSS_timeline gem

    require 'rss_timeline' 

    feeds = [
      'http://feeds.bbci.co.uk/news/rss.xml?edition=uk',
      'http://rss.slashdot.org/Slashdot/slashdot'
    ]

    timeline = RSStimeline.new feeds
    timeline.update

The above example would fetch the latest RSS feed items from BBC News and Slashot, and would save them to a file called *timeline.rss*. It can identify new items by comparing the feed with items in the cache which is a file directory containing the RSS files. 

# Resources

* rss_timeline https://rubygems.org/gems/rss_timeline

rss_timeline gem rss aggregator timeline
