module RabbitMqCommon
  MEDICAL_TASK_QUEUE_NAME = 'medical.tasks'.freeze
  TASK_DONE_QUEUE_NAME = 'medical.done'.freeze
  ADMIN_QUEUE_NAME = 'medical.admin'.freeze
  AVAILABLE_SPECIALITIES = %w(knee elbow ankle).freeze

  def connect_and_create_channel
    @connection = Bunny.new(host: 'localhost')
    @connection.start
    @channel = @connection.create_channel
  end

  def open_doctor_and_technician_queues
    @task_done_queue = @channel.queue(TASK_DONE_QUEUE_NAME, durable: true, auto_delete: false)
    @new_task_queue = @channel.queue(MEDICAL_TASK_QUEUE_NAME, durable: true, auto_delete: false)
    @admin_message_queue = @channel.queue('', durable: true, auto_delete: false)
  end

  def subscribe_to_admin_queue
    @admin_message_queue.bind(admin_exchange).subscribe { |_, _, payload| puts "#{payload}".red }
  end

  def tasks_topic
    @tasks_topic ||= @channel.topic('tasks', auto_delete: true)
  end

  def admin_exchange
    @admin_exchange ||= @channel.fanout('admin', auto_delete: true)
  end

  def read_from_console
    STDIN.gets.chomp
  end
end
