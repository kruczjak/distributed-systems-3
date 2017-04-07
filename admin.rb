class Admin
  include RabbitMqCommon

  def initialize(params)
    connect_and_create_channel
    @admin_queue = @channel.queue(RabbitMqCommon::ADMIN_QUEUE_NAME, durable: true, auto_delete: false)
  end

  def loop_program
    bind_for_listening_all

    loop do
      puts 'Write message to send to all'.green
      send_admin_message(read_from_console)
    end
  end

  private

  def send_admin_message(message)
    admin_exchange.publish(message)
  end

  def bind_for_listening_all
    @admin_queue = @admin_queue.bind(tasks_exchange, routing_key: '#')

    @admin_queue.subscribe do |delivery_info, properties, payload|
      puts '-------------------------------------------------------'.white
      puts "delivery_info: #{delivery_info.inspect}".blue
      puts "properties: #{properties.inspect}".green
      puts "payload: #{payload.inspect}".yellow
    end
  end
end
