function main(my_splash, args)
  assert(my_splash:go(args.url))
  local password_field = assert(my_splash:select("input#host_password"))
  password_field:focus()
  assert(password_field:send_text("secret"))
  assert(password_field:send_keys("<Enter>"))
  assert(my_splash:wait(0.2))
  local db_selector = assert(my_splash:select('select#database'))
  db_selector:mouse_click()
	db_selector:send_text("logs")
  db_selector:send_text("<Enter>")
  assert(my_splash:wait(0.2))
  local table_datadog = assert(my_splash:select('li > a[data-name="datadog"]'))
  table_datadog:mouse_click()
  local content = assert(my_splash:select('li#section-content > a'))
  content:mouse_click()
  assert(my_splash:wait(0.2))
  
  return {
    html_markup = my_splash:html()
  }
end
