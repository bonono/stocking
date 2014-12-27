'use strict'

_storage = { }
_raiseError = false

class MockChromeStorageLocal
   
   @raiseErrorNext: ( ) ->
      _raiseError = true

   @setDirect: ( data ) ->
      _storage[ k ] = v for k, v of data

   @get: ( keys, callback ) ->
      keys = [ keys ] if Object.prototype.toString.call( keys ) isnt '[object Array]'
      read = { }
      for k in keys
         read[ k ] = if _storage[ k ]? then _storage[ k ] else null

      chrome.runtime.lastError = if _raiseError then 'TEST ERROR' else ''
      _raiseError = false

      setTimeout ( -> callback read ), 0

   @set: ( setObj, callback ) ->
      _storage[ k ] = v for k, v of setObj

      chrome.runtime.lastError = if _raiseError then 'TEST ERROR' else ''
      _raiseError = false

      setTimeout callback, 0

defineAs 'chrome', 'runtime', ( lastError: '' )
defineAs 'chrome', 'storage', 'local', MockChromeStorageLocal
