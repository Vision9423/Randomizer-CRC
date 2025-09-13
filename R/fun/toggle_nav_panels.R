hide_panels_on_start <- function() {
  
  nav_hide(
    id = 'main_bar',
    target = 'randomize_patient'
  )
  
  nav_hide(
    id = 'main_bar',
    target = 'patients_db'
  )
  
  nav_hide(
    id = 'main_bar',
    target = 'stat'
  )
  
}


show_panels_on_auth <- function(is_admin) {
  
  nav_show(
    id = 'main_bar',
    target = 'randomize_patient',
    select = TRUE
  )
  
  nav_show(
    id = 'main_bar',
    target = 'patients_db'
  )
  
  if (is_admin) {
    nav_show(
      id = 'main_bar',
      target = 'stat'
    )
  }
}