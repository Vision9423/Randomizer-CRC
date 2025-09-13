server <- function(input, output, session) {
  
  hide_panels_on_start()
  
  # загрузить таблицу пользователей
  user_base <- dbReadTable(
    conn = pool,
    name = db_table_cred
  )
  
  # авторизация в приложение
  auth <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = "login",
    pwd_col = "password",
    sodium_hashed = TRUE,
    reload_on_logout = TRUE,
    log_out = reactive(logout_init())
  )
  
  # перейти на вкладку авторизации по нажатию кнопки
  observeEvent(input$login_btn, {
    nav_select(
      id = 'main_bar',
      selected = 'auth'
    )
  })
  
  observe({
    is_auth <- req(auth()$user_auth)
    is_admin <- auth()$info$role == 'admin'
    
    toggle(
      id = 'exit_btn',
      condition = is_auth
    )
    
    toggle(
      id = 'login_btn',
      condition = !is_auth
    )
    
    show_panels_on_auth(is_admin = is_admin)
  })
  
  # выход из приложения
  observeEvent(input$exit_btn, {
    ask_confirmation(
      inputId = "exit_confirm",
      title = "Выйти из приложения?",
      btn_labels = c('Отмена', "Выйти"),
      allowEscapeKey = TRUE,
      closeOnClickOutside = TRUE
    )
  })
  
  logout_init <- reactive({
    if (req(input$exit_confirm)) TRUE
  })
  
  # рандомизировать нового пациента
  newPatientInfoServer(auth)

  # обновить БД
  patientsDB_raw <- eventReactive(input$get_patientsDB, {
    get_db(auth)
  })

  # отрендерить таблицу
  patientsDBServer('patientsDB', patientsDB_raw, auth)

  # статистика
  statServer(auth)
}