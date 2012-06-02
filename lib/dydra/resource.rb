# This is free and unencumbered software released into the public domain.

require 'net/http'

module Dydra
  ##
  # Represents a Dydra.com resource.
  #
  # This is the base class for all classes that represent dereferenceable
  # HTTP resources on Dydra.com.
  #
  # @see http://docs.dydra.com/sdk/ruby
  # @see http://docs.dydra.com/api/rest
  class Resource
    include Inspectable
    include Comparable

    HEADERS = {'Accept' => 'text/plain'} # N-Triples

    ##
    # @return [Resource]
    def self.new(*args, &block)
      if self == Resource
        case spec = args.first
          when Repository::SPEC
            Repository.new(*spec.split('/'))
          when Account::SPEC
            Account.new(spec)
        end
      else
        super
      end
    end

    ##
    # @return [RDF::URI]
    attr_reader :url

    ##
    # @param  [RDF::URI, String] url
    def initialize(url)
      @url = RDF::URI.new(url)
    end

    ##
    # Returns the root-relative path of this resource.
    #
    # @return [String]
    def path
      self.url.path[1..-1]
    end

    ##
    # Returns `true` if this resource exists on Dydra.com.
    #
    # @return [Boolean]
    def exists?
      true # TODO
    end

    ##
    # Returns `true` if this resource is equal to the given `other`
    # resource.
    #
    # @param  [Object] other
    # @return [Boolean]
    def eql?(other)
      other.class.eql?(self.class) && self == other
    end

    ##
    # Compares this resources to the given `other` resource.
    #
    # @param  [Object] other
    # @return [Integer] `-1`, `0`, or `1`
    def <=>(other)
      self.to_uri <=> other.to_uri
    end

    ##
    # Returns the URL of this resource.
    #
    # @return [RDF::URI]
    def to_uri
      self.url
    end

    ##
    # Returns the RDF data for this resource.
    #
    # @return [RDF::Enumerable]
    def to_rdf
      get('.nt', 'Accept' => 'text/plain') do |response|
        case response
          when Net::HTTPSuccess
            reader = RDF::NTriples::Reader.new(response.body)
            reader.to_a.extend(RDF::Enumerable, RDF::Queryable) # FIXME
        end
      end
    end

    ##
    # Performs an HTTP HEAD request on this resource.
    #
    # @param  [String, #to_s]          format
    # @param  [Hash{String => String}] headers
    # @yield  [response]
    # @yieldparam [Net::HTTPResponse] response
    # @return [Net::HTTPResponse]
    def head(format = nil, headers = {}, &block)
      url = self.url
      Net::HTTP.start(url.host, url.port) do |http|
        response = http.head(url.path.to_s + format.to_s, HEADERS.merge(headers))
        if block_given?
          block.call(response)
        else
          response
        end
      end
    end

    ##
    # Performs an HTTP GET request on this resource.
    #
    # @param  [String, #to_s]          format
    # @param  [Hash{String => String}] headers
    # @yield  [response]
    # @yieldparam [Net::HTTPResponse] response
    # @return [Net::HTTPResponse]
    def get(format = nil, headers = {}, &block)
      url = self.url
      Net::HTTP.start(url.host, url.port) do |http|
        response = http.get(url.path.to_s + format.to_s, HEADERS.merge(headers))
        if block_given?
          block.call(response)
        else
          response
        end
      end
    end
  end # Resource
end # Dydra
