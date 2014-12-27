'use strict'

defineAs 'stocking', 'Healthful', false
defineAs 'stocking', 'waitLaunching', ( callback ) ->
   timer = setInterval ( ->
      if stocking.Healthful
         clearInterval timer
         callback( )
   ), 50

# 各種設定ファイルの読み込み
stocking.config.Static.load ( success ) ->
   return unless success
   stocking.config.Dynamic.load ( success ) ->
      return unless success
      stocking.Stocks.setup ( success ) ->
         stocking.Healthful = success

chrome.omnibox.onInputStarted.addListener ( ) ->
   chrome.omnibox.setDefaultSuggestion ( description: 'Qiitaでストックを検索' )

# 検索バー入力時のイベントハンドラ
chrome.omnibox.onInputChanged.addListener ( text, suggest ) ->
   if text.length > 0
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

         stock = stocking.Stocks.getByTitle text
         if stock?
            url = stock.url
         else
            # ストック出ない場合はQiita.comのページに飛ばす
            if text.length > 0
               url = 'http://qiita.com/search?stocked=1&q=' + text
            else
               user = stocking.config.Dynamic.get stocking.config.Static.UserIdKey
               url = "http://qiita.com/" + ( if user? then user + "/stock" else '' )

         chrome.tabs.update tabs[ 0 ].id, ( url: url )
