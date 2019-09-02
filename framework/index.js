var
    async = require("async"),
    winston = require('winston')



var logger = winston.createLogger({
      transports: [
        new winston.transports.Console()]
    });

function getEpoch(date) {
    return Math.round(date.getTime() / 1000);
  }
  
async function retrieveItems(retrieveItemSetFunc, options, callback) {
  logger.debug("ENTERING: retrieveItems");

  options = options || {};

  var coreOffset = 0,
    queuePass = true,
    passTotal = 0,
    allResults = [];

  async.whilst(
    async function() {
      passTotal++;
      return queuePass;
    },
    function(callback) {
      var passes = [],
        rc = function(callback) {
          retrieveItemSetFunc(coreOffset, options, callback);
          coreOffset += options.limit;
        };
      // TODO: This looks and feels STUPID. Alternative?
      for(var i = 0; i < options.concurrentCalls; i++) {
        passes.push(rc);
      }

      async.parallel(passes, function(error, items) {
        if(!error) {
          items.forEach(function(itemSet) {
            queuePass = (itemSet.length == options.limit);
            allResults = allResults.concat(itemSet);
          });
        }
        callback(error, items);
      });
    },
    function(error) {
      logger.info("RETRIEVED: " + allResults.length + " checkins in " + passTotal + " pass(es) of " + options.concurrentCalls + " calls each.");
      if(error) {
        logger.error(error);
        callback(error);
      }
      else {
        callback(null, allResults);
      }
    }
  );
}

function validateYear(year){
  switch (year) {
    case 2009:
    case 2010:
    case 2011:
    case 2012:
    case 2013:
    case 2014:
    case 2015:
    case 2016:
    case 2017:
    case 2018:
    case 2019:
    case "all":
    case "current":
      break;
    default:
      throw ValidationError(year + "is not a valid year");
      break;
  }

}

function parseYear(year) {
  if (typeof(year) == "number")
    return year;
  switch (year) {
    case "2009":
    case "2010":
    case "2011":
    case "2012":
    case "2013":
    case "2014":
    case "2015":
    case "2016":
    case "2017":
    case "2018":
    case "2019":
      return parseInt(year);
    case "all":
      return 0;
    case "current":
    default:
      return (new Date()).getFullYear();
  }
}


function prepareOptions(fromYear, toYear, access_token, concurrent_calls = 1) {
  var options = {
    concurrentCalls: concurrent_calls,
    before: 0,
    after: 0,
    limit: 250,
    accessToken: access_token
  };

  var y = ty = 0;

  y = parseYear(fromYear);
  toYear ? ty = parseYear(toYear) : ty = y;


  if (ty)
    {
      options.before = new Date(ty,11,31,11,59,59);
      logger.debug("beforeTimestamp: " + options.before + ", epoch: " + getEpoch(options.before));
    }
  if (y) {
      options.after =  new Date(y,0,1,0,0,0);
      logger.debug("afterTimestamp: " + options.after + ", epoch: " + getEpoch(options.after));
    }

  return options;
}


async function generateEvents(fromYear, toYear, retrieveItemSetFunc, itemToEventFunc, access_token, concurrent_calls = 1) {

  var options = prepareOptions(fromYear, toYear, access_token, concurrent_calls);

  return new Promise(function(resolve, reject) {

    retrieveItems(retrieveItemSetFunc,options, function (error, items) {

      if (error) {
        console.error("Error: %s",error);
        reject(error);
      }

      if (items) {
        console.log("Data length: %d", items.length);

        async.map(items, itemToEventFunc, (err,results) => {
          if (err) {
            console.error("Error: %s", err);
            reject(err);
          }

          if (results) {
            resolve(results);
          }
        });
      }
    });
  })
};

module.exports = {generateEvents, getEpoch};

