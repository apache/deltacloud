$(function() {
  $(".alert-message").alert();

  $("a#saveProvider").bind('click', function() {
    $('#providerModal').modal('hide');
    $("#providerModal form").submit();
    return false;
  })

});

function toggleConfig(driver) {
  $('#providerModal form input[name=driver]').attr('value', driver);
  $('#providerModal span#driverName').html(driver.toUpperCase());
  $('#providerModal').modal('show');
  return false;
}

function postModalForm(btn, id) {
  $('div#'+id+' form').submit(function(e) {
    e.preventDefault();
    var frm = $(this);
    $(btn).button('loading');
    $.ajax({
      type : 'POST',
      url : frm.attr('action'),
      data : frm.serialize(),
      success: function(data) {
        $(btn).button('Complete!');
        $('div#'+id).modal('hide');
        location.reload();
      }
    })
    
  }).submit()
  return false;
}
