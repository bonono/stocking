'use strict'

defineAs 'stocking', 'Healthful', false
defineAs 'stocking', 'waitLaunching', ( callback ) ->
   timer = setInterval ( ->
      if stocking.Healthful
         clearInterval timer
         callback( )
   ), 50

# 応急用機能
defineAs 'stocking', 'clearAllData', ( ) ->
   chrome.storage.local.clear ( ) ->
      chrome.runtime.reload( )

# 各種設定ファイルの読み込み
stocking.config.Static.load ( success ) ->
   return unless success
   stocking.config.Dynamic.load ( success ) ->
      return unless success
      stocking.Stocks.setup ( success ) ->
         stocking.Healthful = success

chrome.omnibox.onInputStarted.addListener ( ) ->
   if stocking.Utils.getUser( )?
      description = 'Qiitaでストックを検索'
   else
      description = 'オプションページでユーザー設定をしましょう!'

   chrome.omnibox.setDefaultSuggestion ( description: 'Qiitaでストックを検索' )

# 検索バー入力時のイベントハンドラ
chrome.omnibox.onInputChanged.addListener ( text, suggest ) ->
   if not stocking.Utils.getUser( )?
      defaultText = 'オプションページでユーザー設定をしましょう!'
   else if text.length > 0
      defaultText = 'Qiitaでストックを検索: <match>' + text + '</match>'
   else
      defaultText = 'Qiitaでストックを検索'

   chrome.omnibox.setDefaultSuggestion ( description: defaultText )

   lib     = new stocking.StockLibrary stocking.Stocks.getAll( )
   matched = lib.search( text ).slice 0, 5 # 最高5件

   suggested = [ ]
   for stock in matched
      if stocking.Utils.needEscape stock.title
         description = stocking.Utils.escape stock.title # 処理が面倒になるので, エスケープが必要なタイトルはmatchタグで囲わずエスケープだけ行う
      else
         description = stock.title.replace new RegExp( text, 'i' ), ( m ) -> "<match>#{m}</match>"
      description += " - <dim>" + stock.tags.map( stocking.Utils.escape ).join( ", " ) + "</dim>" if stock.tags.length > 0

      suggested.push (
         content     : stock.title
         description : description
      )

   suggest suggested

getSelectedTab = ( callback ) ->
   chrome.tabs.query ( currentWindow: true, highlighted: true ), ( tabs ) ->
      # タブがないことはないはずだが, ない場合はコールバックが呼ばれない
      callback tabs[ 0 ] if tabs.length > 0

# 確定時のイベントハンドラ
chrome.omnibox.onInputEntered.addListener ( text ) ->
   getSelectedTab ( tab ) ->

      user = stocking.Utils.getUser( )
      if not user?
         # ユーザーが設定されていない場合はオプションページに飛ばす
         url = 'chrome-extension://' + chrome.runtime.id + '/html/option.html'
      else
         stock = stocking.Stocks.getByTitle text
         if stock?
            url = stock.url
         else
            # ストック出ない場合はQiita.comのページに飛ばす
            if text.length > 0
               url = 'http://qiita.com/search?stocked=1&q=' + text
            else
               url = "http://qiita.com/#{user}"

      chrome.tabs.update tab.id, ( url: url )
