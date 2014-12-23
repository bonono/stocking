'use strict'

describe 'stocking.StringArrayクラスのテスト', ( ) ->
   it '検索', ( ) ->
      strings = new stocking.StringArray [
         '入門MySQL'
         '学習MyISAM'
         '書いて学ぶJavascript'
         'javascriptのプロトタイプについて'
         'Androidアプリを書こう(java)'
         'Travis CIを使う'
         'JenkinsでCIを行う'
         'JAPANESE'
         'monitoring server'
         'MySQLパフォーマンスチューニング'
      ]

      expect( strings.search 'm' ).toEqual [
         '入門MySQL'
         '学習MyISAM'
         'monitoring server'
         'MySQLパフォーマンスチューニング'
      ]

      expect( strings.search 'my' ).toEqual [
         '入門MySQL'
         '学習MyISAM'
         'MySQLパフォーマンスチューニング'
      ]

      expect( strings.search 'mys' ).toEqual [
         '入門MySQL'
         'MySQLパフォーマンスチューニング'
      ]

      expect( strings.search 'mysql' ).toEqual [
         '入門MySQL'
         'MySQLパフォーマンスチューニング'
      ]

      expect( strings.search 'mysqla' ).toEqual [ ]
