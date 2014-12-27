'use strict'

# 指定ページのストックをDLします
class StockDownloader

   @start: ( page, callback, requestInstance = new stocking.Request ) ->

      # ETagを積極的に使う
      etagKey = "etag-page-#{page}"
      chrome.storage.local.get etagKey, ( read ) ->

         if stocking.Utils.hasApiError( )
            etag = ''
         else
            etag = if read[ etagKey ]? then read[ etagKey ] else ''

         user = stocking.Utils.getUser( )
         unless user?
            setTimeout ( -> callback page, null ), 0
            return

         url  = stocking.config.Static.StocksApi.replace ':user_id', user
         params = ( page: page, per_page: stocking.config.Static.StocksPerRequest )

         requestInstance.setHeader 'If-None-Match', etag
         requestInstance.start url, params, ( response ) ->

            if response.status is 200

               try
                  stocks = JSON.parse response.text

                  # 本文は使わない上にデカイので消しておく
                  for s in stocks
                     delete s.rendered_body
                     delete s.body
               catch e
                  callback page, null
                  return

               # ETagとレスポンスを保存. ETagとレスポンスは, 不整合が起きないよう必ず同時で
               set = { }
               set[ "etag-page-#{page}" ] = response.getHeader "ETag"
               set[ "response-page-#{page}" ] = JSON.stringify stocks # 本文を消した状態のオブジェクトを保存
               chrome.storage.local.set set

               callback page, stocks

            else if response.status is 304
               # ETagに変更がないならローカルに保存してあるレスポンスを返却
               chrome.storage.local.get "response-page-#{page}", ( read ) ->
                  if stocking.Utils.hasApiError( )
                     callback page, null
                  else
                     callback page, JSON.parse( read[ "response-page-#{page}" ] )
            else
               callback page, null

define 'stocking', StockDownloader
