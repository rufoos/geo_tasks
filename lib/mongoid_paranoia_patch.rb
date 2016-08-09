module Mongoid
  module Paranoia
    def remove(options = {})
      cascade!
      time = self.deleted_at = Time.now
      paranoid_collection.find(atomic_selector).
        update({ "$set" => { paranoid_field => time }})
      @destroyed = true
      IdentityMap.remove(self)
      # clear_timeless_option
      true
    end
  end
end