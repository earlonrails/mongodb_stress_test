# patch j-ruby array
class Array
  def choice
    self[rand(self.size) - 1]
  end
end

module Record

  def random_personal_info
    first_name      = ["Kevin", "Mitch", "Tyler", "Jay", "Erik", "Chad", "Philup", "Jane", "Jill", "Luke"].choice
    last_name       = ["Smith", "Jones", "Black", "White", "Rome", "Rodgers", "Skywalker", "Griffin", "Keys", "Doe"].choice
    drivers_license = random_string(12)
    address         = random_address
    phone           = random_phone_number
    weight          = random_number(3)
    eye_color       = random_color
    hair_color      = random_color
    height          = random_number(3)
    race            = ["White", "African-American", "Asian", "Indian", "Native American", "Latino"].choice
    login_history   = random_login_hash
    return { :first_name => first_name,
             :last_name  => last_name,
             :drivers_license => drivers_license,
             :address => address,
             :phone => phone,
             :weight => weight,
             :eye_color => eye_color,
             :hair_color => hair_color,
             :height => height,
             :race => race,
             :login_history => login_history
    }
  end

  def random_address
    random_number(5) + [" Main", " First", " Broadway", " Market", " Milton", " Pine"].choice + [" St", " Ln", " Pl", " Ct", "Blvd"].choice
  end

  def random_string(length)
    (0...length).map{ 65.+(rand(26)).chr }.join
  end

  def random_number(length)
    (0...length).map{ rand(9) }.join
  end

  def random_phone_number
    "#{random_number(3)}-#{random_number(3)}-#{random_number(4)}"
  end

  def random_color
    ["Blue", "Brown", "Green", "Red", "Black"].choice
  end

  def random_login_hash
    {:time_stamp => random_time, :ip => "#{random_number(3)}.#{random_number(3)}.#{random_number(3)}", :hostname => random_string(12), :idle_time => rand(300)}
  end

  def random_time
    Time.at(rand * Time.now.to_i)
  end

  def random_field
    info = random_personal_info
    info.delete(:login_history)
    info.keys.choice
  end

end