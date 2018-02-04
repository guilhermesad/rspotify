module RSpotify

  # @attr [String]      id              The device ID. This may be null
  # @attr [Boolean]     is_active       If this device is the currently active device
  # @attr [Boolean]     is_restricted   Whether controlling this device is restricted. At present if this is "true" then no Web API commands will be accepted by this device.
  # @attr [String]      name            The name of the device
  # @attr [String]      type            Device type, such as "Computer", "Smartphone" or "Speaker".
  # @attr [String]      volume_percent  The current volume in percent. This may be null
  class Device < Base
    def initialize(options = {})
      @id             = options['id']
      @is_active      = options['is_active']
      @is_restricted  = options['is_restricted']
      @name           = options['name']
      @type           = options['type']
      @volume_percent = options['volume_percent']
    end
  end
end
