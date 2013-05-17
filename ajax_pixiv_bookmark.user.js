// ==UserScript==
// @id             ajax_pixiv_bookmark
// @name           AJAX Pixiv Bookmark
// @version        1.0.1
// @namespace      http://blog.k2ds.net/
// @author         killtw
// @description    Using AJAX to add a bookmark in Pixiv
// @match          http://www.pixiv.net/member_illust.php?*
// @include        http://www.pixiv.net/member_illust.php?*
// ==/UserScript==

// a function that loads jQuery and calls a callback function when jQuery has finished loading
function addJQuery(callback) {
  var script = document.createElement("script");
  script.setAttribute("src", "http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js");
  script.addEventListener('load', function() {
    var script = document.createElement("script");
    script.textContent = "(" + callback.toString() + ")();";
    document.body.appendChild(script);
  }, false);
  document.body.appendChild(script);
}

function main() {
  $("div.bookmark-container a._button").live('click', function(e) {
    e.preventDefault();
    var tt = $('input[name="tt"]').val();
    var illust_id = $('div#rpc_i_id').attr('title');

    $.ajax({
      url: 'bookmark_add.php',
      data: {
        mode: 'add',
        tt: tt,
        id: illust_id,
        type: 'illust',
        form_sid: '',
        restrict: '0'
      },
      dataType: 'html',
      type: 'POST',
      beforeSend: function() {
        $("div.bookmark-container a._button").text('追加中…');
      },
      success: function() {
        $("div.bookmark-container a._button").text('加入成功');
//        $('div.bookmark').load('member_illust.php?mode=medium&illust_id='+illust_id+' div.bookmark');
        $('div.bookmark-container').fadeOut('fast').html('[ <a href="bookmark_detail.php?illust_id=' + illust_id + '">ブックマーク済み</a> | <a href="bookmark_add.php?type=illust&amp;illust_id=' + illust_id + '">編輯</a> ]').fadeIn('fast');
      }
    });
    return false;
  });
}

addJQuery(main);

GM_addStyle(".AutoPager_Related, .ads_area { display:none !important; }");