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
