get_db <- function(auth) {
  
  is_admin <- req(auth()$info$role) == 'admin'
  user_center <- auth()$info$center
  
  patients_db <- patients_tbl
  
  if (!is_admin) {
    patients_db <- patients_db %>%
      filter(center == user_center)
  }
  
  patients_db %>% 
    collect()
}