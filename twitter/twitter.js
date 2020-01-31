var
    winston = require('winston'),
    framework = require('../framework'),
    fetchTimeline = require('./fetch'),
    TweetToEvent = require('./TweetToEvent')

var config = {
    winston : {
        all: {
          level: 'info'
        }
  }
}

const myparams = {
  screenName:  process.env.TWITTERSCREENNAME,
  count: 200,
  tweet_mode:  process.env.TWITTERTWEETMODE
}

const myopts = {
  credentials: {
    consumerKey: process.env.TWITTERCONSUMERKEY,
    consumerSecret: process.env.TWITTERCONSUMERSECRET,
    accessToken: process.env.TWITTERACCESSTOKEN,
    accessTokenSecret: process.env.TWITTERACCESSTOKENSECRET
  },
  limit:  process.env.TWITTERMAXTWEETS,
}

var twitterlogger = winston.createLogger({
    transports: [
      new winston.transports.Console()]
  });

async function retrieveTweetSet(offset, options, logger, callback) {
  logger.info("ENTERING: retrieveTweetSet, offset=" + offset);

  let all = [];

  const stream = fetchTimeline(myparams, myopts) // => Readable Stream

  stream.on('data', (tweets, index) => {
    all = all.concat(tweets);
  })

  stream.on('error', (error) => {
    logger.error("Error: " + error)
    callback(error);
  })

  stream.on('info', (info) => {
    logger.info("Done");
    callback(null, all);
  })

}

async function get() {
  return framework.generateEvents(null, null, retrieveTweetSet, TweetToEvent, null, twitterlogger)
};

module.exports = {get, config};

