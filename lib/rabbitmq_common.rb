module RabbitMqCommon
  MEDICAL_TASK_QUEUE_NAME = 'medical.tasks'.freeze
  TASK_DONE_QUEUE_NAME = 'medical.done'.freeze
  AVAILABLE_SPECIALITIES = %w(knee elbow ankle).freeze

  def connect_and_create_channel
    @connection = Bunny.new(host: 'localhost')
    @connection.start
    @channel = @connection.create_channel
  end

  def open_doctor_and_technician_queues
    @task_done_queue = @channel.queue(TASK_DONE_QUEUE_NAME, durable: true, auto_delete: false)
    @new_task_queue = @channel.queue(MEDICAL_TASK_QUEUE_NAME, durable: true, auto_delete: false)
  end

  def tasks_topic
    @tasks_topic ||= @channel.topic('tasks', auto_delete: true)
  end
end
