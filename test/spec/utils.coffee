'use strict'

describe 'stocking.Utilsクラスのテスト', ( ) ->
   it 'パスカルケース変換', ( ) ->
      expect( stocking.Utils.toPascalCase 'this_is_snake' ).toBe 'ThisIsSnake'
      expect( stocking.Utils.toPascalCase 'word' ).toBe 'Word'
