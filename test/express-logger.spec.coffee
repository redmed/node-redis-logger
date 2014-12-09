# load modules
logger = require('../app/logger/index')
express = require("express")
app = express()

LOG_EXPRESS_CATEGORY = 'express-log'

logger.setConfig({
    'appenders': [
        {
            'type': 'file'
            'filename': 'express-log.log'
            'category': LOG_EXPRESS_CATEGORY
            "maxLogSize": 2048000
        },
        {
            'type': 'console',
            'layout': {
                'type': 'pattern',
                'pattern': '[%d] [%p] %c - %m'
            }
        }
    ]
}, {
    cwd: './logs'
})

# config
###
    AUTO LEVEL DETECTION
    http responses 3xx, level = WARN
    http responses 4xx & 5xx, level = ERROR
    else.level = INFOex
###
app.use(logger.connectLogger(logger.getLogger( LOG_EXPRESS_CATEGORY ), {level: 'auto'} ))

# route
app.get('/', (req,res) ->
    res.send('hello world')
)

# start app
app.listen(5000)

console.log('server runing at localhost:5000')
console.log('Simulation of normal response: goto localhost:5000')
console.log('Simulation of error response: goto localhost:5000/xxx')