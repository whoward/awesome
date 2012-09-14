# Check out https://github.com/joshbuddy/http_router for more information on HttpRouter
HttpRouter.new do
  add('/').to(HomeAction)
  get('/games').to(LobbyAction)
  get('/games/:slug').to(GameAction)
end