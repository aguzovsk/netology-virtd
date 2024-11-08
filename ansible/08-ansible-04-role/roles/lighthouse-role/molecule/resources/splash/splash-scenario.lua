function main(my_splash, args)
  assert(my_splash:go(args.url))
  local password_field = assert(my_splash:select("input#host_password"))
  password_field:focus()
  assert(password_field:send_text("secret"))
  assert(password_field:send_keys("<Enter>"))
  assert(my_splash:wait(0.2))

  local content = assert(my_splash:select('li#section-query > a'))
  content:mouse_click()
  assert(my_splash:wait(0.5))
  local text_area = assert(my_splash:select('div.ace_line'))
  text_area:focus()
  assert(text_area:send_text("SELECT COUNT(*) AS Quantity FROM logs.datadog"))
  local execute_button = assert(my_splash:select('button#execute-btn'))
  execute_button:focus()
  execute_button:mouse_click()
  assert(my_splash:wait(0.5))
  
  return {
    html_markup = my_splash:html()
  }
end
