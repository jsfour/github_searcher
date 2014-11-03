class Dradis
  attr_accessor :users_found
  def initialize token, geos=[], languages=[], log=nil
    log.nil? ? @log = Logger.new("dradis.log", "weekly") : @log = log
    stack = Faraday::RackBuilder.new do |builder|
      builder.use Faraday::HttpCache
      builder.use Octokit::Response::RaiseError
      builder.adapter Faraday.default_adapter
    end
    Octokit.middleware = stack
    @client = Octokit::Client.new(:access_token => token)
    @geos, @languages = geos, languages
    @api_sleep_time = 1
    @users_found = []
    @encoding_problems = []
    @rate_limited = []
  end

  def scan_all
    #TODO: add minimum number of repos.
    @results = []
    @geos.each do |geo|
      @languages.each do |lang|
        @results << @client.search_users(build_query(location: geo, language: lang, type: "user"))
      end
    end
    return @results
  end

  def collate results
    @collated_results = []
    results.each do |result|
      result.items.each do |item|
        @collated_results << item
      end
    end
    @collated_results = @collated_results.flatten.uniq
    return @collated_results
  end

  def parse response_items=[]
    return @users_found if response_items.empty?
    response_items.each do |result|
      retries = 0
      retry_limit = 3
      begin
        user = @client.user(result[:login])
        @log.info "Processed #{result[:login]} successfully"
        @users_found << user
      rescue Encoding::UndefinedConversionError
        @log.error "Problem decoding #{result[:login]} skipping..."
        @encoding_problems << result
      rescue Octokit::TooManyRequests
        if retries < retry_limit
          @log.error "Rate Limited on #{result[:login]} sleeping for #{@api_sleep_time} minute..."
          sleep(@api_sleep_time)
          retries += 1
          retry
        else
          @log.error "Retry limit exceded on #{result[:login]} moving on..."
        end
      end
    end
    return @users_found
  end

private
  def build_query *params
    return "" if params.nil?
    query = ""
    params.each do |param|
      #query = query + "+#{param.key}:" + param.value.gsub(/ /, '+')
      query = query + " location:" + param[:location].gsub(/ /, '+')  if param.has_key?(:location)
      query = query + " repos:>=" + param[:repos].to_s if param.has_key?(:repos)
      query = query + " language:" + param[:language].gsub(/ /, '+') if param.has_key?(:language)
      query = query + " type:" + param[:type].gsub(/ /, '+') if param.has_key?(:type)
    end
    query[0] = "" if query[0] == " "
    return query
  end
end