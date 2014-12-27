'use strict'

_config = { }

# 動的な設定
class Dynamic

   @load: ( callback ) ->
      keys = [
         stocking.config.Static.UserIdKey
      ]
      chrome.storage.local.get keys, ( read ) ->
         if chrome.runtime.lastError? and chrome.runtime.lastError isnt ''
            callback false
         else
            _config = read
            callback true

   @get: ( key ) ->
      if _config[ key ]? then _config[ key ] else null
  
   # 保存. エラー処理はしない
   @set: ( key, value ) ->
      _config[ key ] = value

      set = { }
      set[ key ] = value
      chrome.storage.local.set set, ( -> )

define 'stocking', 'config', Dynamic
