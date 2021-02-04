# frozen_string_literal: true

require 'core/log'
require 'openhab/core/dsl/rule/triggers'

module OpenHAB
  module Core
    module DSL
      module Rule
        #
        # Channel triggers
        #
        module Channel
          include Logging

          #
          # Creates a channel trigger
          #
          # @param [Array] channels array to create triggers for on form of 'binding_id:type_id:thing_id#channel_id'
          #   or 'channel_id' if thing is provided
          # @param [thing] thing to create trigger for if not specified with the channel
          # @param [String] triggered specific triggering condition to match for trigger
          #
          #
          def channel(*channels, thing: nil, triggered: nil)
            channels.flatten.each do |channel|
              channel = [thing, channel].join(':') if thing
              logger.trace("Creating channel trigger for channel(#{channel}), thing(#{thing}), trigger(#{triggered})")
              [triggered].flatten.each do |trigger|
                config = { 'channelUID' => channel }
                config['event'] = trigger.to_s unless trigger.nil?
                config['channelUID'] = channel
                logger.trace("Creating Change Trigger for #{config}")
                @triggers << Trigger.trigger(type: Trigger::CHANNEL_EVENT, config: config)
              end
            end
          end
        end
      end
    end
  end
end
