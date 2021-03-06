require 'logger'

module Cypress
  class Configuration
    attr_accessor :cypress_folder
    attr_accessor :use_middleware
    attr_accessor :logger

    def initialize
      reset
    end

    alias :use_middleware? :use_middleware

    def reset
      self.cypress_folder = 'spec/cypress'
      self.use_middleware = true
      self.logger = Logger.new(STDOUT)
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end
end
