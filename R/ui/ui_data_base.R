ui_data_base <- tagList(
  actionButton(
    inputId = 'get_patientsDB',
    label = 'Обновить базу данных',
    width = 350,
    icon = icon("repeat")
  ),
  
  div(
    style = "flex-grow: 1; overflow: auto;",  # auto для скролла если контент большой
    DTOutput('patientsDB')
  )
)