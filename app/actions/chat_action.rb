require 'yajl'
require 'em-hiredis'

class ChatAction < Cramp::Websocket
  on_start :connected
  on_finish :disconnected
  on_data :data_received
  
  def connected
    @pub = EM::Hiredis.connect("redis://localhost:6379")
    @sub = EM::Hiredis.connect("redis://localhost:6379")

    #TODO: session handling might be awesome
    login_required!
  end
  
  def disconnected
    emit :talk, :message => "User has disconnected", :sender => "Server"

    @pub.close_connection
    @sub.close_connection
  end
  
  def data_received(data)
    msg = parse_json(data)

    handler_method = "handle_#{msg[:action]}"

    if respond_to?(handler_method, false)
      send(handler_method, msg)
    else
      puts "unhandled message action: #{msg[:action].inspect}"
    end
  end

  def handle_login(data)
    username = data[:username]
    password = data[:password]

    if username.blank? or password.blank?
      return login_failure! "Please provide both a username and password"
    end

    #TODO: check if the user is already logged in

    @user = User.find_by_credentials login: username, password: password

    if @user == nil
      login_failure! "Login error: no matching credentials for the username/password you provided"
    else
      login_success! "You have successfully logged in, welcome!"

      join_world(@user, World.instance)
    end
  end

  def handle_register(data)
    username = data[:username]
    password = data[:password]
    #TODO: need a password confirmation

    if username.blank? or password.blank?
      return register_failure! "Please provide both a username and password"
    end

    user = User.new(login: username, password: password, password_confirmation: password)

    if user.valid?
      user.save!

      @user = user

      register_success! "You have successfully registered! now logging you in."

      join_world(@user, World.instance)
    else
      register_failure! "Whoops! #{user.errors.full_messages.to_sentence}"
    end
  end

  def handle_travel(data)
    current_area = @area
    next_area = current_area.find_exit_by_name(data[:direction])

    if next_area == nil
      return undefined_direction! "You canot go in that direction"
    end

    set_area!(next_area)

    # if current_area
      # current_area.notify_exit(this, direction)
      # next_area.notify_entrance(this, current_area, direction)
    # end
  end
  
  def handle_talk(msg)
    # publish msg.merge(:user => @user.login)
  end
  
private
  def join_world(user, world)
    subscribe

    broadcast! "#{user.login} has logged on"

    set_area! world.find_area_by_id("1-01")
  end

  def login_required!
    emit :login_required, :message => "Welcome to Seven Helms, please log in or register a new account."
  end

  def login_failure!(message)
    emit :login_failure, :message => message
  end

  def login_success!(message)
    emit :login_success, :message => message
  end

  def register_failure!(message)
    emit :register_failure, :message => message
  end

  def register_success!(message)
    emit :register_success, :message => message
  end

  def broadcast!(message)
    emit :broadcast, :message => message
  end

  def set_area!(area)
    @area = area
    emit :display_area, :area => area.serialized_attributes
  end

  def undefined_direction!(message)
    emit :undefined_direction, :message => message
  end

  def subscribe
    @sub.subscribe('chat')
    @sub.on(:message) {|channel, message| render(message) }    
  end
  
  def publish(type, message)
    @pub.publish(type, encode_json(message))
  end

  def emit(action, data={})
    render Yajl::Encoder.encode(data.merge(action: action))
  end
  
  def encode_json(obj)
    Yajl::Encoder.encode(obj)
  end
  
  def parse_json(str)
    Yajl::Parser.parse(str, :symbolize_keys => true) rescue {}
  end
end