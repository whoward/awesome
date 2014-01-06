
class ChannelMock
   attr_reader :auto_flush, :messages, :callbacks

   def initialize(auto_flush: false)
      @auto_flush = auto_flush
      @messages = []
      @callbacks = {}
   end

   def connected?
   end

   def connect
   end

   def connect!
   end

   def disconnect
   end

   def disconnect!
   end

   def publish(event, message)
      messages << [event, message]

      flush! if auto_flush
   end

   def subscribe(event, &callback)
      callbacks[event] = callback
   end

   def unsubscribe(event)
      callbacks.delete(event)
   end

   # test methods
   def flush!
      next! until messages.empty?
   end

   def next!
      if msg = messages.shift
         callbacks[msg[0]].try(:call, *msg)
      else
         false
      end
   end

end

describe ChannelMock do
   it_behaves_like "a channel", described_class.new(auto_flush: true)

   let(:flusher) { described_class.new(auto_flush: true) }
   let(:stepper) { described_class.new(auto_flush: false) }

   it 'adds to the length' do
      expect(-> { stepper.publish("hello", '{"message":"hello"}') }).to change(stepper.messages, :length).from(0).to(1)
   end

   it 'calls the given callback when publishing' do
      callback = -> {}
      expect(callback).to receive(:call).once.with("broadcast", 'hello')

      flusher.subscribe("broadcast", &callback)
      flusher.publish("fake", "fake")
      flusher.publish("broadcast", 'hello')
   end

   it 'does not call the callback after being unsubscribed' do
      callback = -> {}
      expect(callback).not_to receive(:call)

      flusher.subscribe("broadcast", &callback)
      flusher.unsubscribe("broadcast")
      flusher.publish("broadcast", 'hello')
   end
end