'use strict'

currentRequest = null

# ストックをDLするクラス
class StockDownloader

   @start: ( callback, requestInstance = new stocking.Request ) ->

      # ETagを積極的に使う
      etagKey = "etag-v1"
      chrome.storage.local.get etagKey, ( read ) ->

         if stocking.Utils.hasApiError( )
            etag = ''
         else
            etag = if read[ etagKey ]? then read[ etagKey ] else ''

         user = stocking.Utils.getUser( )
         unless user?
            setTimeout ( -> callback null ), 0
            return

         url = stocking.config.Static.StocksApi.replace ':user_id', user
         timeout = ( stocking.config.Static.UpdateIntervalMinutes - 1 ) * 60 * 100 # タイムアウトは次の1分前まで

         # 前のリクエストがまだあるなら中断しておく
         currentRequest.abort( ) if currentRequest?
         currentRequest = requestInstance

         requestInstance.setHeader 'If-None-Match', etag
         requestInstance.start url, { }, ( response ) ->
            currentRequest = null

            if response.status is 200

               try
                  stocks = [ ]
                  for s in JSON.parse response.text
                     stock = ( title: s.title, url: s.url, tags: [ ] )
                     ( stock.tags.push ( name: t.name ) ) for t in s.tags
                     stocks.push stock
               catch e
                  callback null
                  return

               # ETagとレスポンスを保存. ETagとレスポンスは, 不整合が起きないよう必ず同時で
               set =
                  'etag-v1'     : response.getHeader 'ETag'
                  'response-v1' : JSON.stringify stocks

               chrome.storage.local.set set
               callback stocks

            else if response.status is 304
               # ETagに変更がないならローカルに保存してあるレスポンスを返却
               chrome.storage.local.get "response-v1", ( read ) ->
                  if stocking.Utils.hasApiError( ) or not read[ "response-v1" ]?
                     callback null
                  else
                     callback JSON.parse( read[ 'response-v1' ] )
            else
               callback null

         , timeout

define 'stocking', StockDownloader
