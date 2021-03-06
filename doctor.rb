class Doctor
  include RabbitMqCommon

  def initialize(params)
    @doctor_id = SecureRandom.uuid

    connect_and_create_channel
    subscribe_to_admin_queue
  end

  def loop_program
    bind_for_task_done_queue

    loop do
      puts 'Which part of body is wrong?'.green
      part = read_from_console

      unless RabbitMqCommon::AVAILABLE_SPECIALITIES.include?(part)
        puts 'We can\'t check that part...'.red
        next
      end

      puts 'What\'s patient name?'.green
      patient_name = read_from_console
      puts 'Any additional message?'.green
      message = read_from_console

      send_task(part, patient_name, message)
    end
  end

  private

  def bind_for_task_done_queue
    @queue = @channel.queue('', durable: true, auto_delete: false)
    @queue = @queue.bind(tasks_exchange, routing_key: @doctor_id)

    @queue.subscribe { |_, _, payload| puts "#{payload}".blue }
  end

  def send_task(part, patient_name, message)
    tasks_exchange.publish(
      "#{patient_name};#{message}",
      routing_key: part,
      reply_to: @doctor_id,
    )
  end
end
