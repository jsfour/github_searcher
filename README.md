# Github Searcher

This script uses the GitHub API to search for people who fit a specified criteria --location and programming language. The script then uses the https://clearbit.co API to enrich the user data. Once collected and enriched, the data is exported to a CSV for easy processing.

Data collected:
* github-name
* github-login
* github-html_url
* github-company
* github-blog
* github-location
* github-email
* github-bio
* github-public_repos_count
* github-followers_count
* linkedin profile
* twitter handel
* twitter-followers_count

### Why does this exist?

This script was built to help find and rank potential recruits for octavius labs.

octavius is a startup studio that has 2 primary directives:

* Bring marketing and productivity SaaS products to market and assemble teams to support the products as they scale
* Partner with companies who are looking to accelerate their R&D efforts
* See our website for more info: [http://octaviuslabs.com](http://bit.ly/1EdvTIH)

Octavius is looking for talented people who like to work on a diverse set of problems. If you are interested please email Jimi: recruiting [AT] octaviuslabs.com

### How do I use it?
#### Step 1:
```
  git clone https://github.com/jsmootiv/github_searcher.git
  cd github_searcher
  bundle install
```
#### Step 2:
Modify the  "geos" and "languages" array in the search.rb file to include the types of languages and the location of developers you want to find. ie:
```
  geos = [
    "Atlanta"
  ]
  languages = [
    "erlang"
  ]

```
#### Step 3:
Setup your config file by copying the document and replacing the api keys.
```
  cp config.yml.template config.yml
```

```
./config.yml

github_token: PLACE YOUR GITHUB API KEY HERE
clearbit_token: PLACE YOUR CLEARBIT API KEY HERE

```
#### Step 4:
Run the script. The output will appear in "names.csv"
```
  ruby search.rb
```

#### Disclaimer:
This script can be used for evil but please use it responsibly. Be cool, don't be an asshole.
