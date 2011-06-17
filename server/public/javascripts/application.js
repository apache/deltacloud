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

var addresses = 0;
var groups = 0;
function make_fields(type)
{
  form = document.getElementById("new_rule_form")
  button = document.getElementById("submit_button")
  if(type == "address")
  {
    name = "ip_address" + eval(++addresses)
    create_rule_source_field(name, "Address " + eval(addresses) + " [use CIDR notation 0.0.0.0/0]", form, button)
  }
  else if(type == "group")
  {
    name = "group" + eval(++groups)
    create_rule_source_field(name, "Name of group " + eval(groups), form, button)
    name = "group" + eval(groups) + "owner"
    create_rule_source_field(name, "Group " + eval(groups) + " owner (required)", form, button)
  }
}

function create_rule_source_field(name, label, form, button)
{
    element = document.createElement("INPUT")
    element.type = "input"
    element.size = 35
    element.name = name
    text = document.createTextNode(label)
    form.insertBefore(element, button)
    form.insertBefore(text, element)
    form.insertBefore(document.createElement('BR'), element)
    form.insertBefore(document.createElement('BR'), button)
    form.insertBefore(document.createElement('BR'), button)
    form.insertBefore(document.createElement('BR'), button)
}
