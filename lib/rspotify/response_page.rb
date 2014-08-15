module RSpotify

  # @attr [Class]        item_klass    The type of each item in the items array
  # @attr [Array]        items         The array of type item_klass items
  # @attr [Integer]      limit         The effective page size (usually 100)
  # @attr [Integer]      offset        How many items were skipped
  # @attr [Integer]      total         Total number of items that exist for paging through
  # @attr [String]       next          Url to the next page of results
  # @attr [String]       previous      Url to the previous page of results
  class ResponsePage < Base
    include Enumerable


    # TODO: maybe move this to each klass? Kinda nice though to have all pagination stuff in one file though
    KLASS_ITEM_NAMES = {
      Track => 'track'
    }


    def initialize(response, item_klass)
      @item_klass = item_klass
      @limit = response['limit']
      @offset = response['offset']
      @total = response['total']
      @next = response['next']
      @previous = response['previous']
      @items = if items = response['items']
        name = KLASS_ITEM_NAMES[item_klass]
        items.map do |item|
          item_klass.new item[name]
        end
      else
        []
      end
    end

    # Called by Enumerable
    def each(&block)
      @items.each do |item|
        block.call(item)
      end
    end


    # backwards compatability with former tracks array
    def size
      @items.length
    end

  end

end