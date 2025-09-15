statUI <- function() {
  
  ns <- NS('stat')
  
  navset_card_tab(
    id = "navset_stat",
    
    nav_item(
      actionButton(
        ns('get_stat'),
        'Обновить статистику',
        icon = icon("repeat"),
        class = "btn-info"
      )
    ),
    
    
    nav_panel(
      title = "Общая информация",
      value = "common_stat",
      withSpinner(
        uiOutput(ns('patients_num'))
      )
    ),
    
    
    nav_panel(
      title = "Статистика по группе",
      value = "stat_by_treatment",
      withSpinner(
        uiOutput(ns('stat_by_treatment'))
      )
    ),
    
    
    nav_panel(
      title = "Статистика по центру",
      value = "stat_by_center",
      withSpinner(
        uiOutput(ns('stat_by_center'))
      )
    )
  )
  
}




statServer <- function(auth) {
  moduleServer('stat', function(input, output, session) {
    
    patients_db_raw <- reactive({
      req(auth()$info$role == 'admin')
      
      get_db(auth)
    }) %>% 
      bindEvent(input$get_stat)
    
    
    # количество пациентов в БД
    patients_num <- reactive({
      patients_db_raw() %>% 
        nrow()
    })
    
    
    # tidy дата фрейм пациентов
    patients_df <- reactive({
      req(patients_num() > 0)
      
      patients_db_raw() %>% 
        get_df_factors() %>% 
        
        # рассчитать возраст на момент рандомизации
        mutate(
          age = interval(
            start = date_birth,
            end = datetime_randomization
          ) / dyears(),
          
          fong_cat = if_else(fong < 3, 0, 1) %>% 
            factor(
              levels = c(0, 1),
              labels = c("0-2", "3-5")
            )
        ) %>% 
        
        # присвоить лейблы
        set_variable_labels(
          sex = "Пол",
          mts_interval = "Срок метастазирования",
          fong = "Баллов по шкале Fong",
          center = "Клинический центр",
          mutation = "Мутационный статус",
          mts_localization = "Локализация метастаза",
          act_after_oper = "АХТ после первичного лечения",
          treatment = "Группа",
          age = "Возраст",
          fong_cat = "Баллов по шкале Fong (категория)",
          node_status = "N-статус первичной опухоли",
          mts_num = "Количество метастазов",
          mts_size = "Размер наибольшего метастаза",
          cea_preop = "РЭА перед метастазэктомией",
          .strict = FALSE
        )
    })
    
    # piechart по группе
    piechart_by_treatment <- renderPlotly({
      
      df_treatment <- patients_df() %>% 
        count(treatment)
      
      plot_ly(
        type = "pie",
        labels = df_treatment$treatment,
        values = df_treatment$n,
        textinfo = "value+percent",
        insidetextorientation = "radial",
        showlegend = FALSE
      ) %>% 
        config(
          locale = "ru"
        )
      
    })
    
    # piechart по центру
    piechart_by_center <- renderPlotly({
      
      df_center <- patients_df() %>% 
        count(center)
      
      plot_ly(
        type = "pie",
        labels = df_center$center,
        values = df_center$n,
        textinfo = "value+percent",
        insidetextorientation = "radial",
        showlegend = FALSE
      ) %>% 
        config(
          locale = "ru"
        )
      
    })
    
    
    # статистика по группе лечения
    stat_by_treatment <- reactive({
      req(patients_num() > 0)
      
      patients_df() %>% 
        tbl_summary(
          by = treatment,
          include = c(
            age, sex, center, mts_localization,
            fong, fong_cat, mts_interval,
            node_status, mts_num, mts_size, cea_preop,
            mutation, act_after_oper
            
          ),
          type = list(
            age ~ "continuous",
            fong ~ "continuous"
          ),
          digits = list(
            age = 1
          )
        ) %>%
        add_overall(
          last = TRUE,
          col_label = "**Всего**  \nN = {style_number(N)}"
        ) %>% 
        modify_header(label = "**Показатель**") %>% 
        add_p() %>% 
        bold_labels() %>% 
        bold_p() %>% 
        as_gt()
    })
    
    
    # статистика по центрам
    stat_by_center <- reactive({
      req(patients_num() > 0)
      
      patients_df() %>% 
        tbl_summary(
          by = center,
          include = c(
            age, sex, treatment, mts_localization,
            fong, fong_cat, mts_interval,
            node_status, mts_num, mts_size, cea_preop,
            mutation, act_after_oper
            
          ),
          type = list(
            age ~ "continuous",
            fong ~ "continuous"
          ),
          digits = list(
            age = 1
          )
        ) %>%
        modify_header(label = "**Показатель**") %>% 
        add_p() %>% 
        bold_labels() %>% 
        bold_p() %>% 
        as_gt()
    })
    
    
    output$patients_num <- renderUI({
      tagList(
        
        value_box(
          title = "Пациентов рандомизировано",
          value = req(patients_num()),
          showcase = bs_icon('people')
        ),
        
        layout_column_wrap(
          width = 1/2,
          
          card(
            card_header(
              h4("Группа")
            ),
            card_body(
              piechart_by_treatment
            )
          ),
          
          card(
            card_header(
              h4("Клинический центр")
            ),
            card_body(
              piechart_by_center  
            )
          )
          
        )
        
      )
    })
    
    
    output$stat_by_treatment <- renderUI({
      req(stat_by_treatment())
        card(
          
          card_header(
            class = "bg-dark",
            h4("Статистика по группе лечения")
          ),
          
          card_body(
            render_gt(
              stat_by_treatment()
            )
          )
          
        )
    })
    
    
    output$stat_by_center <- renderUI({
      req(stat_by_center())
      
      card(
        
        card_header(
          class = "bg-dark",
          h4("Статистика по клиническому центру")
        ),
        card_body(
          render_gt(
            stat_by_center()
          )
        )
        
      )
    })
    
  })
}