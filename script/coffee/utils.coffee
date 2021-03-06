'use strict'

class Utils

   @toPascalCase: ( str ) ->
      ( w.charAt( 0 ).toUpperCase( ) + w.substring( 1 ) for w in str.split '_' ).join ''

   @getUser: ( ) ->
      stocking.config.Dynamic.get stocking.config.Static.UserIdKey

   @setUser: ( userId ) ->
      stocking.config.Dynamic.set stocking.config.Static.UserIdKey, userId

   @hasApiError: ( ) ->
      chrome.runtime.lastError? and chrome.runtime.lastError isnt ''

   @needEscape: ( str ) -> ( /["\'\<\>&]/g ).test str

   @escape: ( str ) ->
      specialChars = ( '"': '&quot;', '\'': '&apos;', '<': '&lt;', '>': '&gt;', '&': '&amp;' )
      return str.replace( /["\'\<\>&]/g, ( m ) -> specialChars[ m ] )

define 'stocking', Utils
