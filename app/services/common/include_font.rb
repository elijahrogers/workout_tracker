module Common
  module IncludeFont
    def add_font_satellite
      font_families.update( 'Hero' =>
      {
        normal: "#{Rails.root}/public/fonts/satellite.ttf",
      }
      )
    end
  end
end
