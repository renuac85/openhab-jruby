# frozen_string_literal: true

# @deprecated OH4.0 this guard is not needed on OH4.1
return unless OpenHAB::Core.version >= OpenHAB::Core::V4_1

require "forwardable"

module OpenHAB
  module Core
    module Types
      TimeSeries = org.openhab.core.types.TimeSeries

      #
      # {TimeSeries} is used to transport a set of states together with their timestamp.
      #
      # The states are sorted chronologically. The entries can be accessed like an array.
      #
      # @since openHAB 4.1
      #
      # @example
      #   time_series = TimeSeries.new # defaults to :add policy
      #                           .add(Time.at(2), DecimalType.new(2))
      #                           .add(Time.at(1), DecimalType.new(1))
      #                           .add(Time.at(3), DecimalType.new(3))
      #   logger.info "first entry: #{time_series.first.state}" # => 1
      #   logger.info "last entry: #{time_series.last.state}" # => 3
      #   logger.info "second entry: #{time_series[1].state}" # => 2
      #   logger.info "sum: #{time_series.sum(&:state)}" # => 6
      #
      # @see DSL::Rules::BuilderDSL#time_series_updated #time_series_updated rule trigger
      #
      class TimeSeries
        extend Forwardable

        # @!attribute [r] policy
        #   Returns the persistence policy of this series.
        #   @see org.openhab.core.types.TimeSeries#getPolicy()
        #   @return [org.openhab.core.types.TimeSeries.Policy]

        # @!attribute [r] begin
        #   Returns the timestamp of the first element in this series.
        #   @return [Instant]

        # @!attribute [r] end
        #   Returns the timestamp of the last element in this series.
        #   @return [Instant]

        # @!attribute [r] size
        #   Returns the number of elements in this series.
        #   @return [Integer]

        #
        # Create a new instance of TimeSeries
        #
        # @param [:add, :replace, org.openhab.core.types.TimeSeries.Policy] policy
        #   The persistence policy of this series.
        #
        def initialize(policy = :replace)
          policy = Policy.value_of(policy.to_s.upcase) if policy.is_a?(Symbol)
          super
        end

        # Returns true if the series' policy is `ADD`.
        # @return [true,false]
        def add?
          policy == Policy::ADD
        end

        # Returns true if the series' policy is `REPLACE`.
        # @return [true,false]
        def replace?
          policy == Policy::REPLACE
        end

        # @!visibility private
        def inspect
          "#<OpenHAB::Core::Types::TimeSeries " \
            "policy=#{policy} " \
            "begin=#{self.begin} " \
            "end=#{self.end} " \
            "size=#{size}>"
        end

        #
        # Returns the content of this series.
        # @return [Array<org.openhab.core.types.TimeSeries.Entry>]
        #
        def states
          get_states.to_array.to_a.freeze
        end

        # rename raw methods so we can overwrite them
        # @!visibility private
        alias_method :add_instant, :add

        #
        # Adds a new element to this series.
        #
        # Elements can be added in an arbitrary order and are sorted chronologically.
        #
        # @note This method returns self so it can be chained, unlike the Java version.
        #
        # @param [Instant, #to_zoned_date_time, #to_instant] instant An instant for the given state.
        # @param [State] state The State at the given timestamp.
        # @return [self]
        #
        def add(instant, state)
          instant = instant.to_zoned_date_time if instant.respond_to?(:to_zoned_date_time)
          instant = instant.to_instant if instant.respond_to?(:to_instant)
          add_instant(instant, state)
          self
        end

        # any method that exists on Array gets forwarded to states
        delegate (Array.instance_methods - instance_methods) => :states
      end
    end
  end
end

TimeSeries = OpenHAB::Core::Types::TimeSeries unless Object.const_defined?(:TimeSeries)
