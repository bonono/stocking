'use strict'

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

$ ( ) ->

   $( document.user.save ).click ( ) ->
      $( document.user.save ).attr 'disabled', 'disabled'
      $( '#profile' ).hide( )
      $( '#not-found' ).hide( )
      $( '#checking' ).fadeIn 100, ( ) ->

         checkUser document.user.name.value, ( user ) ->

            $( '#checking' ).fadeOut 100, ( ) ->
               $( document.user.save ).removeAttr 'disabled'
               if user?
                  view = $( '#profile' )
                  view.find( 'img' ).attr 'src', user.profile_image_url
                  view.find( '.name' ).text user.id
                  view.find( '.description' ).text user.description
                  view.fadeIn 100
               else
                  $( '#not-found' ).fadeIn 100

   $( document.user.name ).bind 'input', ( ) ->
      if document.user.name.value.length is 0
         $( document.user.save ).attr 'disabled', 'disabled'
      else
         $( document.user.save ).removeAttr 'disabled'

   $( document.user ).submit ( ) -> false


