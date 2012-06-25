$(document).ready(function() {
  $(".tweet").tweet({
    username: "deltacloud",
    query : '#deltacloud',
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
