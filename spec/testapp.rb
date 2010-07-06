class TestApp
  def call(env)
    case env["PATH_INFO"]
      when "/" then
        sleep 0.5
        [200, { 'Content-Type' => 'text/html' }, ["Hello World"]]
      when "/response1"
        sleep 1.5
        [200, { 'Content-Type' => 'text/html' }, ["GET_response1"]]
      when "/response2"
        [200, { 'Content-Type' => 'text/html' }, ["GET_response2"]]
      when "/embed_one"
        [200, { 'Content-Type' => 'text/html' }, ["<get>/embed_two</get>"]]
      when "/embed_two"
        [200, { 'Content-Type' => 'text/html' }, ["[<get>/response1</get>] [<get>/response2</get>]"]]
      when "/ajax_or_not"
        if env["HTTP_X_REQUESTED_WITH"]=="XMLHttpRequest"
          [200, { 'Content-Type' => 'text/html' }, ["Ajax!"]]
        else
          [200, { 'Content-Type' => 'text/html' }, ["Non-Ajax!"]]
        end
      when "/get_ajax_and_not_ajax"
        [200, { 'Content-Type' => 'text/html' }, ["[<xhrget>/ajax_or_not</xhrget>] [<get>/ajax_or_not</get>]"]]
      else
        [404, { 'Content-Type' => 'text/html' }, ["404 Not found"]]
    end
  end
end
