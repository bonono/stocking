'use strict'

class Utils

   @toPascalCase: ( str ) ->
      ( w.charAt( 0 ).toUpperCase( ) + w.substring( 1 ) for w in str.split '_' ).join ''

define 'stocking', Utils
