module NewsHelper
  def all_news
    [
      %Q(<a href="http://watzmann.net/blog/2010/10/deltacloud-at-apachecon.html">Deltacloud meetup</a> at ApacheCon on 11/4 at 8pm),
      %Q(Deltacloud Core <a href="http://watzmann.net/blog/2010/07/deltacloud-apache-incubator.html">moved to Apache Incubator</a>.),
      %Q(Deltacloud now <a href="./drivers.html#providers">supports GoGrid</a>!),
      %Q(We've introduced <a href="./api.html#h4_1">Hardware Profiles</a> to the API.),
      %Q(Deltacloud <a href="http://press.redhat.com/2009/09/03/introducing-deltacloud/">announced</a> at 2009 Red Hat Summit!),
    ]
  end

end

Webby::Helpers.register(NewsHelper)
