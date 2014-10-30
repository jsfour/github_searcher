require 'clearbit'
  
module UserExtention

  Clearbit.key = ENV["clearbit_token"]

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