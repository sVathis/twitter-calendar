# Twitter tweets as iCalendar (Azure Function)

This [Azure Function](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) creates an [iCalendar](https://icalendar.org/) with all (or at least the last 3200) Tweets as events. You can subscribe to this iCalendar from your favorite calendaring program and have calendar entries created on every check-in

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [Cloud deployment](#Cloud-deployment) for notes on how to deploy the project on Azure.

### Prerequisites

In order for this service to work you will need:

 1. A valid [Azure subscription](https://azure.microsoft.com/en-us/)
 2. An [Twitter developer account](https://developer.twitter.com)

You will also need the following software installed in your dev enviroment:

 1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
 2. [Azure Function Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
 3. [Node.js](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) (required for Azure Functions Core Tools)

## Installing

### Twitter API access

To use Twitter APIs, you need to register with the [Twitter Developer](https://developer.twitter.com) and create an application, using [this form](https://developer.twitter.com/en/apps/create) and a [Full Archive dev environment](https://developer.twitter.com/en/account/environments).

Generate a unique set of keys (a keyset) that will serve as your application’s credentials:

* API key
* API secret key
* Access token
* Access token secret

You should copy and save your keys locally in the [credentials.sh](credentials.sh) file, for use in this application, as follows:

```shell
TWITTERCONSUMERKEY=<API key>
TWITTERCONSUMERSECRET=<API secret key>
TWITTERACCESSTOKEN=<Access Token>
TWITTERACCESSTOKENSECRET=<Access Token secret>
TWITTERSCREENNAME=<Twitter user name>
TWITTERTWEETMODE=extended
TWITTERMAXTWEETS=1000 #This is the max number of tweets to receive, up to 3200.
```

These credentials will be privatly uploaded to Azure as [App settings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings) by the [bootstrap.sh](bootstrap.sh) script.

### node.js enviroment

Install locally all required modules as follows:

```shell
$ npm install
```

## Deploying

First you will need to set the values of the following variables in [definitions.sh](definitions.sh) file:

```shell
rgName=<Resource Group Name>
storageName=<Storage Account Name>
functionAppName=<FunctionApp Name>
location=<Location>
```

*Note*: `rgName` and `storageName` should be unique across your Azure subscription. `functionAppName` should be unique across Azure(!). `location` should be an [Azure Location](https://azure.microsoft.com/en-us/global-infrastructure/locations/) preferably be as close as possible to your physical location. 

### Local deployment

Before running this function localy for the **first time**, you will need to execute the [bootstrap.sh](bootstrap.sh) script:

```shell
$ ./bootstrap.sh
Done
```

This script will:

* create an Resource Group where all resources required for this function will belong
* create a Storage Account, required by the Azure Functions framework
* create the Azure Function App
* securely upload to Azure all Twitter credentials as [App settings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings)
* will fetch these app settings locally so that can be used for local function execution.

After bootstraping, the Azure Function can be executed locally as follows:

```shell
$ func host start

Hosting environment: Production
Now listening on: http://0.0.0.0:7071
Application started. Press Ctrl+C to shut down.

Http Functions:

        twitter: [GET] http://localhost:7071/api/twitter
```

While the Azure Function is running locally, you can send an HTTP request towards the URL above ([http://localhost:7071/api/twitter](http://localhost:7071/api/twitter)) in order to retrieve your tweets in iCalendar format:

```shell
$ wget -4 http://localhost:7071/api/twitter

--2020-01-31 16:04:15--  http://localhost:7071/api/twitter
Resolving localhost (localhost)... 127.0.0.1
Connecting to localhost (localhost)|127.0.0.1|:7071... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [text/calendar]
Saving to: ‘twitter’

twitter                                [ <=>                                                                      ] 748.89K  --.-KB/s    in 0.03s

2020-01-31 16:04:19 (24.1 MB/s) - ‘twitter’ saved [766866]

$ file twitter
twitter: vCalendar calendar file
```

### Cloud deployment

In order to publish to Azure, execute the [deploy.sh](deploy.sh) script:

```shell
$ ./deploy.sh

Syncing triggers...
Functions in twittercalendar:
    twitter - [httpTrigger]
        Invoke url: https://<functionAppName>.azurewebsites.net/api/twitter?code=<code>

```

After succesfull deployment you can send HTTPS request towards the `Invoke url` above in order to retrieve your tweets in iCalendar format. You can use this `Invoke url` to subscribe to this iCalendar in your favorite calendaring platform, e.g. [Google Calendar](https://support.google.com/calendar/answer/37100?co=GENIE.Platform%3DDesktop&hl=en) or [Outlook](https://support.office.com/en-us/article/Import-or-subscribe-to-a-calendar-in-Outlook-on-the-web-503ffaf6-7b86-44fe-8dd6-8099d95f38df).

## Usage

This Azure Function provides the following API endpoints:

### foursquare 

`https://<functionAppName>.azurewebsites.net/api/twitter`

This endpoint returns your last `TWITTERMAXTWEETS` tweets (up to 3200).


## Built With

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
* [Azure Function Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)
* [Node.js](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
* [ics](https://github.com/adamgibbons/ics)

## Authors

* **Spiros Vathis** - github: [sVathis](https://github.com/sVathis) - Twitter: [@svathis](https://twitter.com/svathis)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
