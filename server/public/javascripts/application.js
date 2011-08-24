// Licensed to the Apache Software Foundation (ASF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.  The
// ASF licenses this file to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance with the
// License.  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//

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

// NOTE: This code was copied from http://phpjs.org/functions/base64_encode:358
// phpjs.org license it under the MIT and GPL licenses

function encodeb64 () {
  // Encodes string using MIME base64 algorithm
  //
  // version: 1107.2516
  // discuss at: http://phpjs.org/functions/base64_encode    // +   original by: Tyler Akins (http://rumkin.com)
  // +   improved by: Bayron Guevara
  // +   improved by: Thunder.m
  // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  // +   bugfixed by: Pellentesque Malesuada    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  // -    depends on: utf8_encode
  // *     example 1: base64_encode('Kevin van Zonneveld');
  // *     returns 1: 'S2V2aW4gdmFuIFpvbm5ldmVsZA=='
  // mozilla has this native    // - but breaks in 2.0.0.12!
  //if (typeof this.window['atob'] == 'function') {
  //    return atob(data);
  //}
  var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";    var o1, o2, o3, h1, h2, h3, h4, bits, i = 0,
      ac = 0,
      enc = "",
      tmp_arr = [];

  var data = $("textarea#user_data").attr('value');

  do { // pack three octets into four hexets
    o1 = data.charCodeAt(i++);
    o2 = data.charCodeAt(i++);
    o3 = data.charCodeAt(i++);
    bits = o1 << 16 | o2 << 8 | o3;

    h1 = bits >> 18 & 0x3f;
    h2 = bits >> 12 & 0x3f;        h3 = bits >> 6 & 0x3f;
    h4 = bits & 0x3f;

    // use hexets to index into b64, and append result to encoded string
    tmp_arr[ac++] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);    } while (i < data.length);

    enc = tmp_arr.join('');

    switch (data.length % 3) {    case 1:
      enc = enc.slice(0, -2) + '==';
      break;
      case 2:
      enc = enc.slice(0, -1) + '=';        break;
    }

    $("textarea#user_data").attr('value', enc);
    return false;
}

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
  if (type == "address")
  {
    name = "ip_address" + eval(++addresses)
    create_rule_source_field(name, "Address " + eval(addresses),
                             "[use CIDR notation 0.0.0.0/0]")
  }
  else if (type == "group")
  {
    name = "group" + eval(++groups)
    create_rule_source_field(name, "Name of group " + eval(groups), "")
    name = "group" + eval(groups) + "owner"
    create_rule_source_field(name, "Group " + eval(groups) + " owner", "(required)")
  }
}

function create_rule_source_field(name, label, hint)
{
  html = "<br/>" +
    "<label>" + label + "</label>&nbsp;" +
    "<input name='" + name + "' size=35 type='text'/>" +
    "<span>&nbsp;" + hint + "</span>"

  $(html).insertBefore("#new_rule_form_fields")
}

function create_address(url)
{
  $.post(url, function(data) {
    var ul = $('#address_list')
    ul.append($(data))
    ul.listview('refresh')
  })
}
