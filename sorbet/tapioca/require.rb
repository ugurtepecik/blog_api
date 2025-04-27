# typed: true
# frozen_string_literal: true

require "active_support/core_ext/integer/time"
require "active_support/core_ext/string/inflections"
require "bootsnap/setup"
require "bundler/setup"
require "dry-struct"
require "dry-types"
require "dry/monads"
require "fileutils"
require "jwt"
require "optparse"
require "rails/all"
require "rails/test_help"
require "sorbet-runtime"
