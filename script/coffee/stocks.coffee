'use strict'

_stocks = [ ]

class Stocks

   @setup: ( ) ->
      Stocks.startObserving( )
      chrome.storage.local.get 'stocks', ( read ) ->
         if not chrome.runtime.lastError? or chrome.runtime.lastError is ''
            _stocks = if read.stocks? then read.stocks else [ ]

   @startObserving: ( ) ->
      Stocks.update( )
      chrome.alarms.get 'observing', ( alarm ) ->
         if alarm is null
            interval = stocking.config.Static.UpdateIntervalMinutes
            chrome.alarms.create 'observing', ( delayInMinutes: interval, periodInMinutes: interval )
            chrome.alarms.onAlarm.addListener ( alarm ) ->
               Stocks.update( ) if alarm.name is 'observing'

   @update: ( ) ->
      acc = [ ]
      callback = ( page, stocks ) ->
         if stocks?
            for s in stocks
               acc.push ( url: s.url, title: s.title, tags: ( t.name for t in s.tags ) )

            if stocks.length is stocking.config.Static.StocksPerRequest
               stocking.StockDownloader.start page + 1, callback
            else
               _stocks = acc
               chrome.storage.local.set ( stocks: _stocks )
         else
            return # null(失敗)だった場合は中断

      stocking.StockDownloader.start 1, callback

   @getAll: ( ) -> s for s in _stocks

   @getByTitle: ( title ) ->
      for s in _stocks
         return s if s.title is title

      return null

define 'stocking', Stocks
