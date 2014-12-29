'use strict'

defineAs 'stocking', 'config', 'Static', (
   StocksApi        : 'http://test/:user_id/stocks'
   UserIdKey        : 'user'
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

      stocking.StockDownloader.start ( stocks ) ->
         expect( stocks ).toEqual [
            ( title: 't1', url: 'u1', tags: [ ( name: 'tag1' ) ] )
            ( title: 't2', url: 'u2', tags: [ ( name: 'tag2' ) ] )
            ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
         ]
         expect( mock.getUrl( ).split( '?' )[ 0 ] ).toBe 'http://test/testuser/stocks'
         done( )
      , req

      expect( mock.getRequestHeader 'If-None-Match' ).toBe ''

      mock.setStatus 200
      mock.setResponse JSON.stringify( [
         ( title: 't1', url: 'u1', tags: [ ( dummy: 'd1', name: 'tag1' ) ] )
         ( title: 't2', url: 'u2', tags: [ ( dummy: 'd2', name: 'tag2' ) ] )
         ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
      ] )
      mock.resume 50

   it 'ETag付き', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      chrome.storage.local.setDirect 'etag-v1': 'foobar1234'

      stocking.StockDownloader.start ( stocks ) ->
         expect( stocks ).toEqual [
            ( title: 't1', url: 'u1', tags: [ ( name: 'tag1' ) ] )
            ( title: 't2', url: 'u2', tags: [ ( name: 'tag2' ) ] )
            ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
         ]
         expect( mock.getRequestHeader 'If-None-Match' ).toBe 'foobar1234'
         done( )
      , req

      mock.setStatus 200
      mock.setResponse JSON.stringify( [
         ( title: 't1', url: 'u1', tags: [ ( dummy: 'd1', name: 'tag1' ) ] )
         ( title: 't2', url: 'u2', tags: [ ( dummy: 'd2', name: 'tag2' ) ] )
         ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
      ] )
      mock.resume 50

   it 'ETag付き(エラー)', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      chrome.storage.local.setDirect 'etag-v1': 'foobar1234'

      chrome.storage.local.raiseErrorNext( )
      stocking.StockDownloader.start ( stocks ) ->
         expect( stocks ).toEqual [
            ( title: 't1', url: 'u1', tags: [ ( name: 'tag1' ) ] )
            ( title: 't2', url: 'u2', tags: [ ( name: 'tag2' ) ] )
            ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
         ]
         expect( mock.getRequestHeader 'If-None-Match' ).toBe ''
         done( )
      , req

      mock.setStatus 200
      mock.setResponse JSON.stringify( [
         ( title: 't1', url: 'u1', tags: [ ( dummy: 'd1', name: 'tag1' ) ] )
         ( title: 't2', url: 'u2', tags: [ ( dummy: 'd2', name: 'tag2' ) ] )
         ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
      ] )
      mock.resume 50

   it 'ETag返却(status: 200)', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      stocking.StockDownloader.start ( stocks ) ->
         expect( stocks ).toEqual [
            ( title: 't1', url: 'u1', tags: [ ( name: 'tag1' ) ] )
            ( title: 't2', url: 'u2', tags: [ ( name: 'tag2' ) ] )
            ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
         ]
         expect( mock.getRequestHeader 'If-None-Match' ).toBe ''
         setTimeout ( ->
            expect( chrome.storage.local.getDirect 'etag-v1' ).toBe 'hogehoge'
            expect( chrome.storage.local.getDirect 'response-v1' ).toBe JSON.stringify( [
               ( title: 't1', url: 'u1', tags: [ ( name: 'tag1' ) ] )
               ( title: 't2', url: 'u2', tags: [ ( name: 'tag2' ) ] )
               ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
            ] )
            done( )
         ), 10
      , req

      mock.setStatus 200
      mock.setResponse JSON.stringify( [
         ( title: 't1', url: 'u1', tags: [ ( dummy: 'd1', name: 'tag1' ) ] )
         ( title: 't2', url: 'u2', tags: [ ( dummy: 'd2', name: 'tag2' ) ] )
         ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
      ] )
      mock.setResponseHeader 'ETag', 'hogehoge'
      mock.resume 50

   it 'ETag返却(status: 304)', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      data =
         'etag-v1' : 'old'
         'response-v1' : JSON.stringify( [
               ( title: 't1', url: 'u1', tags: [ ( name: 'tag1' ) ] )
               ( title: 't2', url: 'u2', tags: [ ( name: 'tag2' ) ] )
               ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
         ] )

      chrome.storage.local.setDirect data

      stocking.StockDownloader.start ( stocks ) ->
         expect( stocks ).toEqual [
            ( title: 't1', url: 'u1', tags: [ ( name: 'tag1' ) ] )
            ( title: 't2', url: 'u2', tags: [ ( name: 'tag2' ) ] )
            ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
         ]
         expect( mock.getRequestHeader 'If-None-Match' ).toBe 'old'

         setTimeout ( ->
            expect( chrome.storage.local.getDirect 'etag-v1' ).toBe 'old'
            expect( chrome.storage.local.getDirect 'response-v1' ).toBe JSON.stringify( [
               ( title: 't1', url: 'u1', tags: [ ( name: 'tag1' ) ] )
               ( title: 't2', url: 'u2', tags: [ ( name: 'tag2' ) ] )
               ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
            ] )
            done( )
         ), 10
      , req

      mock.setStatus 304
      mock.setResponseHeader 'ETag', 'new' # 上書きしていないことを確認するために返してみる(本来は返らない)
      mock.resume 50 

   it 'レスポンスエラー', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      data =
         'etag-v1' : 'old'
         'response-v1' : JSON.stringify( [
               ( title: 't1', url: 'u1', tags: [ ( name: 'tag1' ) ] )
               ( title: 't2', url: 'u2', tags: [ ( name: 'tag2' ) ] )
               ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
         ] )

      chrome.storage.local.setDirect data

      stocking.StockDownloader.start ( stocks ) ->
         expect( stocks ).toBeNull( )
         setTimeout ( ->
            expect( chrome.storage.local.getDirect 'etag-v1' ).toBe 'old'
            expect( chrome.storage.local.getDirect 'response-v1' ).toBe JSON.stringify( [
               ( title: 't1', url: 'u1', tags: [ ( name: 'tag1' ) ] )
               ( title: 't2', url: 'u2', tags: [ ( name: 'tag2' ) ] )
               ( title: 't3', url: 'u3', tags: [ ( name: 'tag3' ) ] )
            ] )
            done( )
         ), 10
      , req

      mock.setStatus 500
      mock.setResponse 'ERROR'
      mock.resume 50

   it 'ユーザー設定なし状態でのテスト', ( done ) ->

      mock = new mocks.MockXMLHttpRequest
      req  = new stocking.Request mock

      chrome.storage.local.clear( )
      stocking.StockDownloader.start ( stocks ) ->
         expect( stocks ).toBeNull( )
         done( )
      , req

      mock.resume 50
