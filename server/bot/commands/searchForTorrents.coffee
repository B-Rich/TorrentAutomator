Command = require "./base"
KickassProvider = require "../../providers/kickass"

# Setup
module.exports = class SearchForTorrentsCommand extends Command
  kickass: null
  maxResults: 5
  regex: new RegExp("^[sS]earch for (.*)")
  constructor: () ->
    @kickass = new KickassProvider()
    console.log @kickass
  run: (input, context, callback) =>

    # console.log(input);
    query = input.message
    query = query.match(@regex)[1]

    # console.log(query);
    @kickass.search query, {}, (err, results) =>
      # console.log(results);

      # List the available Torrents
      len = Math.min(@maxResults, results.length)

      # Init message
      message = "Here are the top #{len} Torrents:\n"

      # Build Torrent list in message
      i = 0
      while i < len
        torrent = results[i]
        downloadSizeInMB = torrent.size / 1000 / 1000
        stats = ((if torrent.verified then "Verified and " else "")) +
          "#{Math.round(downloadSizeInMB * 100) / 100} MB with " +
          "#{torrent.seeders} seeders and " +
          "#{torrent.leechers} leechers"
        message += (i + 1) + ". " + torrent.title + " (" + stats + ") \n"
        i++

      # Create response
      response = response:
        plain: message

      # Save Torrents to context
      context.foundTorrents = results

      # return
      return callback err, response