###
// ==UserScript==
// @id             ajax_pixiv_bookmark
// @name           AJAX Pixiv Bookmark
// @version        2.0.2
// @namespace      http://blog.k2ds.net/
// @author         killtw
// @description    Using AJAX to add a bookmark in Pixiv
// @match          http://www.pixiv.net/member_illust.php?*
// @match          http://www.pixiv.net/setting_user.php
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
  settings =
    default_tag: localStorage.default_tag

  $('table tbody:eq(1)').append '
  <tr><th>預設標籤</th><td>
  <p>當沒有符合的標籤時將使用代入預設標籤，空白即不代入預設標籤</p>
  <p><input type="text" name="default_tag" onkeyup="localStorage.setItem(\'default_tag\', this.value)" value="' + settings.default_tag + '"></p>
  </td></tr>'

  $('div.bookmark-container a._button').click (e) ->
    e.preventDefault()
    illust_tags = []
    input_tag = []
    illust_id = document.URL.match(/\d+/)[0]
    tt = $('input[name="tt"]').val()

    $.ajax
      url: 'http://www.pixiv.net/bookmark_tag_all.php'
      type: 'GET'
      dataType: 'html'
      beforeSend: () ->
        if document.URL.match('manga')
          $.ajax
            url: "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{illust_id}"
            type: 'GET'
            dataType: 'html'
            async: false
            success: (data) ->
              for tag in $(data).find('a.text')
                illust_tags.push tag.text
              tt = $(data).find('input[name="tt"]')[0].value
        else
          for tag in $('a.text')
            illust_tags.push tag.text
        #console.log illust_tags
        return
      success: (data) ->
        for tag in $(data).find('a.tag-name')
          if illust_tags.indexOf(tag.text) isnt -1
            input_tag.push tag.text
        #console.log input_tag.join(' ')
        if input_tag.length is 0
          input_tag.push settings.default_tag
        return
      complete: () ->
        $.ajax
          url: 'bookmark_add.php'
          data:
            mode: 'add'
            tt: tt
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
