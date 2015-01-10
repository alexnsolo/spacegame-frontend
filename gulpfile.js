'use strict';

var gulp       = require('gulp'),
    bowerFiles = require('main-bower-files'),
    path       = require('path'),
    open       = require('open'),
    fs         = require('fs'),
    chalk      = require('chalk'),
    args       = require('yargs').argv,
    map        = require('map-stream'),
    browserSync = require('browser-sync'),
    runSequence = require('run-sequence'),
    plugins = require('gulp-load-plugins')();

// chalk config
var errorLog  = chalk.red.bold,
    hintLog   = chalk.blue,
    changeLog = chalk.red;

var SETTINGS = {
    src: {
        app: 'app/',
        scripts: 'app/scripts/',
        images: 'app/images/',
        bower: 'bower_components/'
    },
    build: {
        app: 'build/',
        images: 'build/images/',
        bower: 'build/bower/'
    },
    coffee: 'tmp/coffee/'
};

var bowerConfig = {
    paths: {
        bowerDirectory: SETTINGS.src.bower,
        bowerrc: '.bowerrc',
        bowerJson: 'bower.json'
    }
};

//server and live reload config
var serverConfig = {
    root: SETTINGS.build.app,
    host: 'localhost',
    port: 9000,
    livereload: true
};

// Flag for generating production code.
var isProduction = args.type === 'production';


/*============================================================
=>                          Server
============================================================*/

gulp.task('server', function () {

    console.log('------------------>>>> firing server  <<<<-----------------------');
    plugins.connect.server(serverConfig);

    console.log('Started connect web server on http://localhost:' + serverConfig.port + '.');
    // open('http://localhost:' + serverConfig.port);
});

gulp.task('tasks', plugins.taskListing);


/*============================================================
=                          Concat                           =
============================================================*/

gulp.task('concat', ['concat:bower', 'concat:js']);


gulp.task('concat:bower', function () {
    console.log('-------------------------------------------------- CONCAT :bower');

    var jsFilter = plugins.filter('**/*.js'),
        cssFilter = plugins.filter('**/*.css'),
        assetsFilter = plugins.filter(['!**/*.js', '!**/*.css', '!**/*.sass']);

    var stream = gulp.src(bowerFiles(bowerConfig), {base: SETTINGS.src.bower})
        .pipe(jsFilter)
        .pipe(plugins.concat('bower.js'))
        .pipe(gulp.dest(SETTINGS.build.bower))
        .pipe(jsFilter.restore())
        .pipe(cssFilter)
        .pipe(plugins.sass())
        .pipe(plugins.concat('bower.css'))
        .pipe(gulp.dest(SETTINGS.build.bower))
        .pipe(cssFilter.restore())
        .pipe(assetsFilter)
        .pipe(gulp.dest(SETTINGS.build.bower))
        .pipe(assetsFilter.restore())
        .pipe(plugins.connect.reload());
    return stream;
});

gulp.task('convert:coffee', function () {

    console.log('-------------------------------------------------- CONVERT :coffee');

    // Callback to show error
    var showError = function (err) {
        console.log(errorLog('\n Coffee file has error clear it to see changes, see below log ------------->>> \n'));
        console.log(errorLog(err));
    };

    var stream = gulp.src([SETTINGS.src.scripts + '*.coffee', SETTINGS.src.scripts + '**/*.coffee'])
       .pipe(plugins.plumber(showError))
       .pipe(plugins.coffee({bare: true}))
       .pipe(gulp.dest(SETTINGS.coffee))
       .pipe(plugins.connect.reload());
    return stream;
});


gulp.task('concat:js', ['convert:coffee'], function () {

    // Callback to show error
    var showError = function (err) {
        console.log(errorLog('\n JS file has error clear it to see changes, see below log ------------->>> \n'));
        console.log(errorLog(err));
    };

    console.log('-------------------------------------------------- CONCAT :js');
    gulp.src([SETTINGS.src.scripts + '*.js', SETTINGS.src.scripts + '**/*.js', SETTINGS.coffee + '*.js', SETTINGS.coffee + '**/*.js'])
        .pipe(plugins.concat('app.js'))
        .pipe(gulp.dest(SETTINGS.build.app))
        .pipe(plugins.connect.reload());
});

/*============================================================
=                          Minify                           =
============================================================*/

gulp.task('image:min', function () {
    gulp.src(SETTINGS.src.images + '**')
        .pipe(plugins.imagemin())
        .pipe(gulp.dest(SETTINGS.build.images))
        .pipe(plugins.connect.reload());
});


/*============================================================
=                           Copy                            =
============================================================*/

gulp.task('copy', ['copy:html', 'copy:css', 'copy:images']);


gulp.task('copy:html', function () {

    console.log('-------------------------------------------------- COPY :html');
    gulp.src(SETTINGS.src.app + '*.html')
        .pipe(plugins.if(isProduction, plugins.minifyHtml({comments: false, quotes: true, spare: true, empty: true, cdata: true})))
        .pipe(gulp.dest(SETTINGS.build.app))
        .pipe(plugins.connect.reload());
});

gulp.task('copy:css', function () {

    console.log('-------------------------------------------------- COPY :css');
    gulp.src(SETTINGS.src.app + 'app.css')
        .pipe(gulp.dest(SETTINGS.build.app))
        .pipe(plugins.connect.reload());
});

gulp.task('copy:images', function () {

    console.log('-------------------------------------------------- COPY :images');
    gulp.src([SETTINGS.src.images + '*.*', SETTINGS.src.images + '**/*.*'])
        .pipe(gulp.dest(SETTINGS.build.images));
});


/*=========================================================================================================
=                                               Watch

    Incase the watch fails due to limited number of watches available on your sysmtem, the execute this
    command on terminal

    $ echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
=========================================================================================================*/

gulp.task('watch', function () {

    console.log('watching all the files.....');

    var watchedFiles = [];

    watchedFiles.push(gulp.watch([SETTINGS.src.scripts + '*.js', SETTINGS.src.scripts + '**/*.js'],  ['concat:js']));

    watchedFiles.push(gulp.watch([SETTINGS.src.scripts + '*.coffee', SETTINGS.src.scripts + '**/*.coffee'],  ['concat:js']));

    watchedFiles.push(gulp.watch([SETTINGS.src.app + '*.html'], ['copy:html']));

    watchedFiles.push(gulp.watch([SETTINGS.src.app + '*.css'],  ['copy:css']));

    watchedFiles.push(gulp.watch([SETTINGS.src.images + '*.*', SETTINGS.src.images + '**/*.*'], ['copy:images']));

    watchedFiles.push(gulp.watch([SETTINGS.src.bower + '*.js', SETTINGS.src.bower + '**/*.js'], ['concat:bower']));

    // Just to add log messages on Terminal, in case any file is changed
    var onChange = function (event) {
        if (event.type === 'deleted') {
            runSequence('clean');
            setTimeout(function () {
                runSequence('copy', 'concat', 'watch');
            }, 500);
        }
        console.log(changeLog('-------------------------------------------------->>>> File ' + event.path + ' was ------->>>> ' + event.type));
    };

    watchedFiles.forEach(function (watchedFile) {
        watchedFile.on('change', onChange);
    });

});


/*============================================================
=                             Clean                          =
============================================================*/

var cleanFiles = function (files, logMessage) {
    console.log('-------------------------------------------------- CLEAN :' + logMessage);
    gulp.src(files, {read: false})
        .pipe(plugins.rimraf({force: true}));
};

gulp.task('clean', function () {
    cleanFiles([SETTINGS.build.app], 'all files');
    cleanFiles([SETTINGS.coffee], 'coffee tmp');
});


/*============================================================
=                             Zip                          =
============================================================*/

gulp.task('zip', function () {
    gulp.src([SETTINGS.build.app + '*', SETTINGS.build.app + '**/*'])
        .pipe(plugins.zip('build-' + new Date() + '.zip'))
        .pipe(gulp.dest('./zip/'));

    setTimeout(function () {
        runSequence('clean:zip');
    }, 500); // wait for file creation

});

/*============================================================
=                             Start                          =
============================================================*/


gulp.task('build', function () {
    console.log(hintLog('-------------------------------------------------- BUILD - Development Mode'));
    runSequence('copy', 'concat', 'watch');
});

gulp.task('build:prod', function () {
    console.log(hintLog('-------------------------------------------------- BUILD - Production Mode'));
    isProduction = true;
    runSequence('copy', 'concat', 'watch');
});

gulp.task('default', ['build', 'server']);

// Just in case you are too lazy to type: $ gulp --type production
gulp.task('prod', ['build:prod', 'server']);



/*============================================================
=                       Browser Sync                         =
============================================================*/

gulp.task('bs', function () {
    browserSync.init([SETTINGS.build.app + 'index.html', SETTINGS.build + 'templates/*.html', SETTINGS.build.css + '*css', SETTINGS.build.scripts + '*.js'], {
        proxy: {
            host: '127.0.0.1',
            port: serverConfig.port
        }
    });
});
