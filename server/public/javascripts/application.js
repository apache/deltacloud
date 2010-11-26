// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {

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
