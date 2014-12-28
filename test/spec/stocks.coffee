'use strict'

# StockDownloaderはモックと差し替える
class MockStockDownloader

   @_data = [ ]
   @_calledPage = [ ]

   # pageキーとstocksキーを持ったオブジェクトの配列をダミーのデータとしてセットする
   # startメソッドのpage引数に応じて, ここで指定されたデータをコールバックの引数として渡す
   @setResponseData: ( data ) ->
      @_data = data

   @resetCallHistory: ( ) ->
      @_calledPage = [ ]

   @getCallHistory: ( ) ->
      @_calledPage

   @start: ( page, callback ) ->
      data = null
      for d in @_data
         if d.page is page
            data = d.stocks
            break

      @_calledPage.push page
      setTimeout ( -> callback page, data ), 0


stockDownloader = stocking.StockDownloader
staticConfig = stocking.config.Static

createDummyStock = ( url, title, tagNames = [ ] ) ->
   stock = ( url: url, title: title, tags: [ ] )
   stock.tags.push ( name: name ) for name in tagNames
   return stock

describe 'stocking.Stocks.updateのテスト', ( ) ->

   beforeEach ( done ) ->
      defineAs 'stocking', 'StockDownloader', MockStockDownloader
      defineAs 'stocking', 'config', 'Static', ( UserIdKey: 'user', StocksPerRequest : 2 )
      stocking.StockDownloader.resetCallHistory( )
      chrome.storage.local.clear( )
      chrome.storage.local.setDirect ( user: 'test' )
      stocking.config.Dynamic.load ( ) ->
         done( )

   afterEach ( ) ->
      stocking.StockDownloader = stockDownloader
      stocking.config.Static   = staticConfig

   it 'シンプルな呼び出し', ( done ) ->
      stocking.StockDownloader.setResponseData [
         ( 
            page: 1,
            stocks: [ 
               createDummyStock( 'u1', 't1', [ 't1', 't2' ] )
            ]
         )
      ]

      stocking.Stocks.update false, ( ) ->
         expect( stocking.Stocks.getAll( ) ).toEqual [
            ( url: 'u1', title: 't1', tags: [ 't1', 't2' ] ) 
         ]
         expect( chrome.storage.local.getDirect 'stocks' ).toEqual [
            ( url: 'u1', title: 't1', tags: [ 't1', 't2' ] ) 
         ]
         expect( stocking.StockDownloader.getCallHistory( ) ).toEqual [ 1 ]
         done( )

   it '2ページに及ぶ呼び出し(2ページ目の記事無)', ( done ) ->
      stocking.StockDownloader.setResponseData [
         ( 
            page: 1,
            stocks: [ 
               createDummyStock( 'u1', 't1', [ 'tag1', 'tag2' ] )
               createDummyStock( 'u2', 't2' )
            ]
         )
         (
            page: 2,
            stocks: [ ]
         )
      ]

      stocking.Stocks.update false, ( ) ->
         expect( stocking.Stocks.getAll( ) ).toEqual [
            ( url: 'u1', title: 't1', tags: [ 'tag1', 'tag2' ] ) 
            ( url: 'u2', title: 't2', tags: [ ] ) 
         ]
         expect( chrome.storage.local.getDirect 'stocks' ).toEqual [
            ( url: 'u1', title: 't1', tags: [ 'tag1', 'tag2' ] ) 
            ( url: 'u2', title: 't2', tags: [ ] ) 
         ]
         expect( stocking.StockDownloader.getCallHistory( ) ).toEqual [ 1, 2 ]
         done( ) 

   it '2ページに及ぶ呼び出し(2ページ目の記事有)', ( done ) ->
      stocking.StockDownloader.setResponseData [
         ( 
            page: 1,
            stocks: [ 
               createDummyStock( 'u1', 't1', [ 'tag1', 'tag2' ] )
               createDummyStock( 'u2', 't2' )
            ]
         )
         (
            page: 2,
            stocks: [
               createDummyStock( 'u3', 't3', [ 'tag3' ] )
            ]
         )
      ]

      stocking.Stocks.update false, ( ) ->
         expect( stocking.Stocks.getAll( ) ).toEqual [
            ( url: 'u1', title: 't1', tags: [ 'tag1', 'tag2' ] ) 
            ( url: 'u2', title: 't2', tags: [ ] ) 
            ( url: 'u3', title: 't3', tags: [ 'tag3' ] ) 
         ]
         expect( chrome.storage.local.getDirect 'stocks' ).toEqual [
            ( url: 'u1', title: 't1', tags: [ 'tag1', 'tag2' ] ) 
            ( url: 'u2', title: 't2', tags: [ ] ) 
            ( url: 'u3', title: 't3', tags: [ 'tag3' ] ) 
         ]
         expect( stocking.StockDownloader.getCallHistory( ) ).toEqual [ 1, 2 ]
         done( )

   it 'エラーが発生した場合, 保持しているストックの内容を上書きしないこと', ( done ) ->
      stocking.StockDownloader.setResponseData [
         ( 
            page: 1,
            stocks: [ 
               createDummyStock( 'u1', 't1', [ 'tag1', 'tag2' ] )
               createDummyStock( 'u2', 't2' )
            ]
         )
         (
            page: 2,
            stocks: [
               createDummyStock( 'u3', 't3', [ 'tag3' ] )
            ]
         )
      ]

      stocking.Stocks.update false, ( ) ->
         expect( stocking.Stocks.getAll( ) ).toEqual [
            ( url: 'u1', title: 't1', tags: [ 'tag1', 'tag2' ] ) 
            ( url: 'u2', title: 't2', tags: [ ] ) 
            ( url: 'u3', title: 't3', tags: [ 'tag3' ] ) 
         ]
         expect( chrome.storage.local.getDirect 'stocks' ).toEqual [
            ( url: 'u1', title: 't1', tags: [ 'tag1', 'tag2' ] ) 
            ( url: 'u2', title: 't2', tags: [ ] ) 
            ( url: 'u3', title: 't3', tags: [ 'tag3' ] ) 
         ]
         expect( stocking.StockDownloader.getCallHistory( ) ).toEqual [ 1, 2 ]
         stocking.StockDownloader.resetCallHistory( )

         stocking.StockDownloader.setResponseData [
            ( page: 1, stocks: null ) # エラー
         ]

         stocking.Stocks.update false, ( ) ->
            expect( stocking.Stocks.getAll( ) ).toEqual [
               ( url: 'u1', title: 't1', tags: [ 'tag1', 'tag2' ] ) 
               ( url: 'u2', title: 't2', tags: [ ] ) 
               ( url: 'u3', title: 't3', tags: [ 'tag3' ] ) 
            ]
            expect( chrome.storage.local.getDirect 'stocks' ).toEqual [
               ( url: 'u1', title: 't1', tags: [ 'tag1', 'tag2' ] ) 
               ( url: 'u2', title: 't2', tags: [ ] ) 
               ( url: 'u3', title: 't3', tags: [ 'tag3' ] ) 
            ]
            expect( stocking.StockDownloader.getCallHistory( ) ).toEqual [ 1 ]
            done( )
