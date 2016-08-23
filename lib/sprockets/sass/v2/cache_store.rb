# frozen_string_literal: true
module Sprockets
  module Sass
    module V2
      # Internal: Cache wrapper for Sprockets cache adapter. (Sprockets 2.x)
      class CacheStore < ::Sass::CacheStores::Base
        attr_reader :environment

        def initialize(environment)
          @environment = environment
        end

        def _store(key, version, sha, contents)
          environment.send :cache_set, "sass/#{key}", version: version, sha: sha, contents: contents
        end

        def _retrieve(key, version, sha)
          obj = environment.send(:cache_get, "sass/#{key}")
          return unless obj.is_a?(Hash)
          return if obj[:version] != version || obj[:sha] != sha
          obj[:obj]
        end
      end
    end
  end
end
