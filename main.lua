--local saveData = require "resources/libs/saveData/saveData"

function love.load()
  --altura do botão
  button_height = 48
  
  --adiciona botões para um menu principal
  function newButton(text,fn)
    return{
      text = text,
      fn = fn,
      now = false,
      last = false
    }
  end

  buttons = {}
  
  --cria os botoes da GUI, com suas respectivas funções
  table.insert(buttons, newButton(
      "CONTINUAR",
      function()
        --print("Starting Game")
        gamePaused = false
      end))
  
  table.insert(buttons, newButton(
      "INSTRUÇÕES",
      function()
        print("Loading Game")
      end))
  --[[
  table.insert(buttons, newButton(
      "RECORDES",
      function()
        print("Settings Menu")
      end))
  ]]--
  table.insert(buttons, newButton(
      "SAIR",
      function()
        --saveData.save(hiscores, "resources/hi")
        love.event.quit(0)  --sai do aplicativo
      end))
  ----------------------------------------------------------------------------------
  --pega o tamanho da tela
  windowW = love.graphics.getWidth()
  windowH = love.graphics.getHeight()
  
  --determina se o jogo está rodando ou não
  gamePaused = true
  
  --determina a dificuldade de cada asteróide 
  asteroidStages = {
    {
      score = 50,
      speed = 120,
      radius = 15
    },
    {
      score = 25,
      speed = 70,
      radius = 30
    },
    {
      score = 10,
      speed = 50,
      radius = 50
    },
    {
      score = 5,
      speed = 20,
      radius = 80
    }
  }
   
  bulletRadius = 5  --raio dos tiros
  score = 0  --placar atual jogo
  maxScore = 0 --placar máximo do jogo (é apagado quando o jogo encerra)
  font = love.graphics.newFont("resources/fonts/Gamer.ttf", 36) --fonte usada no jogo
  
  --inicia ou reseta o level
  function reset()
    --[[carrega os dados da nave]]--
    ship = {}
      ship.x = windowW / 2                      --posição inicial em x
      ship.y = windowH / 2                      --posição inicial em y
      ship.radius = 30 
      ship.speedX = 0                           --velocidade inicial x
      ship.speedY = 0                           --velocidade inicial y
      ship.angle = 0                            --ângulo inicial da nave
      ship.acceleration = 10                    --velocidade de rotação da nave
      ship.image = love.graphics.newImage("resources/images/navinha.png") --sprite da nave
    
    bullets = {}  --carrega os dados das balas(tiros)
  
    --carrega os dados dos asteróides
    asteroids = {
      {
        x = 100,
        y = 100,
      },
      {
        x = windowW - 100,
        y = 100,
      },
      {
        x = windowW / 2,
        y = windowH - 100,
      }
    }
    
    bulletTimer = 0   --intervalo entre um disparo e outro
    
    --inicia o ângulo de movimento e o nível de cada asteróide
    for asteroidIndex, asteroid in ipairs(asteroids) do
      asteroid.angle = love.math.random() * (2 * math.pi)
      asteroid.stage = #asteroidStages
    end
  end
  
  reset()  
end

function love.update(dt)
  --verifica se dois círculos possuem interseção
  local function areCirclesIntersecting(aX, aY, aRadius, bX, bY, bRadius)
    return (aX - bX)^2 + (aY - bY)^2 <= (aRadius + bRadius)^2
  end
    
  bulletTimer = bulletTimer + dt
  
  --[[verifica se o game não está pausado para rodar]]--
  if not gamePaused then
    
    --[[controles de rotação da nave]]--
    if love.keyboard.isDown("right") then
      ship.angle = (ship.angle + ship.acceleration * dt) % (2 * math.pi)
    end
    if love.keyboard.isDown("left") then
      ship.angle = (ship.angle - ship.acceleration * dt) % (2 * math.pi)
    end
    
    --acelera a nave na direção em que está apontando
    if love.keyboard.isDown("up") then
      local speed = 250
      ship.speedX = ship.speedX + math.cos(ship.angle) * speed * dt
      ship.speedY = ship.speedY + math.sin(ship.angle) * speed * dt
    end
     
    --faz a nave disparar
    if love.keyboard.isDown("space") then
      if bulletTimer >= 0.5 then
        bulletTimer = 0
        --insere na table bullets os atributos bullets.x e bullets.y com as coordenadas da nave
        table.insert(bullets,{
            x = ship.x,
            y = ship.y,
            angle = ship.angle,
            timeLeft = 2
          })
      end
    end
      
    --[[movimenta os tiros na direção apontada]]--
    for bulletIndex = #bullets, 1, -1 do
      local bullet = bullets[bulletIndex]
      
      bullet.timeLeft = bullet.timeLeft - dt      --depois de um tempo, o tiro desaparece
      if bullet.timeLeft <= 0 then
        table.remove(bullets, bulletIndex)
      else
        local bulletSpeed = 500
        bullet.x = (bullet.x + math.cos(bullet.angle) * bulletSpeed * dt) % windowW
        bullet.y = (bullet.y + math.sin(bullet.angle) * bulletSpeed * dt) % windowH
      end
      
      --[[remove o asteróide, caso seja atingido por um tiro]]--
      for asteroidIndex = #asteroids, 1, -1 do
        local asteroid = asteroids[asteroidIndex]

        if areCirclesIntersecting(bullet.x, bullet.y, bulletRadius, asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius) then
          table.remove(bullets, bulletIndex)
          
          score = score + asteroidStages[asteroid.stage].score  --aumenta o placar de acordo com o stage do asteróide
          
          --[[determina o placar máximo]]--
          if score > maxScore then
            maxScore = score
          end
          
          if asteroid.stage > 1 then
            local angle1 = love.math.random() * (2 * math.pi)
            local angle2 = (angle1 - math.pi) % (2 * math.pi)
          
            table.insert(asteroids, {
              x = asteroid.x,
              y = asteroid.y,
              angle = angle1,
              stage = asteroid.stage - 1
            })
            table.insert(asteroids, {
              x = asteroid.x,
              y = asteroid.y,
              angle = angle2,
              stage = asteroid.stage - 1
            })
          end
          
          table.remove(asteroids, asteroidIndex)
          break
        end
      end
    end
  
  --[[altera a posição da nave]]--
  ship.x = (ship.x + ship.speedX * dt) % windowW
  ship.y = (ship.y + ship.speedY * dt) % windowH
  
  --[[movimenta os asteróides na direção do ângulo]]--
    for asteroidIndex, asteroid in ipairs(asteroids) do
      --local asteroidSpeed = 20
      asteroid.x = (asteroid.x + math.cos(asteroid.angle) * asteroidStages[asteroid.stage].speed * dt) % windowW
      asteroid.y = (asteroid.y + math.sin(asteroid.angle) * asteroidStages[asteroid.stage].speed * dt) % windowH
      
      --se o asteróide tocar a nave, o jogo reinicia
      if areCirclesIntersecting(ship.x, ship.y, ship.radius, asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius) then
        score = 0
        reset()
        break
      end
    end
  end-----------------------------end gamePaused 
  
  --caso o jogador limpe a tela
  if #asteroids == 0 then
    reset()
  end
end

function love.draw()
  love.graphics.setFont(font) --configura a fonte do jogo
   
  --[[redesenha os objetos para se repetirem]]--
  for y=-1, 1 do
    for x =-1, 1 do
      --faz com que objeto no canto da tela atravessem para o outro lado
      love.graphics.origin()
      love.graphics.translate(x * windowW, y * windowH)
      
      love.graphics.setColor(1, 1, 1)                        --muda a cor para branco
      love.graphics.draw(ship.image, ship.x, ship.y, ship.angle, 1 ,1, ship.radius, ship.radius) --desenha a nave
      
      --[[desenha as balas]]--
      for bulletIndex, bullet in pairs(bullets) do
        love.graphics.setColor(0, 1, 0)
        love.graphics.circle("fill", bullet.x, bullet.y, bulletRadius)
      end
        
      --[[desenha os asteróides]]--
      for asteroidIndex, asteroid in ipairs(asteroids) do
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle('line', asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius)
      end
    end
  end

  love.graphics.origin()
  
  -------------------------------------------------------------------------------------------------
  --[[desenha o menu caso não estaje pausado]]--
  if gamePaused then
    love.graphics.setColor(0, 0, 0, 0.9) --preto com 90% de transparência
    love.graphics.rectangle("fill", 0, 0, windowW, windowH)
    
    --desenha os botões
    local ww = love.graphics.getWidth() 
    local wh = love.graphics.getHeight()
    
    local button_width = windowW * (1/3)  --define a largura do botão para um terço da tela
    local margin = 16               --define o espaço entre um botão e outro
    
    local total_height = (button_height + margin) * #buttons
    local cursor_y = 0
    
    for i, button in ipairs(buttons) do --para cada botão criado em love.load faça:
      button.last = button.now
     
      --define as margens e a posição de cada botão
      local bx = (windowW * 0.5) - (button_width * 0.5)
      local by = (windowH * 0.5) - (button_height * 0.5) - (total_height * 0.5) + cursor_y
      
      local color = {0.4, 0.4, 0.5, 1.0}  --define a cor dos botões
      local mx, my = love.mouse.getPosition() --verifica a posição do mouse
      
      local hot = mx > bx and mx < bx + button_width and my > by and my < by + button_height --verifica se o mouse está em cima de um botão
      
      if hot then
        color = {0.8, 0.8, 0.9, 1.0}  --muda a cor do botão caso o mouse esteja sobre ele
      end
      
      --se clicar em cima de um botão, sua função correspondente será chamada
      button.now = love.mouse.isDown(1)
      if button.now and not button.last and hot then
        button.fn()
      end
      
      --desenha os botões com uma nova cor
      love.graphics.setColor(unpack(color))
      love.graphics.rectangle(
        "fill",
        bx,
        by,
        button_width,
        button_height
      )
      love.graphics.setColor(1, 1, 1, 1)
      
      --[[cria os textos dos botões]]--
      local textW = font:getWidth(button.text)
      local textH = font:getHeight(button.text)
      
      love.graphics.print(
        button.text,
        font,
        (ww * 0.5) - textW * 0.5, --largura do texto do botão
        by + textH * 0.25  --altura do texto do botão
      )
      cursor_y = cursor_y + (button_height+margin) --reserva um espaço entre os botões
    end
  end
  -------------------------------------------------------------------------------------------------
  
  love.graphics.setColor(1, 1, 1) --muda a cor para branco
  love.graphics.print("PLACAR: "..score, 10, 10)  --mostra o placar atual
  love.graphics.print("HI: "..maxScore, 250, 10)  --mostra o maior placar
end

--pausa o game
function love.keypressed(key)
  if key == "escape" then
    --love.filesystem.write("resources/csv/hi.txt", maxScore)
    --love.event.quit(0)
    gamePaused = not gamePaused
  end
end
