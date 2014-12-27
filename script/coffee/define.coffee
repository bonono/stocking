'use strict'

window.define = ( ) ->
   len = arguments.length

   parent = window
   for i in [ 0 ... len - 1 ]
      ns = arguments[ i ]
      parent[ ns ] = { } unless parent[ ns ]?
      parent = parent[ ns ]

   module = arguments[ len - 1 ]
   parent[ module.name ] = module

window.defineAs = ( ) ->
   len = arguments.length

   parent = window
   for i in [ 0 ... len - 2 ]
      ns = arguments[ i ]
      parent[ ns ] = { } unless parent[ ns ]?
      parent = parent[ ns ]

   parent[ arguments[ len - 2 ] ] = arguments[ len - 1 ]
