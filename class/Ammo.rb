require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'

class Ammo
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @x = rand * Constants::WIDTH
    @y = rand * Constants::HEIGHT
    @start_time = Gosu::milliseconds
  end

  def draw  
    img = @animation[Gosu::milliseconds / 100 % @animation.size];
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0, ZOrder::Ammo, 1, 1)
  end

  def dead?
    (Gosu::milliseconds - @start_time) > Constants::AMMO_LIFE_TIME
  end

end