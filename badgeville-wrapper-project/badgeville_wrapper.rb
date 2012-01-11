require 'rubygems'
require 'active_resource'
require 'logger'

# For custom BadgevilleJson
require 'active_support/json'

# Instantiate a logger so HTTP requests and response codes will be printed
# to STDOUT
ActiveResource::Base.logger = Logger.new(STDOUT)
ActiveResource::Base.logger.level = Logger::DEBUG




#********** ADDING module CustomFormat **********#
# Handles the fact that a JSON formatted GET response does not meet the
# ActiveResource standard, and is instead preceded by the root key :data
module BadgevilleJsonFormat
  extend self

  def extension
    "json"
  end

  def mime_type
    "application/json"
  end

  def encode(hash, options = nil)
    ActiveSupport::JSON.encode(hash, options)
  end

  def decode(json)
    ActiveResource::Formats.remove_root(ActiveSupport::JSON.decode(json))["data"] || ActiveResource::Formats.remove_root(ActiveSupport::JSON.decode(json))
  end
end




# # SUBCLASSING ActiveResource::Errors to be used by BaseResource as Badgeville::Errors
module Badgeville
  module Config
    # ADDING class method to configure BaseResource
    def config ( target_site, apikey )
      self.site = target_site
      self.format = :badgeville_json
      # set a path that goes between the URL and the resource
      self.prefix = "/api/berlin/#{apikey}/"
      #self.apikey = '007857cd4fb9f360e120589c34fea080'
    end
  end

  class Errors < ActiveResource::Errors
    # Grabs errors from a custom Badgeville-style json response that does
    # not have a root key :errors.
    def from_badgeville_json(json, save_cache = false)
      #puts "Here is the custom response ", ActiveSupport::JSON.decode(json)
      formatted_json_decoded = Array.new
      json_decoded = (ActiveSupport::JSON.decode(json)) rescue []
      json_decoded.each do |attribute_name, err_msgs|
        if err_msgs.is_a? Array
          err_msgs.each do |err_msg|
            formatted_json_decoded.push(attribute_name.humanize + " #{err_msg}")
          end
        elsif err_msgs.is_a? String
            formatted_json_decoded.push(attribute_name, err_msgs)
        end
      end
      from_array formatted_json_decoded, save_cache
    end

    # Grabs errors from a json response.
    def from_json(json, save_cache = false)
      array = Array.wrap(ActiveSupport::JSON.decode(json)['errors']) rescue []
      from_array array, save_cache
    end

  end
end




# # SUBCLASSING ActiveResource::Base as BaseResource
class BaseResource < ActiveResource::Base

  # CLASS METHODS
  # OVERRIDING ActiveResource attribute
  class << self
    def primary_key
      @primary_key = '_id'
    end

    # # ADDING class method to configure BaseResource
    # def config ( target_site, apikey )
    #   self.site = target_site
    #   self.format = :badgeville_json
    #   # set a path that goes between the URL and the resource
    #   self.prefix = "/api/berlin/#{apikey}/"
    #   #self.apikey = '007857cd4fb9f360e120589c34fea080'
    # end

  end

  # OVERRIDING ActiveResource method in module Validations in order to
  # call the Badgeville.Errors constructor instead of the
  # ActiveResource::Errors constructor
  # Returns the Badgeville::Errors object that holds all information about attribute error messages.
  def errors
    @errors ||= Badgeville::Errors.new(self)
  end

  # OVERRIDING ActiveResource method in module Validations in order to
  # load_remote_errors() for the case where the format is the custom
  # BadgevilleJson format
  def load_remote_errors(remote_errors, save_cache = false ) #:nodoc:
    case self.class.format
    when ActiveResource::Formats[:xml]
      errors.from_xml(remote_errors.response.body, save_cache)
    when ActiveResource::Formats[:json]
      errors.from_json(remote_errors.response.body, save_cache)
    when ActiveResource::Formats[:badgeville_json]
        errors.from_badgeville_json(remote_errors.response.body, save_cache)
    end
  end





end




# SUBCLASSING for remote resources
class Activity < BaseResource
end

class ActivityDefinition < BaseResource
end

class Group < BaseResource
end

class Leaderboard < BaseResource
end

class Player < BaseResource
end

class Reward < BaseResource
end

class RewardDefinition < BaseResource
end

class Site < BaseResource
end

class Track < BaseResource
end

class User < BaseResource
end
