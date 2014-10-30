require 'open-uri'
require 'octokit'
require 'faraday'
require 'faraday-http-cache'
require 'logger'
require 'csv'
require './dradis'
require './user_extention'
require 'yaml'


def run! geo, languages
  log = Logger.new("processor.log", "weekly")
  log.info "New Job Starting ***************"
  github_token = ENV["github_token"]
  finder = Dradis.new(github_token, geo, languages, log)
  res = finder.scan_all
  users = finder.collate(res)
  users = finder.parse(users)
  enriched_users = users.map do |i|
    i.extend(UserExtention)
    i.enrich
    log.info i.login + " enriched"
    i
  end
  write_csv(enriched_users)
  log.info "Job Complete ***************"
end

def write_csv users
  CSV.open("./names.csv", "wb") do |csv|
    csv << [
      "name",
      "login",
      "html_url",
      "company",
      "blog",
      "location",
      "email",
      "bio",
      "github-public_repos",
      "github-followers",
      "linkedin",
      "twitter",
      "twitter-followers"
    ]
    users.each do |user|
      csv << [
        user.name,
        user.login,
        user.html_url,
        user.company,
        user.blog,
        user.location,
        user.email,
        user.bio,
        user.public_repos,
        user.followers,
        user.enrich.fetch("linkedin"){Hash.new}.fetch("handle"){""},
        user.enrich.fetch("twitter"){Hash.new}.fetch("handle"){""}, 
        user.enrich.fetch("twitter"){Hash.new}.fetch("followers"){""}
      ]
    end
  end
end

geos = [
  "Santa Monica",
  "Los Angeles",
  "LA",
  "Culver City",
  "El Segundo"
]
languages = [
  "ruby",
  "rails",
  "Rails",
  "node",
  "ember",
  "javascript"
]

config = YAML.load_file("config.yml")
ENV["clearbit_token"] = config["clearbit_token"]
ENV["github_token"] = config["github_token"]

puts "Finding people on GitHub that live in:\n"
geos.each do |geo|
  puts "    #{geo}\n"
end

puts "That like these languages:\n"
languages.each do |lang|
  puts "    #{lang}\n"
end
puts "Compiled names will be in: names.csv"

run!(geos, languages)
puts "Done!"
