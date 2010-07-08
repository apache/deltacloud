# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def bread_crumb
    s = "<ul class='breadcrumb'><li class='first'><a href='/'>&#948</a></li>"
    url = request.path.split('?')  #remove extra query string parameters
    levels = url[0].split('/') #break up url into different levels
    levels.each_with_index do |level, index|
      unless level.blank?
        if index == levels.size-1 ||
           (level == levels[levels.size-2] && levels[levels.size-1].to_i > 0)
          s += "<li class='subsequent'>#{level.gsub(/_/, ' ')}</li>\n" unless level.to_i > 0
        else
            link = "/"
            i = 1
            while i <= index
              link += "#{levels[i]}/"
              i+=1
            end
            s += "<li class='subsequent'><a href=\"#{link}\">#{level.gsub(/_/, ' ')}</a></li>\n"
        end
      end
    end
    s+="</ul>"
  end
end
