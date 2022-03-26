require "net/http"
require "ostruct"
require "json"
require "date"

module Jekyll
  module Strapi
    class StrapiCollection
      attr_accessor :collection_name, :config

      def initialize(site, collection_name, config)
        @site = site
        @collection_name = collection_name
        @config = config
        @api_key = ENV["STRAPI_API_KEY"]
      end

      def generate?
        @config['output'] || false
      end

      def path
        if @config['api_version'] == "v4"
          "/api/#{@config['type'] || @collection_name}"
        else
          "/#{@config['type'] || @collection_name}"
        end
      end

      def collection_date
        @config["date"] || "publishedAt"
      end

      def each
        # Initialize the HTTP query
        uri = URI("#{@site.endpoint}#{path}")
        if @config['query']
          uri += @config['query']
          p uri
        end
        Jekyll.logger.info "Jekyll Strapi:", "Fetching entries from #{uri}"
        # Get entries
        if @api_key
          request = Net::HTTP::Get.new(uri)
          request["Authorization"] = "Bearer #{@api_key}"
          response = Net::HTTP.start(uri.hostname, uri.port) {|http|
            http.request(request)
          }
        else
          response = Net::HTTP.get_response(uri)
        end
        # Check response code
        if response.code == "200"
          result = JSON.parse(response.body, object_class: OpenStruct)
        elsif response.code == "401"
          raise "The Strapi server sent a error with the following status: #{response.code}. Please make sure you authorized the API access in the Users & Permissions section of the Strapi admin panel."
        else
          raise "The Strapi server sent a error with the following status: #{response.code}. Please make sure it is correctly running."
        end

        # Add necessary properties
        case @config["api_version"]
        when "v4"
          result.data.each do |document|
            dt = DateTime.parse(document.attributes[collection_date])
            document.type = collection_name
            document.collection = collection_name
            document.id ||= document._id
            document.year = dt.strftime("%Y")
            document.month = dt.strftime("%m")
            document.day = dt.strftime("%d")
            document.url = @site.strapi_link_resolver(collection_name, document)
            puts document
          end


          result.data.each {|x| yield(x)}
        else
          result.each do |document|
            dt = DateTime.parse(document[collection_date])
            document.type = collection_name
            document.collection = collection_name
            document.id ||= document._id
            document.year = dt.strftime("%Y")
            document.month = dt.strftime("%m")
            document.day = dt.strftime("%d")
            document.url = @site.strapi_link_resolver(collection_name, document)
          end

          result.each {|x| yield(x)}
        end
      end
    end
  end
end
