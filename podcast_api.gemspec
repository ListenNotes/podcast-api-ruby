# frozen_string_literal: true

require_relative "lib/version"

Gem::Specification.new do |s|
  s.name = "podcast_api"
  s.version = PodcastApi::VERSION
  s.required_ruby_version = ">= 3.3"
  s.summary = "Ruby bindings for the Listen Notes Podcast API"
  s.description = "Listen Notes is the best podcast search engine and api.  " \
                  "This is the official Ruby Gem for the Listen Notes Podcast API. " \
                  "See https://www.PodcastAPI.com/ for details."
  s.author = "Listen Notes, Inc."
  s.email = "hello@listennotes.com"
  s.homepage = "https://www.PodcastAPI.com/"
  s.license = "MIT"
  s.add_runtime_dependency "httparty", '>= 0.24.1', '< 0.25'
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/ListenNotes/podcast-api-ruby/issues",
    "changelog_uri" =>
      "https://github.com/ListenNotes/podcast-api-ruby/releases",
    "documentation_uri" => "https://www.listennotes.com/api/docs/",
    "github_repo" => "https://github.com/ListenNotes/podcast-api-ruby",
    "homepage_uri" => "https://www.PodcastAPI.com/",
    "source_code_uri" => "https://github.com/ListenNotes/podcast-api-ruby",
  }

  s.files = Dir['lib/**/*.rb', 'lib/api-contract.json', 'README.md', 'LICENSE']
  s.require_paths = ["lib"]
end
