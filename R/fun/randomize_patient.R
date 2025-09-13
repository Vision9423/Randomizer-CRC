# рандомизировать пациента ------------------------------------------------

randomize_patient <- function(data) {

  # отобрать столбцы, необходимые для рандомизации
  new_patient <- data %>% 
    mutate(
      fong_cat = if_else(fong < 3, 0, 1)
    ) %>% 
    select(
      mts_interval, center, fong_cat, mutation,
      mts_localization, act_after_oper
    )
  
  # Попробовать взять блокировку на 20 секунд
  lock <- dbGetQuery(pool, "SELECT GET_LOCK('patient_randomization', 20)")

  if (lock != 1) stop("Не получилось рандомизировать пациента, повторите попытку")
  
  # по окончанию работы функции снять лок
  on.exit(
    dbGetQuery(pool, "SELECT RELEASE_LOCK('patient_randomization')"),
    add = TRUE
  )
  
  # получить таблицу пациентов
  patientsDB <- patients_tbl %>% 
    select(
      mts_interval, fong, center, mutation, mts_localization,
      act_after_oper, treatment
    ) %>% 
    collect() %>% 
    mutate(
      fong_cat = if_else(fong < 3, 0, 1)
    ) %>% 
    select(-fong)
  
  # рандомизировать группу
  
  if (nrow(patientsDB) == 0) {
    
    treatment <- sample(
      x = 0:1,
      size = 1,
      replace = TRUE,
      prob = c(0.5, 0.5)
    )
    
  } else {
    
    # получить вектор групп ранее рандомизированных пациентов
    result <- pull(
      .data = patientsDB,
      var = 'treatment'
    )
    
    # оставить столбцы в БД, необходимые для рандомизации
    patients_df <- patientsDB %>% 
      select(-treatment)
    
    # добавить нового пациента в дата фрейм
    patients_df_updated <- bind_rows(
      patients_df, new_patient
    )
    
    # номер нового пациента в БД
    j <- nrow(patients_df_updated)
    
    # провести рандомизацию
    treatment <- Minirand(
      covmat = patients_df_updated,
      j = j,
      covwt = rep(x = 1/6, times = 6),
      ratio = c(1, 1),
      ntrt = 2,
      trtseq = c(0, 1),
      method = 'Range',
      result = result,
      p = 0.9
    )
    
  }
  
  # добавить данные нового пациента в дата фрейм
  new_patient_full <- data %>% 
    mutate(
      treatment = treatment
    )
  
  # занести пациента в БД
  dbWriteTable(
    conn = pool,
    name = db_table_patients,
    value = new_patient_full,
    overwrite = FALSE,
    append = TRUE
  )
  
  return(treatment)
}


# сформировать модальное окно результата рандомизации ---------------------

renderUI_randomizationResult <- function(data, treatment) {
  
  # цвет сообщения в зависимости от группы
  color <- ifelse(treatment == 0, "#006400", "#FF4500")
  
  # перевести группу из числового значения в фактор
  treatment <- factor(
    x = treatment,
    levels = c(0, 1),
    labels = c('Динамическое наблюдение', 'Адъювантная химиотерапия')
  )
  
  tagList(
    p(
      'Пациент', tags$b(data$name), 'рандомизирован в группу:',
      style = "text-align: center;"
    ),
    h3(
      treatment,
      style = sprintf("border: 3px solid %s;
                         padding: 10px;
                         border-radius: 10px;
                         text-align: center;
                         display: inline-block;", color)
    )
  )
}


# рандомизировать и получить результат ------------------------------------

randomizePatientServer <- function(data) {
  
  # рандомизировать пациента и занести его в БД
  treatment <- randomize_patient(data)
  
  showModal(modalDialog(
    title = 'Пациент успешно рандомизирован и добавлен в базу данных',
    renderUI_randomizationResult(data, treatment),
    
    footer = tagList(
      modalButton("Закрыть окно")
    ),
    
    easyClose = FALSE
  ))
}
