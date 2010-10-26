module Datagraph
  ##
  # Represents a Datagraph.org user account.
  class Account < Resource
    SPEC = %r(^([^/]+)$) # /account

    ##
    # Returns `true` if an account with the given `name` exists on
    # Datagraph.org.
    #
    # @param  [String, #to_s] name
    # @return [Boolean]
    def self.exists?(name)
      Account.new(name).exists?
    end

    ##
    # Registers a new user account with Datagraph.org.
    #
    # @param  [String] name
    # @param  [Hash{Symbol => Object}] options
    # @option options [String] :password
    # @return [Account]
    def self.register!(name, options = {})
      Datagraph::Client.rpc.call('datagraph.account.register', name, options[:password])
      self.new(name)
    end

    # @return [String]
    attr_reader :name

    ##
    # @param  [String, #to_s] name
    def initialize(name)
      @name = name.to_s
      super(Datagraph::URL.join(@name))
    end

    ##
    # Returns the given repository belonging to this account.
    #
    # @param  [String, #to_s] name
    # @return [Repository]
    def repository(name)
      Repository.new(self, name)
    end

    ##
    # Returns the list of repositories belonging to this account.
    #
    # @return [Array<Repository>]
    def repositories
      Repository.each(:account_name => name).select do |repository|
        repository.account.name == name
      end
    end

    ##
    # Returns a string representation of the account name.
    #
    # @return [String]
    def to_s
      name
    end

    ##
    # @private
    # @return [Hash]
    def info
      Datagraph::Client.rpc.call('datagraph.account.info', name)
    end
  end # Account
end # Datagraph