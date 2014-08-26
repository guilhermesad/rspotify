module RSpotify
  # ResponsePage represent one page of items returned from the API.  It has metadata about the entire set 
  # that allows for easy pagination from page to page.  Example usage:
  # 
  # track_page = user.playlist.tracks
  # while track_page
  #  track_page.each do |track|
  #    puts "#{track.inspect}"
  #  end 
  #  track_page = track_page.next_page
  # end

  # @attr [Class]        item_class    The type of each item in the items array
  # @attr [Array]        items         The array of type item_class items
  # @attr [Integer]      limit         The effective page size (usually 100)
  # @attr [Integer]      offset        How many items were skipped
  # @attr [Integer]      total         Total number of items that exist for paging through
  # @attr [String]       next          Url to the next page of results
  # @attr [String]       previous      Url to the previous page of results
  class ResponsePage < Base
    include Enumerable

    def initialize(page_response, item_class, item_name, opts={})
      @page_response = page_response
      @item_class = item_class
      @item_name = item_name
      @limit = page_response['limit']
      @offset = page_response['offset']
      @total = page_response['total']
      
      if @next = page_response['next'] || false
        @next = RSpotify.normalize_api_path(@next)
      end

      if @previous = page_response['previous'] || false
        @previous = RSpotify.normalize_api_path(@previous)
      end

      # for caching when we already have a page of data
      @previous_page = opts[:previous_page]
      @next_page = opts[:next_page]

      @items = if items = page_response['items']
        items.map do |item|
          item_class.new item[item_name]
        end
      else
        []
      end
    end

    # Fetches previous ResponsePage if one exists
    def previous_page
      @previous_page ||= if @previous
        response = RSpotify.auth_get @next
        ResponsePage.new(response, @item_class, @item_name, next_page: self)
      end
    end

    # Fetches next ResponsePage if one exists
    def next_page
      @next_page ||= if @next
        response = RSpotify.auth_get @next
        ResponsePage.new(response, @item_class, @item_name, previous_page: self)
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
    # backwards compatability with former tracks array
    def length
      @items.length
    end

  end

end