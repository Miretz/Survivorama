require 'gosu'

require_relative 'Constants'
require_relative 'ZOrder'
require_relative 'Player'
require_relative 'Ammo'
require_relative 'Explosion'
require_relative 'Bullet'
require_relative 'Enemy'

class GameWindow < Gosu::Window
  def initialize
    super Constants::WIDTH, Constants::HEIGHT, :fullscreen => false
    self.caption = Constants::CAPTION

    @background_image = Gosu::Image.new(Constants::BACKGROUND, :tileable => true)
    @ammo_anim = Gosu::Image::load_tiles(Constants::AMMO_SPRITE, 25, 25)
    @explosion_anim = Explosion.load_animation(self)
    @font = Gosu::Font.new(24)

    start
  end

  def start
    @player = Player.new
    @player.warp(Constants::WIDTH / 2.0, Constants::HEIGHT / 2.0)

    @enemy = Enemy.new
    @enemy.warp(Constants::WIDTH / 2.0, Constants::HEIGHT - 40)

    @kills = 0

    @ammos = Array.new

    @explosions = []
    @bullets = []


    @time = Constants::TIME_LIMIT
    @last_time = Gosu::milliseconds

    @running = true
  end

  def update

    if not @running
      return
    end

    handleTimeLimit
    handlePlayerMove
    handleAmmoDissapear
    handleExplosions
    handleEnemy
    handleBullets

    @player.collectAmmo(@ammos)

    generateNewAmmo
    removeOffscreenBullets
  end

  def handleExplosions
    @explosions.each do |expl|
      if expl.explosion_peak? and Gosu::distance(@player.x, @player.y, expl.x, expl.y) < 45 then
        @player.die
        @explosions.push(Explosion.new(@explosion_anim, @player.x, @player.y, 25))
        @player.warp(Constants::WIDTH / 2.0, Constants::HEIGHT / 2.0)
        if @player.lives < 1
          @running = false
        end
      end
    end
    @explosions.reject!(&:done?)
    @explosions.map(&:update)
  end

  def handleEnemy
    @enemy.move(@player.x, @player.y)
    if Gosu::distance(@enemy.x, @enemy.y, @player.x, @player.y) < 60
      @explosions.push(Explosion.new(@explosion_anim, @enemy.x, @enemy.y))
      @explosions.push(Explosion.new(@explosion_anim, @player.x, @player.y))
      @enemy.die
      @player.die
      @player.warp(Constants::WIDTH / 2.0, Constants::HEIGHT / 2.0)
      if @player.lives < 1
        @running = false
      end
    end
  end

  def handleBullets
    @bullets.each do |bullet|
      bullet.move
      if Gosu::distance(@enemy.x, @enemy.y, bullet.x, bullet.y) < 60
        @explosions.push(Explosion.new(@explosion_anim, @enemy.x, @enemy.y))
        @enemy.die
        @kills += 1
      end
    end
  end

  def removeOffscreenBullets
    @bullets.reject! do |bullet|
      if bullet.x < 0 or bullet.x > Constants::WIDTH then
        true
      elsif bullet.y < 0 or bullet.y > Constants::HEIGHT then
        true
      else
        false
      end
    end
  end

  def generateNewAmmo
     if rand(100) < 4 and @ammos.size < 5 then
      @ammos.push(Ammo.new(@ammo_anim))
    end
  end

  def handleAmmoDissapear
    @ammos.reject! do |ammo|
      if ammo.dead? then
        true
      else
        false
      end
    end
  end

  def handleTimeLimit
    if (Gosu::milliseconds - @last_time) > 1000
      @time -= 1
      @last_time = Gosu::milliseconds
    end

    if @time < 0
      @running = false
    end
  end

  def handlePlayerMove
    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
      @player.turn_left
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
      @player.turn_right
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
      @player.accelerate
    end
    if Gosu::button_down? Gosu::KbDown or Gosu::button_down? Gosu::GpButton1 then
      @player.reverse
    end
    @player.move
  end

  def draw
  	@background_image.draw(0, 0, ZOrder::Background)
    
    if @running
      @bullets.each(&:draw)
      @player.draw
      @enemy.draw
  	  @ammos.each(&:draw)
      @explosions.map(&:draw)

      visualBullets = "|" * @player.ammo
      @font.draw("Ammo: #{visualBullets}", 650, 550, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Lives: #{@player.lives}", 20, 550, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Time: #{@time}", 650, 20, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    else
      @font.draw("GAME OVER! You killed #{@kills} monsters", 300, 300, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("Press Enter to restart or Escape to exit the game...", 200, 320, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape then
      close
    end
    if id == Gosu::KbReturn then
      start
    end
    if id == Gosu::KbSpace then
      if @bullets.size < 10 and @player.ammo > 0 then
        @player.ammo -= 1
        @bullets.push(Bullet.new(@player.x, @player.y, @player.angle))
      end
    end
  end

end

window = GameWindow.new
window.show
