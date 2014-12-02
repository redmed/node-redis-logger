_redis = require 'redis'
_Q = require 'q'
_ = require 'lodash'

ErrorInfo =
    JSON_STRINGIFY: 'Error on JSON.stringify'
    JSON_PARSE: 'Error on JSON.parse'
    SET: 'Error on SET'
    GET: 'Error on GET'
    DEL: 'Error on DEL'
    NO_KEY: 'Error on need a key'
    EXIST: 'Error on check'

class RedisCache
    constructor: ( options = {} ) ->
        @client = _redis.createClient( options.port or 6379,
            options.host or '127.0.0.1',
            options )
        @prefix = options.prefix or 'BD_cache:'
        @database = if !_.isNumber( options.database ) then 0 else options.database

        @_initEvent()
        @select( @database )

        return

    _initEvent: () ->
        @client.on( 'connect', ( err ) ->
#            console.log( 'RedisCache is Connecting...' )
        )

        @client.on( 'ready', ( err ) ->
#            console.log( 'RedisCache is READY!' )
        )

        @client.on( 'error', ( err ) ->
#            console.log( 'RedisCache is Error ' + err )
        )

    _stringify: ( obj ) ->
        try
            str = JSON.stringify( obj )
        catch
            throw new Error( ErrorInfo.JSON_STRINGIFY )


    _strKey: ( key ) ->
        @prefix + @_stringify( key )


    ###
        存储Key-Value值对
        @param {string} key
        @param {*} value
        @param {Object} options
        @param {=number} options.ttl time to live (seconds)
    ###
    set: ( key, value, options = {} ) ->
        defer = _Q.defer()

        if !key
            throw new Error( ErrorInfo.NO_KEY )

        _key = @_strKey( key )

        data = @_stringify( value )

        _ttl = options.ttl

        if _ttl and _ttl > 0
            @client.setex( _key, _ttl, data, ( err, reply ) ->
                if err
                    defer.reject( "#{ErrorInfo.SET} #{err}" )
                else
                    defer.resolve( reply )
            )
        else
            @client.set( _key, data, ( err, reply ) ->
                if err
                    defer.reject( "#{ErrorInfo.SET} #{err}" )
                else
                    defer.resolve( reply )
            )

        defer.promise


    ###
        获取指定Key值
        @param {string} key
    ###
    get: ( key ) ->
        defer = _Q.defer()

        if !key
            throw new Error( ErrorInfo.NO_KEY )

        _key = @_strKey( key )

        @client.get( _key, ( err, result ) ->
            if err
                defer.reject( "#{ErrorInfo.GET} #{key} #{err}" )
            else
                if result
                    try
                        data = JSON.parse( result )
                        defer.resolve( data )
                    catch err
                        defer.resolve( result )
#                        defer.reject( "#{ErrorInfo.JSON_PARSE} #{key} #{result}" )
                else
                    defer.resolve()
        )

        defer.promise


    ###
        删除指定Key值
        @param {string} key
    ###
    del: ( key ) ->
        defer = _Q.defer()

        if !key
            throw new Error( ErrorInfo.NO_KEY )

        _key = if !_.isArray( key ) then [ key ] else key

        _key = _key.map( ( k ) ->
            @_strKey( k )
        , @ )

        _args = _key.concat( ( err, reply ) ->
            if err
                defer.reject( "#{ErrorInfo.DEL} #{err}" )
            else
                defer.resolve( reply )
        )

        @client.del.apply( @client, _args )

        defer.promise


    ###
        清除当前数据库
    ###
    clear: () ->
        defer = _Q.defer()

        @client.flushdb( () ->
            defer.resolve()
        )

        defer.promise


    ###
        获取指定的指定Key

        Supported glob-style patterns:

            h?llo matches hello, hallo and hxllo
            h*llo matches hllo and heeeello
            h[ae]llo matches hello and hallo, but not hillo
            Use \ to escape special characters if you want to match them verbatim.
    ###
    getKeys: ( pattern = '*' ) ->
        defer = _Q.defer()

        @client.keys( pattern, ( err, result ) ->
            if err
                defer.reject( err )
            else
                defer.resolve( result )
        )

        defer.promise


    ###
        判断Key是否存在
    ###
    isExist: ( key ) ->
        defer = _Q.defer()

        @client.exists( @_strKey( key ), ( err, reply ) ->
            if err or reply is 0
                defer.reject( 0 )
            else
                defer.resolve( reply )
        )

        defer.promise


    ###
        断开数据库
    ###
    quit: () ->
        defer = _Q.defer()

        @client.quit( ( err, reply ) ->
            if err
                defer.reject()
            else
                defer.resolve( reply )
        )

        defer.promise


    ###
        持久化数据
    ###
    save: () ->
        defer = _Q.defer()

        @client.bgsave( ( err, reply ) ->
            if err
                defer.reject()
            else
                defer.resolve( reply )
        )

        defer.promise


    ###
        选择数据库
    ###
    select: ( database ) ->
        @client.select( database )


module.exports = RedisCache
