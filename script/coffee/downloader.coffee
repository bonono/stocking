'use strict'

class Downloader

   constructor: ( ) ->
      @_reset( )

      Object.defineProperty this, 'status', ( get: ( ) => @_status )
      Object.defineProperty this, 'requestUrl', ( get: ( ) => @_url )
      Object.defineProperty this, 'response', ( get: ( ) => @_response )
      Object.defineProperty this, 'responsedETag', ( get: ( ) => @_eTag )
      Object.defineProperty this, 'isSucceeded', ( get: ( ) => @_status is 200 || @_status is 304 )

   start: ( url, params, eTag, callback = null ) ->
      @_reset( )
      @_url = @_buildUrl url, params
      
      xhr = new XMLHttpRequest
      xhr.open 'GET', @_url, true

      xhr.setRequestHeader 'If-None-Match', eTag if eTag? and eTag isnt ''

      xhr.onreadystatechange = ( ) =>
         if xhr.readyState is 4
            @_status = xhr.status
            if xhr.status is 200 || xhr.status is 304
               @_response = xhr.responseText
               @_eTag     = xhr.getResponseHeader 'ETag' if xhr.status is 200

            callback this if callback?

      xhr.send( )

   _reset: ( ) ->
      @_status      = 0
      @_url         = ''
      @_response    = ''
      @_eTag        = ''

   _buildUrl: ( url, params ) ->
      queryString = ( "#{k}=#{v}" for k, v of params ).join "&"
      return if queryString isnt '' then "#{url}?#{queryString}" else url
