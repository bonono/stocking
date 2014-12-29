'use strict'

# StockDownloaderはモックと差し替える
class MockStockDownloader

   @_data = [ ]
  
   @setResponseData: ( stocks ) ->
      @_data = stocks

   @start: ( callback ) ->
      setTimeout ( => callback @_data ), 0

stockDownloader = stocking.StockDownloader
staticConfig = stocking.config.Static

createDummyStock = ( url, title, tagNames = [ ] ) ->
   stock = ( url: url, title: title, tags: [ ] )
   stock.tags.push ( name: name ) for name in tagNames
   return stock

describe 'stocking.Stocks.updateのテスト', ( ) ->

   beforeEach ( done ) ->
      defineAs 'stocking', 'StockDownloader', MockStockDownloader
      defineAs 'stocking', 'config', 'Static', ( UserIdKey: 'user' )
      chrome.storage.local.clear( )
      chrome.storage.local.setDirect ( user: 'test' )
      stocking.config.Dynamic.load ( ) ->
         done( )

   afterEach ( ) ->
      stocking.StockDownloader = stockDownloader
      stocking.config.Static   = staticConfig

   it 'シンプルな呼び出し', ( done ) ->
      stocking.StockDownloader.setResponseData [
         createDummyStock( 'u1', 't1', [ 't1', 't2' ] )
      ]

      stocking.Stocks.update false, ( ) ->
         expect( stocking.Stocks.getAll( ) ).toEqual [
            ( url: 'u1', title: 't1', tags: [ 't1', 't2' ] ) 
         ]
         expect( chrome.storage.local.getDirect 'stocks' ).toEqual [
            ( url: 'u1', title: 't1', tags: [ 't1', 't2' ] ) 
         ]
         done( )

   it 'エラーが発生した場合, 保持しているストックの内容を上書きしないこと', ( done ) ->
      stocking.StockDownloader.setResponseData [
         createDummyStock( 'u1', 't1', [ 'tag1', 'tag2' ] )
         createDummyStock( 'u2', 't2' )
         createDummyStock( 'u3', 't3', [ 'tag3' ] )
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

         stocking.StockDownloader.setResponseData null # エラー

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
            done( )
