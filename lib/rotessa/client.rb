require "httparty"
require "debug"

class Rotessa::Client
  include HTTParty

  attr_reader :environment, :api_key

  PAGE_SIZE = 1000 # Rotessa's default page size

  def initialize(api_key: nil, environment: nil)
    api_key ||= ENV["ROTESSA_API_KEY"]
    environment ||= ENV["ROTESSA_ENVIRONMENT"]&.to_sym || :production

    raise "Invalid environment: #{environment}. Only :production and :sandbox are accepted." unless [:production, :sandbox].include?(environment)
    raise "Invalid API key: #{api_key}. API key must be a string." unless api_key.to_s != ""

    @api_key = api_key
    @environment = environment

    set_base_uri
  end

  def customers(**query)
    options = base_options.clone
    options[:query].merge!(query)

    get_all_pages("/customers", options)
  end

  def customer(id:, **query)
    options = base_options.clone
    options[:query].merge!(query)

    unless id.is_a?(Integer) || id.to_i.to_s == id.to_s
      options[:query][:custom_identifier] = id
      id = "show_with_custom_identifier"
    end

    path = build_path("/customers", id)

    self.class.get(path, options)
  end

  def transactions(**query)
    options = base_options.clone
    options[:query].merge!(query)
    get_all_pages("/transaction_report", options)
  end

  private

  def set_base_uri
    case environment
    when :production
      self.class.base_uri "https://api.rotessa.com/v1"
    when :sandbox
      self.class.base_uri "https://sandbox-api.rotessa.com/v1"
    end
  end

  def build_path(base_path, *args)
    path = base_path
    (args || []).each do |arg|
      path += "/#{arg}"
    end
    path
  end

  def get_all_pages(path, options)
    results = []
    response = nil
    options = options.merge(page: 0)

    while fetch_next_page?(response)
      options[:page] += 1
      response = self.class.get(path, options)

      return [response, errors_for(response)] if has_error?(response)

      results += Array.wrap(response.parsed_response)
    end

    [response, results]
  end

  def fetch_next_page?(results)
    results.nil? || results.size == PAGE_SIZE
  end

  def base_options
    {headers: headers, query: {}}
  end

  def headers
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => "Token token=\"#{api_key}\"",
      "Accept-Encoding" => "gzip,deflate,identity"
    }
  end

  def has_error?(response)
    response.nil? || !response.success? || (response.parsed_response.is_a?(Hash) && response["errors"].present?)
  end

  def errors_for(response)
    return nil unless response&.parsed_response&.is_a?(Hash)

    response["errors"]
  end
end
