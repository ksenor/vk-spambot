class Bot < ActiveRecord::Base
  resourcify

  attr_accessible :account_id, :bot_type, :page, :page_title, :page_hash, :message, :count, :hours, :minutes
  attr_accessor :hours, :minutes

  belongs_to :account

  self.per_page = 10

  bot_type_regexp = /^(group|discussion)$/
  page_regexp     = /^(http:\/\/)(vk.com\/|vkontakte.ru\/).{10,25}$/

  validates :account_id,  :presence     => true

  validates :bot_type,    :presence     => true,
                          :format       => { :with    => bot_type_regexp,
                                             :message => 'can only be group or duiscussion.' }

  validates :page,        :presence     => true,
                          :format       => { :with    => page_regexp ,
                                             :message => 'must be in format http://vk.com/ or http://vkontakte.ru/, length of symbols after domain must be 10-25.' }

  validates :message,     :presence     => true

  validates :hours,       :presence     => true,
                          :numericality => { :only_integer             => true,
                                             :greater_than_or_equal_to => 0,
                                             :less_than_or_equal_to    => 24,
                                             :message                  => 'can only be between 0 and 24.' }

  validates :minutes,     :presence     => true,
                          :numericality => { :only_integer             => true,
                                             :greater_than_or_equal_to => 0,
                                             :less_than_or_equal_to    => 60,
                                             :message                  => 'can only be between 0 and 60.' }

  default_scope :order => 'bots.created_at DESC'

  before_validation :set_hours_minutes

  before_save :set_interval

  # Go, go, go!
  def run
    data = get_request_data

    response = RestClient.post "#{$service_url}/api/bot/run", data, { :content_type => :json, :accept => :json }

    update_title_and_hash(response)
  rescue => error
    { :status => :error, :message => error.to_s }
  end

  def get_request_data
    data         = {}
    bot_data     = attributes.except('created_at', 'updated_at')
    account_data = account.attributes.except('id', 'created_at', 'updated_at')

    bot_data.each_pair { |k,v| data.store(k.to_sym,v.to_s) }
    account_data.each_pair { |k,v| data.store(k.to_sym,v.to_s) }

    { :bot => Encryptor.encrypt(data.to_json, :key => $secret_key) }
  end

  # Trying to stop the bot in our sinatra part
  def stop
    data = { :bot => Encryptor.encrypt({:id => id}.to_json, :key => $secret_key) }
    RestClient.post "#{$service_url}/api/bot/stop", data, { :content_type => :json, :accept => :json }
  rescue => error
    { :status => :error, :message => error.to_s }
  end

  # We need to update our db entry with data that returned from sinatra
  def update_title_and_hash(response)
    response = JSON.parse(response)

    page_title = response['page_title']
    unless page_title.nil?
      update_attribute(:page_title, page_title)
    end

    page_hash = response['page_hash']
    unless page_hash.nil?
      update_attribute(:page_hash, page_hash)
    end

    response
  end

  def self.check_status(user_id)
    response = RestClient.get "#{$service_url}/api/user/#{user_id}/bots"

    JSON.parse(response)
  rescue
    {}
  end

  private

    def set_hours_minutes
      self.hours   = 0 if hours.nil?
      self.minutes = 0 if minutes.nil?
    end

    def set_interval
      if account.user.has_any_role?
        self.interval = hours.to_i.zero? && minutes.to_i.zero? ? 0 : "#{hours}h#{minutes}m"
      else
        self.interval = 0
      end
    end

end
