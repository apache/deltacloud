module NewsHelper
  def all_news
    [
      %Q(<a href="roadmap.html">Roadmap</a> posted.),
      %Q(<a href="http://watzmann.net/blog/2010/10/deltacloud-at-apachecon.html">Deltacloud meetup</a> at ApacheCon on 11/4 at 8pm.),
      %Q(Deltacloud Core <a href="http://watzmann.net/blog/2010/07/deltacloud-apache-incubator.html">moved to Apache Incubator</a>.),
      %Q(Deltacloud now <a href="./drivers.html#providers">supports GoGrid</a>!)
    ]
  end

end

Webby::Helpers.register(NewsHelper)
