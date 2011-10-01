require "frozen_synapse/lazy_attributes"
require "open-uri"
require "json"

module FrozenSynapse
  # @attr_reader [String] username
  # @attr_reader [Number] wins
  # @attr_reader [Number] losses
  # @attr_reader [Number] level
  # @attr_reader [Time]   registered_at
  # @attr_reader [Float]  rating The user's rating according to the Elo rating system
  # @attr_reader [Hash<Symbol<:daily, :streak, :global> => String>] rank The user's ranks
  class User
    include FrozenSynapse::LazyAttributes
    extend FrozenSynapse::LazyAttributes

    lazy_attr_reader :wins
    lazy_attr_reader :losses
    lazy_attr_reader :level
    lazy_attr_reader :registered_at
    lazy_attr_reader :rating
    # TODO ranks
    def initialize(username)
      @username = username
      @wins = @losses = @level = @registered_at = @rating = @rank = nil
      @populated = false
    end

    # Populate the user object with all attributes. Normally you don't
    # have to call this method directly, unless you are using
    # {FrozenSynapse::Rankings)
    #
    # @return [void]
    # @see FrozenSynapse::Rankings
    def populate(force = false)
      return if @populated == true && !force
      data = FrozenSynapse.make_request("user/#{@username}/profile")
      @wins = data["wins"]
      @losses = data["losses"]
      @level = data["level"]
      @rank  = {
        :daily => data["daily_rank"],
        :streak => data["streak_rank"],
        :global => data["global_rank"],
      }
      @registered_at = Time.parse(data["date_full_registered"]) # TODO check if Time.parse is parsing correctly
      @rating = data["elo_rating"]

      @populated = true
    end
  end
end
