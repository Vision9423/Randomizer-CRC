# база данных рандомизированных пациентов
panel_patients_db <- nav_panel(
  title = 'База данных пациентов',
  value = 'patients_db',
  
  navset_card_tab(
    id = "patients_db",
    nav_item(
      actionButton(
        inputId = 'get_patientsDB',
        label = 'Обновить базу данных',
        icon = icon("repeat"),
        class = "btn-info"
      )
    ),
    
    nav_panel(
      title = "База данных пациентов",
      patientsDBUI("patientsDB")
    )
  )
)