require 'yajl'
require 'em-hiredis'

class ChatAction < Cramp::Websocket
  include GameWebSocketProtocol

  on_start :connected
  on_finish :disconnected
  on_data :data_received
  
  def connected
    #TODO: session handling might be awesome
    login_required!
  end
  
  def disconnected
    pubsub.broadcast "#{@user.login} has disconnected"
    pubsub.disconnect!
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
    current_area = @user.area
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
  
  def handle_talk(data)
    pubsub.chat(@user.login, data[:message])
  end
  
private
  def join_instance(user, instance)
    user.instance = instance
    user.save!

    pubsub.on_broadcast do |message|
      broadcast! message
    end

    pubsub.on_chat do |sender, message|
      display_talk! sender, message
    end
  end

  def join_world(user, world)
    join_instance user, Instance.main_instance

    pubsub.broadcast "#{user.login} has logged on"

    if user.area
      set_area! user.area
    else
      set_area! world.find_area_by_id("1-01")
    end    
  end

  def set_area!(area)
    @user.area = area
    @user.save!

    display_area!(area)
  end

  def pubsub
    @pubsub ||= PubSubClient.new(Instance.main_instance)
  end

end