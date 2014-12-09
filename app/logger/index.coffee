_fs = require 'fs'
_path = require 'path'
log4js = require 'log4js'

# 配置文件
CONFIG_JSON = {
    'appenders': [
        {
            'type': 'dateFile',
            'filename': 'log',
            'pattern': '-yyyy-MM-dd hh.log',
            'alwaysIncludePattern': true,
            'category': 'log'
        },
        {
            'type': 'console',
            'layout': {
                'type': 'pattern',
                'pattern': '[%d] [%p] %c - %m'
            }
        }
    ],

    'levels': {
        '[all]': 'TRACE',
        'log': 'TRACE'
    }
}

# 日志输出文件路径
LOG_PATH = './logs'
# 错误级别输出
ERROR_LEVEL = 'TRACE'

mkdirIfNotExist = ( path ) ->
    if !_fs.existsSync( path )
        try
            _fs.mkdirSync( path )
        catch e
            console.error( 'Could not set up a log directory. ', e )

###
    设置全局配置
    @param {Object|string} config 设置全局配置或配置文件路径
    @param {Object=} options 设置其他配置项
    @param {string=} options.cwd 日志路径 默认为'./logs'
###
exports.setConfig = ( config = CONFIG_JSON, options = {} ) ->
    mkdirIfNotExist( options.cwd or LOG_PATH )

    log4js.configure( config, options )

    log4js

###
    获得不同类型Logger实例
    @param {string=} category log分类 可与配置文件中“appenders.category”对应
    @param {errorLevel=} errorLevel 可log的error_level 可与配置文件中“levels”对应
###
exports.getLogger = ( category, errorLevel ) ->
    logger = log4js.getLogger( category )

    if errorLevel
        logger.setLevel( errorLevel )

    logger

exports.connectLogger = ( logger, options ) ->
    log4js.connectLogger( logger, options )