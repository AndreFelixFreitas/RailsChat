class ChatController < WebSocketApplicationController
  periodic_timer :retrieve_messages, :every => 0.1
  on_data :receive_message

  def retrieve_messages
  end

  def receive_message(data)
  end
end
