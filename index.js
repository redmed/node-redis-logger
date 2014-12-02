/**
 * @file:
 * @author: redmed(qiaogang@baidu.com)
 * 14/12/2
 */

require('coffee-script/register');

exports.logger = require('./app/logger/index.coffee')
exports.cache = require('./app/redis-cache/index.coffee')
