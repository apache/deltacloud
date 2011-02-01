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

function more_fields()
{
	//increment the hidden input that captures how many meta_data are passed
	var meta_params = document.getElementsByName('meta_params')
    current_number_params = eval(meta_params[0].value)+1
	meta_params[0].value = current_number_params
    var new_meta = document.getElementById('metadata_holder').cloneNode(true);
    new_meta.id = 'metadata_holder' + current_number_params;
    new_meta.style.display = 'block';
    var nodes = new_meta.childNodes;
    for (var i=0;i < nodes.length;i++) {
        var theName = nodes[i].name;
        if (theName)
          nodes[i].name = theName + current_number_params;
    }
    var insertHere = document.getElementById('metadata_holder');
    insertHere.parentNode.insertBefore(new_meta,insertHere);
}

function less_fields()
{
    var meta_params = document.getElementsByName('meta_params')
	current_val = eval(meta_params[0].value)
	if (current_val == 0)
	{
		return;
	}
	else
	{
		var theDiv = document.getElementById('metadata_holder'+current_val)
		theDiv.parentNode.removeChild(theDiv)
		meta_params[0].value = eval(current_val)-1
	}
}
