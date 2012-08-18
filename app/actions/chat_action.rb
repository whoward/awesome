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
    if @user
      pubsub.broadcast "#{@user.login} has disconnected"
      @user.logout!
    end
    
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

    @user = User.find_by_credentials login: username, password: password

    return login_failure!("Login error: no matching credentials for the username/password you provided") if @user == nil

    if @user.logged_in
      login_failure! "That account is already in use (perhaps a bad thing?)"
    else
      @user.login!

      login_success! "You have successfully logged in, welcome!"

      join_world(@user, World.instance)
    end
  end

  def handle_register(data)
    username = data[:username]
    password = data[:password]

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
  end
  
  def handle_talk(data)
    pubsub.chat(@user.login, data[:message])
  end

  def handle_pm(data)
    recipient = User.logged_in.where(:login => data[:username]).first

    if recipient == nil
      return error_message! "#{data[:username]} is not logged in"
    end

    pubsub.private_message(recipient.id, @user.login, data[:message])
  end

  def handle_list(data)
    user_list! User.in_instance(@user.instance).only(:login).map(&:login)
  end
  
private
  def join_world(user, world)
    user.instance = Instance.main_instance
    user.save!

    subscribe!

    pubsub.broadcast "#{user.login} has logged on"

    if user.area
      set_area! user.area
    else
      set_area! world.find_area_by_id("1-01")
    end    
  end

  def subscribe!
    pubsub.on_broadcast do |message|
      broadcast! message
    end

    pubsub.on_chat do |sender, message|
      display_talk! sender, message
    end

    pubsub.on_private_message do |sender, message|
      display_private_message! sender, message
    end

    pubsub.on_area_travel do |user, from_area_id, to_area_id|
      # ignore travel messages from this user
      if user != @user.login
        if from_area_id == @user.area_id
          # user is exiting the area
          direction = @user.area.find_exit_by_id(to_area_id)

          player_leaves_area! user, direction
        else
          # user is entering the area
          direction = @user.area.find_exit_by_id(from_area_id)

          player_enters_area! user, direction
        end
      end
    end
  end

  def set_area!(area)
    # notify other players of the user's movement
    pubsub.area_travel(@user.login, @user.area_id, area.id)

    # update the database record for the user's area
    @user.area = area
    @user.save!

    # change the area we receive event notifications from
    pubsub.area = area

    # display the new area to the player (duplicate the area so that the player
    # list is not permanently mutated).
    displayed_area = area.dup
    displayed_area.players = User.in_instance(@user.instance).in_area(area).only(:login).map(&:login)

    display_area!(area)
  end

  def pubsub
    @pubsub ||= PubSubClient.new(@user)
  end

end