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
   matched = lib.search text

   suggested = [ ]
   for stock in matched
      description = stock.title.replace new RegExp( text, 'i' ), ( m ) -> "<match>#{m}</match>"
      description += " - <dim>" + stock.tags.join( ", " ) + "</dim>" if stock.tags.length > 0

      suggested.push (
         content     : stock.title
         description : description
      )

   suggest suggested

# 確定時のイベントハンドラ
chrome.omnibox.onInputEntered.addListener ( text ) ->
   chrome.tabs.query ( active: true ), ( tabs ) ->
      if tabs.length > 0

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

         chrome.tabs.update tabs[ 0 ].id, ( url: url )
