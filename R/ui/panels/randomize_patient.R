# рандомизация пациента
panel_randomize_patient <- nav_panel(
  title = 'Рандомизировать пациента',
  value = 'randomize_patient',
  
  div(class = "container my-5",
      newPatientInfoUI()
  )
  
)