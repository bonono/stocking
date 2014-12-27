'use strict'

class StockLibrary

   constructor: ( @_stocks ) ->

   search: ( partOfTitle ) ->
      re = new RegExp partOfTitle, 'i'
      return ( s for s in @_stocks when re.test s.title )

define 'stocking', StockLibrary
