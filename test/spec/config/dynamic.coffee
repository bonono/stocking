'use strict'

# 静的設定ファイルの読み取りは面倒なのでスタブで
defineAs 'stocking', 'config', 'Static', (
   UserIdKey: 'user'
)

describe 'stocking.config.Dynamicクラスのテスト', ( ) ->

   beforeEach ( done ) ->
      done( )

   it '初期化テスト(成功)', ( done ) ->
      chrome.storage.local.setDirect ( user: 'test' )
      stocking.config.Dynamic.load ( success ) ->
         expect( success ).toBeTruthy( )
         expect( stocking.config.Dynamic.get 'user' ).toBe 'test'
         done( )

   it '初期化テスト(失敗)', ( done ) ->
      chrome.storage.local.raiseErrorNext( )
      stocking.config.Dynamic.load ( success ) ->
         expect( success ).toBeFalsy( )
         done( )
