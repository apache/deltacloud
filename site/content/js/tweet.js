$(document).ready(function() {
  if($.browser.msie) {
    $("#dcloud_popup_link").attr("href", "dcloud.html");
    $("#demo_popup_link").attr("href", "dcloud-demo.html");
  } else {
    $("a.vid").fancybox({ 'hideOnContentClick': true, 'width': 400, 'height': 300, 'titleShow': false });
    $("a.providers").fancybox({ 'hideOnContentClick': true, 'padding': 0, 'margin': 0, 'width': 958,
      'height': 640, 'scrolling': 'no', 'autoDimensions': false, 'autoScale': true });
  }
  $(".tweet").tweet({
    username: "deltacloud",
    query : '#deltacloud OR @deltacloud',
    join_text: "auto",
    avatar_size: 32,
    count: 2,
    retweets : false,
    auto_join_text_default: "we said,",
    auto_join_text_ed: "",
    auto_join_text_ing: "",
    auto_join_text_reply: "we replied to",
    auto_join_text_url: "we were checking out",
    loading_text: "Loading news..."
  });
});
