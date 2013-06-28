###
// ==UserScript==
// @id             ajax_pixiv_bookmark
// @name           AJAX Pixiv Bookmark
// @version        2.0.0
// @namespace      http://blog.k2ds.net/
// @author         killtw
// @description    Using AJAX to add a bookmark in Pixiv
// @match          http://www.pixiv.net/setting_user.php
// @include        http://www.pixiv.net/setting_user.php
// @match          http://www.pixiv.net/member_illust.php?*
// @include        http://www.pixiv.net/member_illust.php?*
// ==/UserScript==
###

addjQuery = (callback) ->
    e = document.createElement 'script'
    e.setAttribute 'src', 'http://ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min.js'
    e.addEventListener 'load', () ->
      script = document.createElement 'script'
      script.textContent = "(" + callback.toString() + ")();"
      document.body.appendChild script
      return
    document.body.appendChild e
    return

main = () ->
  $('div.bookmark-container a._button').click (e) ->
    e.preventDefault()
    illust_tags = []
    input_tag = []
    illust_id = $('input[name="illust_id"]').val()

    $.ajax
      url: 'http://www.pixiv.net/bookmark_tag_all.php'
      type: 'GET'
      dataType: 'html'
      beforeSend: () ->
        for tag in $('a.text')
          illust_tags.push tag.innerText
        console.log illust_tags
      success: (data) ->
        for tag in $(data).find('a.tag-name')
          if illust_tags.indexOf(tag.innerText) isnt -1
            input_tag.push tag.innerText
        console.log input_tag.join(' ')
        return
      complete: () ->
        $.ajax
          url: 'bookmark_add.php'
          data:
            mode: 'add'
            tt: $('input[name="tt"]').val()
            id: illust_id
            tag: input_tag.join(' ')
            type: 'illust'
            form_sid: ''
            restrict: '0'
          dataType: 'html'
          type: 'POST'
          beforeSend: () ->
            $("div.bookmark-container a._button").text('追加中…')
            return
          success: () ->
            $("div.bookmark-container a._button").text('加入成功')
            $('div.bookmark-container').fadeOut('fast').html('<a href="bookmark_add.php?type=illust&illust_id=' + illust_id + '" class="button-on">編輯收藏</a>').fadeIn('fast')
            return
        return
    return
  return

addjQuery main
