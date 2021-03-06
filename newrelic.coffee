# Description:
#   Display current app performance stats from New Relic
#
# Dependencies:
#   "xml2js": "0.2.0"
#
# Configuration:
#   HUBOT_NEWRELIC_ACCOUNT_ID
#   HUBOT_NEWRELIC_APP_ID
#   HUBOT_NEWRELIC_API_KEY
#
# Commands:
#   hubot newrelic <appname> - Returns summary application stats from New Relic
#
# Notes:
#   How to find these settings:
#   After signing into New Relic, select your application
#   Given: https://rpm.newrelic.com/accounts/xxx/applications/yyy
#     xxx is your Account ID and yyy is your App ID
#   Account Settings > API + Web Integrations > API Access > "API key"
#
# Author:
#   briandoll

module.exports = (robot) ->
#   robot.respond /newrelic me/i, (msg) ->
#     accountId = process.env.HUBOT_NEWRELIC_ACCOUNT_ID
#     appId     = process.env.HUBOT_NEWRELIC_APP_ID
#     apiKey    = process.env.HUBOT_NEWRELIC_API_KEY
#     Parser = require("xml2js").Parser

#     msg.http("https://rpm.newrelic.com/accounts/#{accountId}/applications/#{appId}/threshold_values.xml?api_key=#{apiKey}")
#       .get() (err, res, body) ->
#         if err
#           msg.send "New Relic says: #{err}"
#           return

#         (new Parser).parseString body, (err, json) ->
#           threshold_values = json['threshold-values']['threshold_value'] || []
#           lines = threshold_values.map (threshold_value) ->
#             "#{threshold_value['$']['name']}: #{threshold_value['$']['formatted_metric_value']}"
#           msg.send lines.join("\n"), "https://rpm.newrelic.com/accounts/#{accountId}/applications/#{appId}"

  robot.respond /newrelic (.*)/i, (msg) ->
    accountId = process.env.HUBOT_NEWRELIC_ACCOUNT_ID
    appId     = process.env.HUBOT_NEWRELIC_APP_ID
    apiKey    = process.env.HUBOT_NEWRELIC_API_KEY
    Parser = require("xml2js").Parser
    match = msg.match[1].trim()

    msg.http("https://api.newrelic.com/accounts.xml?include=application_health&api_key=#{apiKey}")
      .get() (err, res, body) ->
        if err
          msg.send "New Relic says: #{err}"
          return

        (new Parser).parseString body, (err, json) ->
          accounts = json['accounts']['account']
          accounts.forEach (account) ->
            applications = account['applications'][0]['application']
            applications.forEach (application) ->
              lines = []
              appName = application['name'][0]
              lines.push appName
              threshold_values = application['threshold-values'][0]['threshold_value']
              threshold_values.forEach (threshold_value) ->
                lines.push "#{threshold_value['$']['name']}: #{threshold_value['$']['formatted_metric_value']}"
              lines.push "https://rpm.newrelic.com/accounts/#{accountId}/applications/#{application['id'][0]['_']}"
              msg.send lines.join("\n") if match.toLowerCase() == appName.toLowerCase() || match.toLowerCase() == 'all'
