engines = require 'consolidate'
request = require 'request'
Twitter = require 'ntwitter'

app = express()

app.configure 'development', ->
  app.use express.logger('dev')
  app.use express.errorHandler()

app.configure 'production', ->
  app.enable 'trust proxy'

app.configure ->
  app.set 'port', process.env.PORT or 4134
  app.use express.bodyParser()

app.get '/', (req, res) ->
  res.send 'twine-remind'

app.post '/', (req, res) ->
  if req.body.tweet
    params = req.body.params
    request.get "http://api.crunchbase.com/v/1/companies/posts", name: params.replace(/\s/, "%20"), (err, res, body) =>
      json = JSON.parse(body)
      twitter = new Twitter
        consumer_key: req.body.auth.consumer_key
        consumer_secret: req.body.auth.consumer_secret
        access_token_key: req.body.auth.access_token_key
        access_token_secret: req.body.auth.access_token_secret
      params =
        in_reply_to_status_id: req.body.tweet.id
      if json.posts_url
        twitter.updateStatus "#{json.name} has been TechCrunched <a href='#{json.posts_url}'>#{json.num_posts} times</a>.", params, (err, data) ->
          res.jsonp data

app.listen app.get('port'), ->
  console.log "Server started on port #{app.get 'port'} in #{app.settings.env} mode."
