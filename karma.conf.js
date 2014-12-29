module.exports = function(config) {
   config.set({

      basePath: '',

      browsers: ['PhantomJS'],
      frameworks: ['jasmine-jquery', 'jasmine'],

      exclude: [
         'script/coffee/bootstrap.coffee',
         'script/coffee/option.coffee'
      ],
      files: [
         'script/coffee/define.coffee',
         'test/mocks/**/*.coffee',
         'script/coffee/**/*.coffee',
         'test/spec/**/*.coffee'
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
