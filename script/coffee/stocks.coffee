'use strict'

_stocks = [ ]

class Stocks

   @setup: ( callback ) ->
      Stocks.startObserving( )
      chrome.storage.local.get 'stocks', ( read ) ->
         if not chrome.runtime.lastError? or chrome.runtime.lastError is ''
            _stocks = if read.stocks? then read.stocks else [ ]
            callback true
         else
            callback false

   @startObserving: ( ) ->
      Stocks.update( )
      chrome.alarms.get 'observing', ( alarm ) ->
         if alarm is null
            interval = stocking.config.Static.UpdateIntervalMinutes
            chrome.alarms.create 'observing', ( delayInMinutes: interval, periodInMinutes: interval )
            chrome.alarms.onAlarm.addListener ( alarm ) ->
               if alarm.name is 'observing'
                  stocking.waitLaunching ( -> Stocks.update( ) )

   @update: ( needNotifying = false, completedCallback = null ) ->
      currentUser = stocking.Utils.getUser( )

      acc = [ ]
      callback = ( page, stocks ) ->
         if stocks?
            for s in stocks
               acc.push ( url: s.url, title: s.title, tags: ( t.name for t in s.tags ) )

            if stocks.length is stocking.config.Static.StocksPerRequest
               stocking.StockDownloader.start page + 1, callback
            else
               # APIの更新は時間がかかるため, updateが呼ばれて更新を行っている間にユーザー名が変更される可能性がある
               # そのためupdate呼び出し時のユーザー名と比較し, 等しい場合だけストックを更新する
               if currentUser is stocking.Utils.getUser( )
                  _stocks = acc
                  chrome.storage.local.set ( stocks: _stocks )

                  if needNotifying
                     chrome.notifications.create 'stocks-updated', (
                        type    : 'basic'
                        iconUrl : '/resource/icon128.png'
                        title   : 'ストック更新完了のお知らせ'
                        message : currentUser + 'さんのストックの初期設定が完了しました'
                     ), ( -> )

                  completedCallback( ) if completedCallback?

         else
            completedCallback( ) if completedCallback? # null(失敗)だった場合は中断

      stocking.StockDownloader.start 1, callback

   @getAll: ( ) -> s for s in _stocks

   @getByTitle: ( title ) ->
      for s in _stocks
         return s if s.title is title

      return null

define 'stocking', Stocks
