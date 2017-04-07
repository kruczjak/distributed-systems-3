class Technician
  include RabbitMqCommon

  def initialize(params)
    @specialities = [params[0], params[1]]

    @specialities.each { |s| raise 'Wrong speciality' unless RabbitMqCommon::AVAILABLE_SPECIALITIES.include?(s) }

    connect_and_create_channel
    open_doctor_and_technician_queues
    subscribe_to_admin_queue
  end

  def loop_program
    @channel.prefetch(1)
    start_listening_on_tasks

    loop do
      sleep 100
    end
  end

  private

  def start_listening_on_tasks
    @new_task_queue = @new_task_queue.bind(tasks_exchange, routing_key: @specialities[0])
    @new_task_queue = @new_task_queue.bind(tasks_exchange, routing_key: @specialities[1])

    @new_task_queue.subscribe(manual_ack: true) do |delivery_info, properties, payload|
      # puts "Received #{payload}, message properties are #{properties.inspect} and #{delivery_info.inspect}".blue
      puts "Doctor #{properties[:reply_to]} wants to check " \
           "#{delivery_info[:routing_key]} for #{payload.split(';')[0]}".blue

      sleep 10

      @channel.acknowledge(delivery_info.delivery_tag, false)
      puts 'Job done, let\'s respond'.green

      tasks_exchange.publish(
        "Hi!, Job #{delivery_info[:routing_key]}: #{payload} is done :)",
        routing_key: properties[:reply_to],
      )
    end
  end
end
