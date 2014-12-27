'use strict'

core = null

# ユーザーAPIを叩いて確認
checkUser = ( userId, callback ) ->
   if not userId? or userId.length is 0
      callback null
      return

   $.ajax(
      type     : 'GET'
      url      : 'http://qiita.com/api/v2/users/' + userId
      dataType : 'json'
      success  : callback
      error    : ( -> callback null )
   )

# 保存クリック時のイベントハンドラ
onClickedSave = ( ) ->
   $( document.user.save ).attr 'disabled', 'disabled'
   $( '#profile' ).hide( )
   $( '#not-found' ).hide( )
   $( '#checking' ).fadeIn 100, ( ) ->

      checkUser document.user.name.value, ( user ) ->

         $( '#checking' ).fadeOut 100, ( ) ->
            $( document.user.save ).removeAttr 'disabled'
            if user?

               # ユーザー情報とストックを更新
               core.stocking.Utils.setUser user.id
               core.stocking.Stocks.update true

               view = $( '#profile' )
               view.find( 'img' ).attr 'src', user.profile_image_url
               view.find( '.name' ).text user.id
               view.find( '.description' ).text user.description
               view.fadeIn 100
            else
               $( '#not-found' ).fadeIn 100

$ ( ) ->

   $( document.user.save ).click onClickedSave

   $( document.user.name ).bind 'input', ( ) ->
      if document.user.name.value.length is 0
         $( document.user.save ).attr 'disabled', 'disabled'
      else
         $( document.user.save ).removeAttr 'disabled'

   $( document.user ).submit ( ) -> false

   chrome.runtime.getBackgroundPage ( window ) ->
      core = window
      core.stocking.waitLaunching ( ) ->
         if ( user = core.stocking.Utils.getUser( ) )?
            document.user.name.value = user
            $( document.user.save ).removeAttr 'disabled'

         $( '#loading' ).fadeOut 400
