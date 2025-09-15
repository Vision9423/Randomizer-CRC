ui_settings <- tagList(
  
  use_busy_spinner(
    spin = "fingerprint",
    position = "full-page",
    spin_id = "busy_full"
  ),
  
  # предупреждения о незаполненных полях
  useShinyFeedback(),
  
  # использовать shinyjs
  useShinyjs()
)