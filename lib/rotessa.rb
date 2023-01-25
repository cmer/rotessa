# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/array/wrap"

require_relative "rotessa/version"
require_relative "rotessa/client"

module Rotessa
  class Error < StandardError; end
  # Your code goes here...
end
