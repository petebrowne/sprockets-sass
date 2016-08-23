# frozen_string_literal: true
require_relative '../v3/cache_store'
module Sprockets
  module Sass
    module V4
      # Internal: Cache wrapper for Sprockets cache adapter. (Sprockets >= 3)
      class CacheStore < Sprockets::Sass::V3::CacheStore
      end
    end
  end
end
