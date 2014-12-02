_async = require 'async'
_fs = require 'fs'
_path = require 'path'
_ = require 'lodash'
Cache = require '../app/redis-cache/index'

cache = new Cache( {
    prefix: 'test:'
    dbIndex: 1
} )

key = 'key'

key_2 = 'key2'

data = {
    a: '1'
    b: '2'
    c: 3
}

data_2 = {
    'nx': 'nx'
}

describe( 'RedisCache test', ()->
    expire = 1

    it( 'RedisCache.set', ( done ) ->
        cache.set( key, data ).then( ( data ) ->
            expect( 'OK' ).toEqual( data )
            done()
        )
    )

    it( 'RedisCache.get', ( done ) ->
        cache.get( key ).then( ( _data ) ->
            expect( data ).toEqual( _data )
            done()
        )
    )

    it( 'RedisCache.set@ttl=' + expire + 's', ( done ) ->
        cache.set( key, data, {
            ttl: expire
        } ).then( ( data ) ->
            expect( 'OK' ).toEqual( data )
            done()
        )
    )

    it( 'RedisCache.get@ttl before', ( done ) ->
        cache.get( key ).then( ( _data ) ->
            expect( data ).toEqual( _data )
            done()
        )
    )

    it( 'RedisCache.get@ttl after', ( done ) ->
        setTimeout( () ->
            cache.get( key ).then( ( _data ) ->
                expect( undefined ).toEqual( _data )
                done()
            )
        , (expire + 2) * 1000 )
    )

    it( 'RedisCache.del@ single key', ( done ) ->
        key = 'abc'
        val = 'def'
        cache.set( key, val ).then( () ->
            cache.del( key ).then( ( _data ) ->
                expect( 1 ).toEqual( _data )

                cache.get( key ).then( ( _data ) ->
                    expect( undefined ).toEqual( _data )
                    done()
                )
            )
        )
    )

    it( 'RedisCache.del@ multi key', ( done ) ->
        testData = [
            {
                key: 'key1'
                val: 'value1'
            }
            {
                key: 'key2'
                val: 'value2'
            }
        ]

        _async.series( [
                ( callback ) ->
                    cache.set( testData[0].key, testData[0].val )
                    .then( ( data ) ->
                        callback()
                        cache.get( testData[0].key )
                        .then( ( data ) ->
                        )
                    )
                ( callback ) ->
                    cache.set( testData[1].key, testData[1].val )
                    .then( ( data ) ->
                        callback()
                    )
            ], ( err, results ) ->
            cache.del( [ testData[0].key, testData[1].key ] ).then( ( _data ) ->
                expect( 2 ).toEqual( _data )
                done()
            )
        )
    )

    it( 'RedisCache.isExist', ( done ) ->
        key = '2134321'
        val = '5432523'
        notExistKey = 'not exist key'
        cache.set( key, val ).then( () ->

            _async.series([
                (callback) ->
                    cache.isExist( key ).then( ( _data ) ->
                        expect( 1 ).toEqual( _data )
                        callback()
                    )
                (callback) ->
                    cache.isExist( notExistKey ).fail( ( _data ) ->
                        expect( 0 ).toEqual( _data )
                        callback()
                    )
            ], (err, results) ->
                done()
            )
        )
    )

    it( 'RedisCache.save', ( done ) ->
        cache.save().then( ( data ) ->
            expect( 1 ).toBe( 1 )
            done()
        )
    )

    it( 'RedisCache.clear', ( done ) ->
        cache.clear().then( ( data ) ->
            expect( 1 ).toBe( 1 )
            done()
        )
    )

    it( 'RedisCache.quit', ( done ) ->
        cache.quit().then( ( data ) ->
            expect( 'OK' ).toBe( data )
            done()
        )
    )
)

