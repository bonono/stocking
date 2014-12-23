'use strict'

###
class StringArray

   constructor: ( @_source = [ ] ) ->
      @_searchResult = null
      @_prevWord = null
      @_strings = ( str.toLowerCase( ) for str in @_source )

   search: ( word ) ->
      if @_searchResult?
         return @_searchFromResult word
      else
         return @_searchByDefault word

   _searchByDefault: ( word ) ->
      ret = [ ]
      @_searchResult = [ ]
      for index, str of @_strings
         found = str.indexOf word
         if found isnt -1
            @_searchResult.push ( index: index, followingString: str.substring( found + word.length ) )
            ret.push @_source[ index ]

      @_prevWord = word
      return ret

   _searchFromResult: ( word ) ->
      if word isnt @_prevWord and word.substring( 0, @_prevWord.length ) is @_prevWord

         added = word.substring @_prevWord.length
         ret = [ ]
         searchResult = [ ]

         for sr in @_searchResult
            if sr.followingString.substring( 0, added.length ) is added
               ret.push @_source[ sr.index ]
               searchResult.push ( index: sr.index, followingString: sr.followingString.substring( added.length ) )

         @_prevWord = word
         @_searchResult = searchResult

         return ret
         
      else
         @_searchResult = null
         @_prevWord = null
         return @_searchByDefault word
###

class StringArray

   constructor: ( @_source = [ ]) ->
      @_strings = ( s.toLowerCase( ) for s in @_source )

   search: ( word ) ->
      # とりあえずindexOfで単純に実装
      ( @_source[ i ] for i, s of @_strings when s.indexOf( word ) isnt -1 )

define 'stocking', StringArray

