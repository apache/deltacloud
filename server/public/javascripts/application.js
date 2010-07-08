// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {

  $("a.delete").click(function(e) {
    var original_url = $(this).attr('href')
    $.ajax({
      url : original_url,
      type : 'DELETE',
      cache : false,
      success: function(data) {
        window.location = original_url.replace(/\/([\w_-]+)$/i, '')
      }
    })
    return false;
  })

  $("a.post").click(function(e) {
    var original_url = $(this).attr('href')
    $.ajax({
      url : original_url,
      type : 'POST',
      dataType : 'xml',
      success: function(data) {
        window.location = original_url.replace(/\/([\w_-]+)$/i, '')
      }
    })
    return false;
  })

})
