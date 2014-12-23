module.exports = function(config) {
   config.set({

      basePath: '',

      browsers: ['PhantomJS'],
      frameworks: ['jasmine-jquery', 'jasmine'],

      exclude: [ ],
      files: [
         'script/coffee/stocking.coffee',
         'script/coffee/**/*.coffee',
         'test/spec/**/*.coffee',
         { pattern: 'test/fixture/**/*', included: false }
      ],

      preprocessors: {
         '**/*.coffee': [ 'coffee' ]
      },

      coffeePreprocessor: {
         transformPath: function( path ) {
            return path.replace( /\.coffee$/, '.js' );
         }
      },

      reporters: ['progress'],

      port: 9876,
      colors: true,
      logLevel: config.LOG_INFO,

      autoWatch: false,
      singleRun: true
   });
};
