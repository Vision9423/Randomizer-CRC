# о приложении
panel_about <- nav_panel(
  title = 'О приложении',
  value = 'about',
  
  div(class = "container my-5",
      includeMarkdown('www/about.md')
  )
  
)