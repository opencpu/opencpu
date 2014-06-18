library(opencpu)
library(httr)

payload <- '{
  "ref": "refs/heads/master",
  "after": "fafc4c046ab6973dafbbfad51c46a095f53d0129",
"before": "035269431ef2ad2445c9cc90824d6e4749a2e5b3",
"created": false,
"deleted": false,
"forced": false,
"compare": "https://github.com/jeroenooms/jsonlite/compare/035269431ef2...fafc4c046ab6",
"commits": [
{
"id": "fafc4c046ab6973dafbbfad51c46a095f53d0129",
"distinct": true,
"message": "Trigger build",
"timestamp": "2014-06-17T16:13:29-07:00",
"url": "https://github.com/jeroenooms/jsonlite/commit/fafc4c046ab6973dafbbfad51c46a095f53d0129",
"author": {
"name": "Jeroen",
"email": "jeroenooms@gmail.com",
"username": "jeroenooms"
},
"committer": {
"name": "Jeroen",
"email": "jeroenooms@gmail.com",
"username": "jeroenooms"
},
"added": [

],
"removed": [

],
"modified": [
"README.md"
]
}
],
"head_commit": {
"id": "fafc4c046ab6973dafbbfad51c46a095f53d0129",
"distinct": true,
"message": "Trigger build",
"timestamp": "2014-06-17T16:13:29-07:00",
"url": "https://github.com/jeroenooms/jsonlite/commit/fafc4c046ab6973dafbbfad51c46a095f53d0129",
"author": {
"name": "Jeroen",
"email": "jeroenooms@gmail.com",
"username": "jeroenooms"
},
"committer": {
"name": "Jeroen",
"email": "jeroenooms@gmail.com",
"username": "jeroenooms"
},
"added": [

],
"removed": [

],
"modified": [
"README.md"
]
},
"repository": {
"id": 13305534,
"name": "jsonlite",
"url": "https://github.com/jeroenooms/jsonlite",
"description": "A smarter JSON encoder/decoder for R",
"homepage": "http://arxiv.org/abs/1403.2805",
"watchers": 40,
"stargazers": 40,
"forks": 2,
"fork": true,
"size": 5617,
"owner": {
"name": "jeroenooms",
"email": "jeroenooms@gmail.com"
},
"private": false,
"open_issues": 6,
"has_issues": true,
"has_downloads": true,
"has_wiki": false,
"language": "C++",
"created_at": 1380823525,
"pushed_at": 1403046815,
"master_branch": "master"
},
"pusher": {
"name": "jeroenooms",
"email": "jeroenooms@gmail.com"
}
}'

req = POST (
  url = paste0(opencpu$url(), "/webhook"), 
  body = payload,
  add_headers("Content-Type" = "application/json")
)

print(req)