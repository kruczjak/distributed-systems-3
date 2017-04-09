module RabbitMqCommon
  MEDICAL_QUEUE_NAME = 'medical.'.freeze
  ADMIN_QUEUE_NAME = 'medical.log'.freeze
  AVAILABLE_SPECIALITIES = %w(knee elbow ankle).freeze

  def connect_and_create_channel
    @connection = Bunny.new(host: 'localhost')
    @connection.start
    @channel = @connection.create_channel
  end

  def subscribe_to_admin_queue
    @admin_message_queue = @channel.queue('', durable: true, auto_delete: false)
    @admin_message_queue.bind(admin_exchange).subscribe { |_, _, payload| puts "#{payload}".red }
  end

  def tasks_exchange
    @tasks_exchange ||= @channel.topic('tasks', auto_delete: true)
  end

  def admin_exchange
    @admin_exchange ||= @channel.fanout('admin', auto_delete: true)
  end

  def read_from_console
    STDIN.gets.chomp
  end
end
