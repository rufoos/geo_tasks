module Mongoid
  module Geospatial

    def self.meters_to_miles(meters)
      meters / 1609.34
    end

    def self.meters_to_km(meters)
      meters / 1000.0
    end

    def distance_from(obj, options = { :unit => :km })
      if !self.is_a?(Mongoid::Geospatial::Point) || !obj.is_a?(Mongoid::Geospatial::Point)
        puts 'Fields must be a Mongoid::Geospatial::Point class'
        return nil
      end
      self.distance_from(obj, options)
    end

    class Point
      def distance_from(obj, options = {})
        wgs84_proj4 = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'
        wgs84_wkt = <<-WKT
          GEOGCS["WGS 84",
            DATUM["WGS_1984",
              SPHEROID["WGS 84",6378137,298.257223563,
                AUTHORITY["EPSG","7030"]],
              AUTHORITY["EPSG","6326"]],
            PRIMEM["Greenwich",0,
              AUTHORITY["EPSG","8901"]],
            UNIT["degree",0.01745329251994328,
              AUTHORITY["EPSG","9122"]],
            AUTHORITY["EPSG","4326"]]
        WKT

        wgs84_factory = RGeo::Geographic.spherical_factory(
          :srid => 4326,
          :proj4 => wgs84_proj4,
          :coord_sys => wgs84_wkt
        )

        point1 = wgs84_factory.point(self.x, self.y)
        point2 = wgs84_factory.point(obj.x, obj.y)

        distance = wgs84_factory.line(point1, point2).length

        distance = Mongoid::Geospatial.meters_to_miles(distance) if options[:unit] == :mi
        distance = Mongoid::Geospatial.meters_to_km(distance) if options[:unit] == :km
        distance = distance if options[:unit] == :m 

        distance
      end
    end

  end
end