'use strict'

class Response

   constructor: ( @_xhr ) ->
      Object.defineProperties this, (
         status : ( value: @_xhr.status ),
         text   : ( value: @_xhr.responseText )
      )

   getHeader: ( key ) ->
      @_xhr.getResponseHeader key

class Request

   constructor: ( @_xhr = new XMLHttpRequest ) ->
      @_headers = { }

   setHeader: ( key, value ) ->
      @_headers[ key ] = value

   start: ( url, params, callback = null ) ->
      @_url = @_buildUrl url, params
      
      @_xhr.open 'GET', @_url, true
      @_xhr.onreadystatechange = ( ) =>
         callback ( new Response @_xhr ) if @_xhr.readyState is 4

      @_xhr.setRequestHeader k, v for k, v of @_headers
      @_xhr.send( )

   _buildUrl: ( url, params ) ->
      queryString = ( "#{k}=#{v}" for k, v of params ).join "&"
      return if queryString isnt '' then "#{url}?#{queryString}" else url

define 'stocking', Request
