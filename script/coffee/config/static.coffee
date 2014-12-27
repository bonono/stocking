'use strict'

# 静的な設定ファイル
class Static

   @load: ( callback ) ->
      chrome.runtime.getPackageDirectoryEntry ( root ) ->
         root.getFile 'app.json', ( create: false ), ( ( app ) ->
            app.file ( file ) ->

               reader = new FileReader
               reader.onerror = ( ) -> callback false
               reader.onload = ( e ) ->
                  json = JSON.parse e.target.result
                  for k, v of json
                     Object.defineProperty Static, stocking.Utils.toPascalCase( k ), ( value: v )
                  callback true

               reader.readAsText file, 'utf-8'

         ), ( -> callback false )

define 'stocking', 'config', Static
