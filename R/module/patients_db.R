patientsDBUI <- function(id) {
  ns <- NS(id)
  
  uiOutput(
    outputId = ns("patients_db")
  )
  
}


patientsDBServer <- function(id, data, auth) {
  
  moduleServer(
    id = id,
    module = function(input, output, session) {
      
      patientsDB_shiny <- reactive({
        
        shiny_data <- req(data()) %>% 
          # преобразовать числовые данные в факторы
          get_df_factors() %>% 
          
          # номер в порядке добавления
          mutate(patient_num = row_number()) %>% 
          
          # номер в порядке добавления в своем клиническом центре
          group_by(center) %>% 
          mutate(patient_num_center = row_number()) %>% 
          ungroup() %>% 
          
          # сортировать по дате рандомизации
          arrange(
            desc(datetime_randomization),
            desc(id)
          ) %>% 
          
          # упорядочить столбцы
          relocate(
            patient_num, patient_num_center,
            .after = id
          )
        
        # если нет прав администратора, то скрыть столбцы с ID
        # и общей нумерацией
        if (req(auth()$info$role) != "admin") {
          shiny_data <- shiny_data %>% 
            select(-c(id, patient_num))
        }
        
        shiny_data
      })
      
      patientsDB_colnames <- reactive({
        get_ru_colnames(patientsDB_shiny())
      })
      
      patientsDT <- renderDT(
        datatable(
          patientsDB_shiny(),
          colnames = patientsDB_colnames(),
          # fillContainer = TRUE,
          filter = "top", # включить возможность фильтрации
          options = list(
            
            # русский язык
            language = list(
              url = "https://cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Russian.json"
            ),
            
            # количество строк по умолчанию
            pageLength = 10,
            
            # настроить какие столбцы можно фильтровать
            columnDefs = list(
              list(
                targets = c(
                  "name", "sex", "fong", "center",
                  "mts_interval", "node_status", "mts_num", "mts_size",
                  "cea_preop", "mutation", "mts_localization",
                  "act_after_oper", "treatment"
                ),
                searchable = TRUE
              ),
              list(targets = "_all", searchable = FALSE)
            )
          )
        ) %>% 
          
          # русский формат даты для даты рождения
          formatDate(
            columns = "date_birth",
            method = "toLocaleDateString",
            params = list("ru-RU")
          ) %>% 
          
          # русский формат даты и времени для даты и времени рандомизации
          formatDate(
            columns = "datetime_randomization",
            method = "toLocaleString",
            params = list(
              "ru-RU", 
              list(timeZone = "Europe/Moscow", hour12 = FALSE)
            )
          )
      )
      
      
      output$patients_db <- renderUI({
        div(
          patientsDT,
          style = "height:auto; overflow-y: scroll;",
        )
      })
      
    }
  )
}