module Bots
  class Discussion < Core::Bot
    def initialize(email, password, page, hash, message, count)
      bot = Core::Bot.new(email, password)
      bot.login
      @config         = ParseConfig.new('cfg/bots/discussion_cfg')
      @count          = (1..8).member?(count.to_i) ? count.to_i : 1
      @discussion_id  = '-' + page[/\d+_\d+/].to_s
      @hash           = hash
      @message        = message
      @msg_count      = 0
    end

    def spam
      params = {
        :act     => "post_comment",
        :topic   => @discussion_id,
        :hash    => @hash,
        :comment => @message
      }
      @count.times do
        @msg_count += 1
        p 'Sending discussion message #' + @msg_count.to_s
        params[:comment] = @message + "\n\n" + rand(1000000000..9999999999).to_s
        @@agent.post(@config.get_value('wall_php'), params)
      end if @@logged_in
    end
  end
end
