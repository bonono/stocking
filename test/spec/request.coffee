'use strict'

describe 'stocking.Requestクラスのテスト', ( ) ->

   beforeEach ( done ) ->
      done( )

   it 'URL組み立てテスト(パラメータ無)', ( done ) ->
      mock = new mocks.MockXMLHttpRequest
      req = new stocking.Request mock
      req.start 'http://test', { }, ( -> )

      expect( mock.getUrl( ) ).toBe 'http://test'
      done( )

   it 'URL組み立てテスト(パラメータ有)', ( done ) ->
      mock = new mocks.MockXMLHttpRequest
      req = new stocking.Request mock
      req.start 'http://test', ( name: 'TESTUSER', age: 23 ), ( -> )

      expect( mock.getUrl( ) ).toBe 'http://test?name=TESTUSER&age=23'
      done( )

   it 'ヘッダ設定テスト', ( done ) ->
      mock = new mocks.MockXMLHttpRequest
      req = new stocking.Request mock
      req.setHeader 'ETag', 'foobar1234'
      req.start 'http://test', { }, ( -> )

      expect( mock.getRequestHeader 'ETag' ).toBe 'foobar1234'
      done( )

   it 'レスポンス取得テスト(200)', ( done ) ->
      mock = new mocks.MockXMLHttpRequest
      req = new stocking.Request mock
      req.start 'http://test', { }, ( res ) ->
         expect( res.status ).toBe 200
         expect( res.text ).toBe 'fooooooooooooo'
         expect( res.getHeader 'ETag' ).toBe 'baaaaaaaar'
         done( )
      
      mock.setStatus 200
      mock.setResponse 'fooooooooooooo'
      mock.setResponseHeader 'ETag', 'baaaaaaaar'
      mock.resume( )

   it 'レスポンス取得テスト(404)', ( done ) ->
      mock = new mocks.MockXMLHttpRequest
      req = new stocking.Request mock
      req.start 'http://test', { }, ( res ) ->
         expect( res.status ).toBe 404
         expect( res.text ).toBe 'not found'
         done( )
      
      mock.setStatus 404
      mock.setResponse 'not found'
      mock.resume( )
