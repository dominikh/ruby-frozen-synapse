require "frozen_synapse/user"
require "open-uri"
require "json"

module FrozenSynapse
  module Top5
    # @return [Array<User>]
    def self.global
      FrozenSynapse.make_request("top_5/global").map{ |s| User.new(s) }
    end

    # @return [Array<User>]
    def self.daily
      FrozenSynapse.make_request("top_5/daily").map{ |s| User.new(s) }
    end

    # @return [Array<User>]
    def self.streak
      FrozenSynapse.make_request("top_5/streak").map{ |s| User.new(s) }
    end
  end

  # @note {User Users} returned by any of the methods in this module
  #   will have the rank only initialized for the requested list
  #   (global, daily or streak). If you need the other ranks to be
  #   available as well, call {User#populate}. But please be aware
  #   that doing this for all returned users will put heavy strain on
  #   the API server.
  module Rankings
    # @return [Array<User>]
    def self.global
      list_to_users(FrozenSynapse.make_request("rankings/global"), :global)
    end

    # @return [Array<User>]
    def self.daily
      list_to_users(FrozenSynapse.make_request("rankings/daily"), :daily)
    end

    # @return [Array<User>]
    def self.streak
      list_to_users(FrozenSynapse.make_request("rankings/streak"), :streak)
    end

    # @api private
    def self.list_to_users(list, type)
      users = []
      list.each do |data|
        user = User.new(data["name"])
        user.lazy_initialize(:rating => data["elo_rating"],
                             :wins   => data["wins"],
                             :losses => data["losses"],
                             :rank   => {type => data["rank"]})
      end
    end
  end

  # @api private
  API_URI = "http://slashsrv.com/projects/fs-api/"

  # @return [Array<User>] All currently connected users, as reported
  #   by the server.
  def self.online
    users = FrozenSynapse.make_request("online")
    users.map do |data|
      user = User.new(data["name"])
      user.instance_variable_set(:@level, data["level"]) unless data["level"] == 0
      user
    end
  end

  # @api private
  def self.make_request(payload)
    open(API_URI + payload) do |f|
      return JSON.parse(f.read)
    end
  end
end
