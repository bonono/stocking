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

