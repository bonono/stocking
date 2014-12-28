'use strict'

class MockNotifications

   @create: ( id, options, callback ) ->
      # とりあえずID返すだけの実装
      return if id? and id.length > 0 then id else +new Date

defineAs 'chrome', 'notifications', MockNotifications
