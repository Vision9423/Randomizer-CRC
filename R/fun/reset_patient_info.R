reset_patient_info <- function() {
  updateTextInput(
    inputId = "name",
    value = ""
  )
  
  updateDateInput(
    inputId = "date_birth",
    value = Sys.Date()
  )
  
  radio_btns_to_reset <- c(
    "sex", "mts_localization", "mutation",
    "act_after_oper", "mts_interval", "node_status",
    "mts_num", "mts_size", "cea_preop"
  )
  
  radio_btns_to_reset %>% 
    walk(
      .f = \(btn_id) {
        updateRadioGroupButtons(
          inputId = btn_id,
          selected = character(0)
        )
      }
    )
}