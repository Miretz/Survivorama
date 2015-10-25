require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'

class Player

  attr_reader :x, :y, :lives, :angle
  attr_accessor :ammo

  def initialize
    
    @image = Gosu::Image.new(Constants::PLAYER_SPRITE)
    @beep = Gosu::Sample.new(Constants::BEEP_SOUND)

    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @ammo = 6
    @lives = 5
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def turn_left
    @angle -= 4.5
  end

  def turn_right
    @angle += 4.5
  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end

  def reverse
    @vel_x -= Gosu::offset_x(@angle, 0.5)
    @vel_y -= Gosu::offset_y(@angle, 0.5)
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= Constants::WIDTH
    @y %= Constants::HEIGHT

    @vel_x *= 0.90
    @vel_y *= 0.90
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Player, @angle)
  end

  def die
    @lives -= 1
  end

  def collectAmmo(ammos)
    ammos.reject! do |ammo|
      if Gosu::distance(@x, @y, ammo.x, ammo.y) < 35 then
        @ammo += 3
        @beep.play
        true
      else
        false
      end
    end
  end
end