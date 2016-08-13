# frozen_string_literal: true
module Sass
  module Script
    # Original Sass script functions are overidden with this methods
    module Functions
      include Sprockets::Sass::Utils.get_class_by_version('Functions')

      # Hack to ensure previous API declarations (by Compass or whatever)
      # don't take precedence.
      %i(asset_path asset_url image_path image_url font_path font_url asset_data_uri).each do |method|
        defined?(@signatures) && @signatures.delete(method)
      end

      declare :asset_path,     [:source], var_kwargs: true
      declare :asset_path,     %i(source kind)
      declare :asset_url,      [:source], var_kwargs: true
      declare :asset_url,      %i(source kind)
      declare :image_path,     [:source], var_kwargs: true
      declare :image_url,      [:source], var_kwargs: true
      declare :image_url,      %i(source only_path)
      declare :image_url,      %i(source only_path cache_buster)
      declare :font_path,      [:source], var_kwargs: true
      declare :font_url,       [:source], var_kwargs: true
      declare :font_url,       %i(source only_path)
      declare :asset_data_uri, [:source]
    end
  end
end
