'use strict'

# 指定ページのストックをDLします
class StockDownloader

   @start: ( page, callback, requestInstance = new stocking.Request ) ->

      # タグを積極的に使う
      etagKey = "etag-page-#{page}"
      chrome.storage.local.get etagKey, ( read ) ->

         if chrome.runtime.lastError? and chrome.runtime.lastError isnt ''
            etag = ''
         else
            etag = if read[ etagKey ]? then read[ etagKey ] else ''

         user = stocking.config.Dynamic.get( stocking.config.Static.UserIdKey )
         unless user?
            setTimeout ( -> callback page, null ), 0
            return

         url  = stocking.config.Static.StocksApi.replace ':user_id', user

         params = ( page: page, per_page: stocking.config.Static.StocksPerRequest )

         requestInstance.setHeader 'If-None-Match', etag
         requestInstance.start url, params, ( response ) ->

            if response.status is 200 or response.status is 304

               # ETagを保存
               if response.status is 200
                  set = { }
                  set[ "etag-page-#{page}" ] = response.getHeader "ETag"
                  chrome.storage.local.set set

               try
                  stocks = JSON.parse response.text
               catch e
                  stocks = null

               callback page, stocks

            else
               # エラーはやんわり無視
               callback page, null

define 'stocking', StockDownloader
