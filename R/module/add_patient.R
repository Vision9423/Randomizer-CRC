newPatientInfoUI <- function() {
  
  ns <- NS("new_patient_info")
  
  tagList(
    
    card(
      card_header(
        h4("Клинический центр")
      ),
      
      card_body(
        radioGroupButtons(
          inputId = ns("center"),
          label = NULL,
          choices = list(
            "МНИОИ им. П.А. Герцена" = 0,
            "НМИЦ онкологии им. Н.Н. Блохина" = 1,
            'ММКЦ "Коммунарка"' = 2,
            "Онкологический центр № 1 ГКБ имени С.С. Юдина" = 3
          ),
          selected = character(0)
        )
      )
    ),
    
    card(
      textInput(
        inputId = ns("name"),
        label = "ФИО пациента",
        placeholder = "Введите ФИО пациента",
        width = "500px"
      ),
      
      radioGroupButtons(
        inputId = ns("sex"),
        label = "Пол",
        choices = list(
          "Мужской" = 0,
          "Женский" = 1
        ),
        selected = character(0)
      ),
        
      dateInput(
        inputId = ns("date_birth"),
        label = "Дата рождения пациента",
        language = "ru",
        weekstart = 1,
        format = "dd.mm.yyyy",
        width = "500px"
      ) 
    ),
    
    
    card(
      
      radioGroupButtons(
        inputId = ns("mts_localization"),
        label = "Локализация метастазов",
        choices = list(
          "Печень" = 0,
          "Лёгкие" = 1
        ),
        
        selected = character(0)
      ),
      
      radioGroupButtons(
        inputId = ns("mutation"),
        label = "Мутационный статус",
        choices = list(
          "wtRAS" = 0,
          "mRAS" = 1
        ),
        
        selected = character(0)
      ),
      
      radioGroupButtons(
        inputId = ns("act_after_oper"),
        label = "АХТ после хирургического удаления первичной опухоли",
        choices = list(
          "Не проводилась" = 0,
          "Проводилась" = 1
        ),
        
        selected = character(0)
      )
    ),

        
      card(
        
        card_header(
          h4("Шкала Fong")
        ),
        
        card_body(
          radioGroupButtons(
            inputId = ns("mts_interval"),
            label = "Интервал между датой удаления первичной опухоли и датой выявления метастазирования",
            choices = list(
              "6-12 месяцев" = 0,
              "Более 12 месяцев" = 1
            ),
            
            selected = character(0)
          ),
          
          radioGroupButtons(
            inputId = ns("node_status"),
            label = "N-статус первичной опухоли",
            choices = list(
              "N0" = 0,
              "N+" = 1
            ),
            
            selected = character(0)
          ),
          
          radioGroupButtons(
            inputId = ns("mts_num"),
            label = "Количество метастазов",
            choices = list(
              "Один" = 0,
              "Более одного" = 1
            ),
            
            selected = character(0)
          ),
          
          radioGroupButtons(
            inputId = ns("mts_size"),
            label = "Размер наибольшего метастаза",
            choices = list(
              "Не более 5,0 см" = 0,
              "Более 5,0 см" = 1
            ),
            
            selected = character(0)
          ),
          
          radioGroupButtons(
            inputId = ns("cea_preop"),
            label = "Раково-эмбриональный антиген (РЭА) перед метастазэктомией",
            choices = list(
              "Не более 200 нг/мл" = 0,
              "Более 200 нг/мл" = 1
            ),
            
            selected = character(0)
          )
        ),
        
        # количество баллов по шкале Fong
        value_box(
          title = "Баллов по шкале Fong",
          value = textOutput(ns("fong_score")),
          showcase = bs_icon("clipboard-data")
        )
      ),
      
    # кнопка для рандомизации
    actionButton(
      inputId = ns("add_patient"),
      label = "Рандомизировать пациента",
      icon = icon("hospital-user"),
      class = "btn-info mb-5"
    )
    
  )
}


newPatientInfoServer <- function(auth) {
  moduleServer("new_patient_info", function(input, output, session) {
    
    {
      ns <- session$ns
      
      # выключить выбор центра, если пользователь не админ ----
      observe({
        
        req(auth()$user_auth)
        
        is_admin <- auth()$info$role == "admin"
        
        updateRadioGroupButtons(
          inputId = "center",
          selected = auth()$info$center,
          disabled = !is_admin
        )
        
      })
      
      user_center <- reactive({
        if (auth()$info$role == "admin") {
          input$center
        } else {
          auth()$info$center
        }
      })
      
      patient_info_list <- reactive({
        req(auth()$user_auth)
        
        list(
          name = input$name,
          sex = input$sex,
          date_birth = input$date_birth,
          center = user_center(),
          mts_localization = input$mts_localization,
          mts_interval = input$mts_interval,
          node_status = input$node_status,
          mts_num = input$mts_num,
          mts_size = input$mts_size,
          cea_preop = input$cea_preop,
          mutation = input$mutation,
          act_after_oper = input$act_after_oper
        )
      }) %>% 
        bindEvent(input$add_patient)
      
      is_full_info <- reactive({
        patient_info_list() %>% 
          map_lgl(\(column) isTruthy(column)) %>% 
          all()
      })
      
      
      patient_info_df <- reactive({
        req(is_full_info())

        patient_info_list() %>%
          as_tibble_row() %>% 
          modify_at(
            .at = c(
              "mts_interval", "node_status", "mts_num",
              "mts_size", "cea_preop",
              "mutation", "mts_localization",
              "act_after_oper", "center"
            ),
            .f = as.integer
          ) %>%
          rowwise() %>%
          mutate(
            fong = sum(
              1 - mts_interval, node_status, mts_num,
              mts_size, cea_preop
            )
          ) %>%
          ungroup()
      })


      observe({

        feedbackWarning(
          inputId = "name",
          show = !isTruthy(input$name),
          text = "Пожалуйста, заполните ФИО пациента"
        )

        feedbackWarning(
          inputId = "date_birth",
          show = !isTruthy(input$date_birth),
          text = "Пожалуйста, заполните дату рождения пациента"
        )

        if (is_full_info()) {
          newPatientConfirm(patient_info_df(), ns)
        } else {
          notify_warning(
            text = "Не все поля заполнены",
            position = "center-top"
          )
        }

      }) %>%
        bindEvent(input$add_patient)
      
      # количество баллов по шкале Fong
      fong_score <- reactive({
        list(
          mts_interval = input$mts_interval,
          node_status = input$node_status,
          mts_num = input$mts_num,
          mts_size = input$mts_size,
          cea_preop = input$cea_preop
        ) %>% 
          modify_at(
            .at = "mts_interval",
            .f = \(x) if (is.null(x)) 1 else x
          ) %>% 
          modify_if(
            .p = is.null,
            .f = \(x) 0
          ) %>% 
          modify(
            as.integer
          ) %>% 
          modify_at(
            .at = "mts_interval",
            .f = \(x) 1 - x
          ) %>% 
          unlist() %>% 
          sum()
      })
      
      output$fong_score <- renderText({
        fong_score()
      })
      

      # рандомизировать пациента
      observe({
        removeModal()
        randomizePatientServer(patient_info_df())
        reset_patient_info()
      }) %>%
        bindEvent(input$confirm_randomization)
      
      
    }
    
  })
}