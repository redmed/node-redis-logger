log = require( '../app/logger/index' )


log.init( 'log.json' )

logger = log.getLogger( {
    category: 'express'
} )
anotherLogger = log.getLogger()
fileLogger = log.getLogger( {
    category: 'file-logger'
    errorLevel: 'INFO'
} )

logger.trace( 'Entering %d cheese %d testing', 1, 2 )
logger.debug( 'Got cheese.' )
logger.info( 'Cheese is Gouda.' )
logger.warn( 'Cheese is quite smelly.' )
logger.error( 'Cheese is too ripe!' )
logger.fatal( 'Cheese was breeding ground for listeria.' )

anotherLogger.info( 'Getting a info...' )
anotherLogger.debug( 'Getting a debug...' )
anotherLogger.error( 'Cheese is too ripe!' )
anotherLogger.fatal( 'Cheese was breeding ground for listeria.' )

fileLogger.trace( 'Entering %d cheese %d testing', 1, 2 )
fileLogger.debug( 'Got cheese.' )
fileLogger.info( 'Cheese is Gouda.' )
fileLogger.warn( 'Cheese is quite smelly.' )
fileLogger.error( 'Cheese is too ripe!' )
fileLogger.fatal( 'Cheese was breeding ground for listeria.' )
