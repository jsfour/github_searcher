require 'clearbit'
  
module EnrichmentStrapon

  def clearbit_key=(key)
    Clearbit.key = key
  end

  def enrich
    if !self.email.nil? and @enrich.nil?
      begin
        @enrich = Clearbit::Person[email: self.email]
      rescue
        # Just move on
      end
    end
    @enrich ||= Clearbit::Mash.new
    return @enrich
  end
end