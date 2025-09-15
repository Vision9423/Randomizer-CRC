ui <- page_navbar(
  
  window_title = 'Рандомизация пациентов',
  id = 'main_bar',
  lang = 'ru',
  navbar_options = navbar_options(
    position = 'static-top'
  ),
  
  # тема интерфейса
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    success = "#3CB371",
    base_font = font_google("Roboto")
  ),
  
  # колесо загрузки и предупреждения
  header = ui_settings,
  
  # о приложении
  panel_about,
  
  # рандомизация пациента
  panel_randomize_patient,
  
  # база данных рандомизированных пациентов
  panel_patients_db,
  
  # статистика
  panel_stat,
  
  nav_spacer(),
  
  # авторизация
  panel_auth_hidden,
  
  # кнопки авторизации и выхода
  panel_login_buttons
  
)