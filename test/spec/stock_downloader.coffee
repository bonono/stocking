'use strict'

defineAs 'stocking', 'config', 'Static', (
   StocksApi        : 'http://test/:user_id/stocks'
   UserIdKey        : 'user'
   StocksPerRequest : 20
)

describe 'stocking.StockDownloaderクラスのテスト', ( done ) ->

   beforeEach ( done ) ->
      jasmine.getFixtures( ).fixturesPath = 'base/test/fixture'
      chrome.storage.local.clear( )
      chrome.storage.local.setDirect ( user: 'testuser' )
      stocking.config.Dynamic.load ( ) ->
         done( )

   it 'リクエスト', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      stocking.StockDownloader.start 1, ( page, stocks ) ->
         expect( page ).toBe 1
         expect( stocks ).toEqual [ 'A', 'B', 'C' ]
         expect( mock.getUrl( ).split( '?' )[ 0 ] ).toBe 'http://test/testuser/stocks'
         expect( mock.getUrl( ).split( '?' )[ 1 ].split '&' ).toEqual [ 'page=1', 'per_page=20' ] # パラメータの順番が違っても通るように
         done( )
      , req

      expect( mock.getRequestHeader 'If-None-Match' ).toBe ''

      mock.setStatus 200
      mock.setResponse JSON.stringify( [ 'A', 'B', 'C' ] )
      mock.resume 50

   it 'ETag付き', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      data = { }
      data[ 'etag-page-1' ] = 'foobar1234'
      chrome.storage.local.setDirect data

      stocking.StockDownloader.start 1, ( page, stocks ) ->
         expect( page ).toBe 1
         expect( stocks ).toEqual [ 'A', 'B', 'C' ]
         expect( mock.getRequestHeader 'If-None-Match' ).toBe 'foobar1234'
         done( )
      , req

      mock.setStatus 200
      mock.setResponse JSON.stringify( [ 'A', 'B', 'C' ] )
      mock.resume 50

   it 'ETag付き(エラー)', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      data = { }
      data[ 'etag-page-1' ] = 'foobar1234'
      chrome.storage.local.setDirect data

      chrome.storage.local.raiseErrorNext( )
      stocking.StockDownloader.start 1, ( page, stocks ) ->
         expect( page ).toBe 1
         expect( stocks ).toEqual [ 'A', 'B', 'C' ]
         expect( mock.getRequestHeader 'If-None-Match' ).toBe ''
         done( )
      , req

      mock.setStatus 200
      mock.setResponse JSON.stringify( [ 'A', 'B', 'C' ] )
      mock.resume 50

   it 'ETag返却(status: 200)', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      stocking.StockDownloader.start 1, ( page, stocks ) ->
         expect( page ).toBe 1
         expect( stocks ).toEqual [ 'A', 'B', 'C' ]
         expect( mock.getRequestHeader 'If-None-Match' ).toBe ''

         setTimeout ( ->
            expect( chrome.storage.local.getDirect 'etag-page-1' ).toBe 'hogehoge'
            done( )
         ), 10
      , req

      mock.setStatus 200
      mock.setResponse JSON.stringify( [ 'A', 'B', 'C' ] )
      mock.setResponseHeader 'ETag', 'hogehoge'
      mock.resume 50

   it 'ETag返却(status: 304)', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      data = { }
      data[ 'etag-page-1' ] = 'old'
      chrome.storage.local.setDirect data

      stocking.StockDownloader.start 1, ( page, stocks ) ->
         expect( page ).toBe 1
         expect( stocks ).toEqual [ 'A', 'B', 'C' ]
         expect( mock.getRequestHeader 'If-None-Match' ).toBe 'old'

         setTimeout ( ->
            expect( chrome.storage.local.getDirect 'etag-page-1' ).toBe 'old'
            done( )
         ), 10
      , req

      mock.setStatus 304
      mock.setResponse JSON.stringify( [ 'A', 'B', 'C' ] )
      mock.setResponseHeader 'ETag', 'new'
      mock.resume 50 

   it 'レスポンスエラー', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      stocking.StockDownloader.start 1, ( page, stocks ) ->
         expect( page ).toBe 1
         expect( stocks ).toBeNull( )
         done( )
      , req

      mock.setStatus 500
      mock.setResponse JSON.stringify( [ 'A', 'B', 'C' ] )
      mock.resume 50

   it 'ユーザー設定なし状態でのテスト', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      chrome.storage.local.clear( )
      stocking.StockDownloader.start 1, ( page, stocks ) ->
         expect( page ).toBe 1
         expect( stocks ).toBeNull( )
         done( )
      , req

      mock.resume 50
