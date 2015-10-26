require 'pry'
require 'open-uri'
require 'uri'
require 'rss'
require 'open_uri_redirections'

def getTags(var)
  tags = {}
  var["bookmarks"].each do |val|
    tagArray = val["tags"]
    tagArray.each do |tag|
      if tags.has_key?(tag)
        tags[tag] = tags[tag] + 1
      else
        tags[tag] = 1
      end
    end
  end
  return tags
end

#Faraday初期化
conn = Faraday::Connection.new(:url => 'http://b.hatena.ne.jp/entry/json/') do |builder|
  builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
  builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
  builder.use FaradayMiddleware::FollowRedirects
  builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
end

#Faraday初期化
res = conn.get 'http://b.hatena.ne.jp/entry/json/', {:url => "http://d.hatena.ne.jp/naoya/20151026/1445827208"}
res = JSON.parse(res.body)
tags = getTags(res)
max = 0
tag = ""
tags.each do |key, val|
  if max < val
    max = val
    tag = key
  end
end
result = []
rss = nil

# リダイレクトして、うまくいかなかったのでopen-urlのミドルウェアを使う
open(URI.escape("https://b.hatena.ne.jp/search/tag?q=#{tag}&mode=rss&sort=recent&threshold=30"), :allow_redirections => :all) do |f|
  rss = RSS::Parser.parse(f.read)
end
#rss = conn.get "https://b.hatena.ne.jp/search/text?q=#{tag}&mode=rss&threshold=30&sort=recent"
rss.items.each do |item|
  entry = {}
  res = conn.get 'http://b.hatena.ne.jp/entry/json/', {:url => item.about}
  res = JSON.parse(res.body)
  entry[:link] = item.about
  entry[:title] = item.title
  entry[:description] = item.description
  entry[:content_encoded] = item.content_encoded
  entry[:screenshot] = res["screenshot"]
  entry[:count] = res["count"]
  entry[:tags] = getTags(res)
  result << entry
end

pp result
result.each do |data|
  entry = Entry.where(link: data[:title])
  if entry.exists?
    entry.update(data)
  else
    Entry.create(data)
  end
end
