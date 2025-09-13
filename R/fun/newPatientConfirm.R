# функция для рендера UI всплывающего окна --------------------------------

renderUI_newPatientConfirm <- function(data) {
  
  center <- factor(
    x = data$center,
    levels = c(0, 1, 2, 3),
    labels = c(
      "МНИОИ им. П.А. Герцена",
      "НМИЦ онкологии им. Н.Н. Блохина",
      'ММКЦ "Коммунарка"',
      "Онкологический центр № 1 ГКБ имени С.С. Юдина"
    )
  )
  
  name <- data$name
  
  sex <- factor(
    x = data$sex,
    levels = c(0, 1),
    labels = c("Мужской", "Женский")
  )
  
  date_birth <- format.Date(
    x = data$date_birth,
    format = "%d.%m.%Y"
  )
  
  age <- (
    interval(
      start = data$date_birth,
      end = Sys.Date()
    ) / dyears()
  ) %>% 
    style_number(digits = 1)
  
  mts_localization <- factor(
    x = data$mts_localization,
    levels = c(0, 1),
    labels = c("Печень", "Лёгкие")
  )
  
  mutation <- factor(
    x = data$mutation,
    levels = c(0, 1),
    labels = c("wtRAS", "mRAS")
  )
  
  act_after_oper <- factor(
    x = data$act_after_oper,
    levels = c(0, 1),
    labels = c("Не проводилась", "Проводилась")
  )
  
  mts_interval <- factor(
    x = data$mts_interval,
    levels = c(0, 1),
    labels = c("6-12 месяцев", "Более 12 месяцев")
  )
  
  node_status <- factor(
    x = data$node_status,
    levels = c(0, 1),
    labels = c("N0", "N+")
  )
  
  mts_num <- factor(
    x = data$mts_num,
    levels = c(0, 1),
    labels = c("Один", "Более одного")
  )
  
  mts_size <- factor(
    x = data$mts_size,
    levels = c(0, 1),
    labels = c("Не более 5,0 см", "Более 5,0 см")
  )
  
  cea_preop <- factor(
    x = data$cea_preop,
    levels = c(0, 1),
    labels = c("Не более 200 нг/мл", "Более 200 нг/мл")
  )
  
  fong <- data$fong
  
  tagList(
    card(
      p(strong("Клинический центр: "), center),
    ),
    
    card(
      p(strong("ФИО: "), name),
      p(strong("Пол: "), sex),
      p(strong("Дата рождения: "), date_birth),
      p(strong("Возраст: "), age, " лет")
    ),
    
    card (
    p(strong("Локализация метастаза: "), mts_localization),
    p(strong("Мутационный статус: "), mutation),
    p(strong("АХТ после первичного лечения: "), act_after_oper)
    ),
    
    card (
      card_header(
        h4("Шкала Fong")
      ),
      
      card_body(
        p(strong("Срок метастазирования: "), mts_interval),
        p(strong("N-статус первичной опухоли: "), node_status),
        p(strong("Количество метастазов: "), mts_num),
        p(strong("Размер наибольшего метастаза: "), mts_size),
        p(strong("РЭА перед метастазэктомией: "), cea_preop),
        
        value_box(
          title = "Баллов по шкале Fong",
          value = fong,
          showcase = bs_icon("clipboard-data")
        )
        
      )
      
    )
    
    
  )
}



# всплывающее окно подтверждения рандомизации -----------------------------

newPatientConfirm <- function(data, ns) {
  showModal(modalDialog(
    title = 'Подтвердите введенные данные',
    size = "l",
    renderUI_newPatientConfirm(data),

    footer = tagList(
      actionButton(
        inputId = ns('confirm_randomization'),
        "Рандомизировать",
        class = "btn-success"
      ),
      modalButton("Отменить")
    ),

    easyClose = FALSE
  ))
  
}