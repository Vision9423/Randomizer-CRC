# статистика
panel_stat <- nav_panel(
  title = 'Статистика',
  value = 'stat',
  
  div(class = "container my-2",
      statUI()
  )
  
)