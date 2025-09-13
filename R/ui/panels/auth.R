# авторизация
panel_auth_hidden <- nav_panel_hidden(
  value = 'auth',
  
  shinyauthr::loginUI(
    id = "login",
    title = "Авторизация",
    user_title = "Логин",
    pass_title = "Пароль",
    login_title = "Войти",
    error_message = "Неверный логин или пароль!"
  )
  
)


panel_login_buttons <- nav_item(
  div(
    actionButton(
      "login_btn",
      "Войти",
      icon = icon("right-to-bracket"),
      class = "btn-success"
      ),
    
    hidden(
      actionButton(
        "exit_btn",
        "Выйти",
        icon = icon("right-to-bracket"),
        class = "btn-danger"
      )
    )
  )
)