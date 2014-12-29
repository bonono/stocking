'use strict'

# XMLHttpRequestのモック
class MockXMLHttpRequest

   constructor: ( ) ->
      @_requestHeader = { }
      @_responseHeader = { }
      @_url = ''

      @status = 0
      @readyState = 0
      @responseText = ''
      @onreadystatechange = ( -> )

   setRequestHeader: ( key, value ) ->
      @_requestHeader[ key ] = value

   getResponseHeader: ( key ) ->
      if @_responseHeader[ key ]? then @_responseHeader[ key ] else ''

   open: ( method, @_url, async ) ->
      throw new Error 'You can call open function when readyState is 0' if @readyState isnt 0
      @readyState = 1
      @onreadystatechange( )

   send: ( ) ->
      throw new Error 'You can call send function when readyState is 1' if @readyState isnt 1
      @readyState = 3
      @onreadystatechange( )

   abort: ( delay = 0 ) ->
      throw new Error 'You can call abort function when readyState is 3' if @readyState isnt 3
      setTimeout (
         @readyState = 4
         @status = 0
         @onreadystatechange( )
      ), 

   # 以下モック用のメソッド
   # send後に以下メソッドを使って値を検証できる
   setStatus: ( @status ) ->
   setResponse: ( @responseText ) ->

   getUrl: ( ) -> @_url

   getRequestHeader: ( key ) ->
      if @_requestHeader[ key ]? then @_requestHeader[ key ] else ''

   setResponseHeader: ( key, value ) ->
      @_responseHeader[ key ] = value

   resume: ( delay = 0 ) ->
      setTimeout ( =>
         @readyState = 4
         @onreadystatechange( ) 
      ), delay

define 'mocks', MockXMLHttpRequest
