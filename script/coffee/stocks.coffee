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

      interval = stocking.config.Static.UpdateIntervalMinutes
      chrome.alarms.get 'observing', ( alarm ) ->
         if not alarm? or alarm.periodInMinutes isnt interval
            chrome.alarms.create 'observing', ( delayInMinutes: interval, periodInMinutes: interval )

         if not chrome.alarms.onAlarm.hasListeners( )
            chrome.alarms.onAlarm.addListener ( alarm ) ->
               if alarm.name is 'observing'
                  stocking.waitLaunching ( -> Stocks.update( ) )

   @update: ( needNotifying = false, completedCallback = null ) ->
      currentUser = stocking.Utils.getUser( )
      stocking.StockDownloader.start ( stocks ) ->
         if stocks? and currentUser is stocking.Utils.getUser( )
            _stocks = ( ( url: s.url, title: s.title, tags: ( t.name for t in s.tags ) ) for s in stocks )
            chrome.storage.local.set ( stocks: _stocks )
            Stocks.notifyFirstUpdated currentUser if needNotifying

         completedCallback( ) if completedCallback?

   @notifyFirstUpdated: ( name ) ->
      chrome.notifications.create 'stocks-updated', (
         type    : 'basic'
         iconUrl : '/resource/icon128.png'
         title   : 'ストック更新完了のお知らせ'
         message : name + 'さんのストックの初期設定が完了しました'
      ), ( -> )

   @getAll: ( ) -> s for s in _stocks

   @getByTitle: ( title ) ->
      for s in _stocks
         return s if s.title is title

      return null

define 'stocking', Stocks
