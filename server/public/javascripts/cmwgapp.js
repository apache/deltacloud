// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function doPut(theNode)
{
  $.ajax({
      type: "PUT",
      url: $(theNode.form).attr("action"),
      data: $(theNode.form).serializeArray(),
      success: function(returnData) {
        alert("Command executed successfully!");
        var flag = theNode.form.elements["refresh"];
        if (flag != null && flag.value == "true") {
          location.reload(true);
        }
      },
      error: function(errorData) {
        alert("Command executed unsuccessfully!")
      },
      dataType: "xml"
    });
}

function doXmlPut(theNode, addId, func)
{
  var xmlData = "";
  if (func) {
    xmlData = fixupXml(theNode);
  }
  else {
    xmlData = "<?xml version='1.0' encoding='utf-8' ?>";
    xmlData += "<" + $(theNode.form).attr("xmlRootNode").value + " xmlns='http://www.dmtf.org/cimi'>";
    xmlData += getStandardData(theNode);
    xmlData += "</" + $(theNode.form).attr("xmlRootNode").value + ">";
  }

  var padding = "";
  if (addId) {
    padding = "/" + $(theNode.form).attr("id").value;
  }

  $.ajax({
      type: "PUT",
      url: $(theNode.form).attr("action") + padding,
      data: xmlData,
      contentType: 'application/xml',
      accepts: 'application/xml',
      success: function(data, textStatus, jqXHR) {
        alert("Command executed successfully!");
        var flag = theNode.form.elements["refresh"];
        if (flag != null && flag.value == "true") {
          location.reload(true);
        }
      },
      error: function(a, b, c) {
        alert("Command executed unsuccessfully!")
      },
      statusCode: {
      204: function() {
        alert("Command executed successfully!")
      }
      },
      dataType: "xml"
    });
}

function doXmlPost(theNode, func)
{
  var xmlData = "";
  if (func) {
    xmlData = fixupXml(theNode);
  }
  else {
    xmlData = "<?xml version='1.0' encoding='utf-8' ?>";
    xmlData += "<" + $(theNode.form).attr("xmlRootNode").value + " xmlns='http://www.dmtf.org/cimi'>";
    xmlData += getStandardData(theNode)
    xmlData += "</" + $(theNode.form).attr("xmlRootNode").value + ">";
  }

  $.ajax({
      type: "POST",
      url: $(theNode.form).attr("action"),
      data: xmlData,
      contentType: 'application/xml',
      accepts: 'application/xml',
      success: function(data, textStatus, jqXHR) {
        alert("Command executed successfully!");
        window.location.href = $(theNode.form).attr("refreshURI").value
      },
      error: function(jqXHR, data1, data2) {
        alert("Command executed unsuccessfully!")
      },
      statusCode: {
      201: function() {
        alert("Command executed successfully!")
      }
      },
      dataType: "xml"
    });
}

function doXmlDelete(theNode, addId)
{
  var xmlData = "<?xml version='1.0' encoding='utf-8' ?>";
  var padding = "";
  if (addId) {
    padding = "/" + $(theNode.form).attr("id").value;
  }

  $.ajax({
      type: "DELETE",
      url: $(theNode.form).attr("action") + padding,
      data: xmlData,
      contentType: 'application/xml',
      accepts: 'application/xml',
      success: function(returnData) {
        alert("Command executed successfully!")
        //window.location.href = $(theNode.form).attr("action")
        window.location.href = $(theNode.form).attr("refreshURI").value
      },
      error: function(errorData) {
        alert("Command executed unsuccessfully!")
      },
      dataType: "xml"
    });
}

function getStandardData(theNode) {
  var xmlData = "";
  xmlData += "<uri>" + $(theNode.form).attr("id").value + "</uri>";
  xmlData += "<name>" + $(theNode.form).attr("name").value + "</name>";
  xmlData += "<description>" + $(theNode.form).attr("description").value + "</description>";
  xmlData += "<created>" + $(theNode.form).attr("created").value + "</created>";

  //handling properties
  var index=0;
  while ($(theNode.form).attr("param_name_" + index)) {
    if ($(theNode.form).attr("param_name_" + index).value != null &&
        $(theNode.form).attr("param_name_" + index).value.length > 0) {
      xmlData += "<property name='" + $(theNode.form).attr("param_name_" + index).value + "'>" +
                                     $(theNode.form).attr("param_value_" + index).value + "</property>";
    }
    index++;
  }

  //handling operations
  index = 0
  while ($(theNode.form).attr("operation_" + index)) {
    var aOpNode = ttt0 = $(theNode.form).attr("operation_" + index);
      xmlData += "<operation rel='" + $(aOpNode).attr("oper_type") + "' href='" +
                                     aOpNode.value + "' />";
    index++;
  }

  return xmlData;
}

function doDelete(theNode)
{
  var theURL = $(theNode.form).attr("action");
  var theData = $(theNode.form).serializeArray();

  $.ajax({
      type: "DELETE",
      url: $(theNode.form).attr("action"),
      data: $(theNode.form).serializeArray(),
      success: function(returnData) {
        alert("Command executed successfully!")
        var flag = theNode.form.elements["refresh"];
        if (flag != null && flag.value == "true") {
          location.reload(true);
        }
      },
      error: function(errorData) {
        alert("Command executed unsuccessfully!")
      },
      dataType: "xml"
    });
}

function doPost(theNode)
{
  var theURL = $(theNode.form).attr("action");
  var theData = $(theNode.form).serializeArray();

  $.ajax({
      type: "POST",
      url: $(theNode.form).attr("action"),
      data: $(theNode.form).serializeArray(),
      success: function(returnData) {
        alert("Command executed successfully!")
        var flag = theNode.form.elements["refresh"];
        if (flag != null && flag.value == "true") {
          location.reload(true);
        }
      },
      error: function(errorData) {
        alert("Command executed unsuccessfully!")
      },
      dataType: "xml"
    });
}

function AddNewPproperty(tableId)
{
  var tbl = document.getElementById(tableId);
  var lastRow = tbl.rows.length;
  // if there's no header row in the table, then iteration = lastRow + 1
  var iteration = lastRow;
  var row = tbl.insertRow(lastRow);

  // left cell
  var cellLeft = row.insertCell(0);
  var el = document.createElement('input');
  el.type = 'text';
  el.name = 'param_name_' + iteration;
  el.id = 'param_name_' + iteration;
  el.size = 25;
  cellLeft.appendChild(el);


  // right cell
  var cellRight = row.insertCell(1);
  var em = document.createElement('input');
  em.type = 'text';
  em.name = 'param_value_' + iteration;
  em.id = 'param_value_' + iteration;
  em.size = 25;
  cellRight.appendChild(em);

  // select cell
  var cellRightBut = row.insertCell(2);
  var er = document.createElement('input');
  er.type = 'button';
  er.name = 'param_remove' + iteration;
  er.id = 'param_remove' + iteration;
  er.value = "Remove";
  er.tableRow = row
  $(er).click(function() {
  removeProperty(this);
  })

  cellRightBut.appendChild(er);
}

function removeProperty(theNode)
{
  $(theNode.parentNode.parentNode).remove();
}
