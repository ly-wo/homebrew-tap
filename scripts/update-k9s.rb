#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

REPO = "derailed/k9s"
FORMULA_PATH = "Formula/k9s.rb"

def request_json(uri)
  request = Net::HTTP::Get.new(uri)
  request["Accept"] = "application/vnd.github+json"
  request["User-Agent"] = "homebrew-tap-updater"
  request["X-GitHub-Api-Version"] = "2022-11-28"
  token = ENV.fetch("GITHUB_TOKEN", ENV.fetch("GH_TOKEN", nil))
  request["Authorization"] = "Bearer #{token}" if token&.length&.positive?

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end
  return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

  abort "GitHub API request failed: #{response.code} #{response.message}\n#{response.body}"
end

def tag_commit(repo, tag)
  reference = request_json(URI("https://api.github.com/repos/#{repo}/git/ref/tags/#{tag}"))
  object = reference.fetch("object")

  loop do
    type = object.fetch("type")
    return object.fetch("sha") if type == "commit"

    abort "Unexpected Git tag object type: #{type}" if type != "tag"

    object = request_json(URI(object.fetch("url"))).fetch("object")
  end
end

release = request_json(URI("https://api.github.com/repos/#{REPO}/releases/latest"))
tag = release.fetch("tag_name")
match = /\Av(?<version>\d+(?:\.\d+)+)\z/.match(tag)
abort "Unexpected K9s release tag: #{tag}" unless match

revision = tag_commit(REPO, tag)
source = File.read(FORMULA_PATH)
tag_pattern = /^      tag:\s+"v(?<version>\d+(?:\.\d+)+)",$/
revision_pattern = /^      revision: "(?<revision>[a-f0-9]{40})"$/
tag_match = source.match(tag_pattern)
revision_match = source.match(revision_pattern)
abort "Could not find K9s tag in #{FORMULA_PATH}" unless tag_match
abort "Could not find K9s revision in #{FORMULA_PATH}" unless revision_match

if tag_match[:version] == match[:version] && revision_match[:revision] == revision
  puts "k9s is already up to date at #{tag}."
  exit
end

updated = source.sub(tag_pattern, %Q(      tag:      "#{tag}",))
updated = updated.sub(revision_pattern, %Q(      revision: "#{revision}"))
File.write(FORMULA_PATH, updated)
puts "Updated k9s to #{tag}."
