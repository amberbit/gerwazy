class TestApp
  def call(env)
    case env["PATH_INFO"]
      when "/" then
        sleep 0.5
        [200, { 'Content-Type' => 'text/html' }, ["Hello World"]]
      when "/response1"
        sleep 1.5
        [200, { 'Content-Type' => 'text/html' }, ["GET_response1"]]
      else
        [404, { 'Content-Type' => 'text/html' }, ["404 Not found"]]
    end
  end
end
