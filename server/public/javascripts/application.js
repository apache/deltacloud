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

  if ($('select#list_instances').length) {
    $('select#list_instances').html("<option>Loading instances...</option>");
    $.getJSON("/api/instances?state=RUNNING&format=json",
      function(data){
        $('select#list_instances').empty();
        $.each(data.instances, function(i,item){
          $('select#list_instances').append('<option value="'+item.id+'">'+item.id+'</option>');
        });
      }
    );
  }

})
