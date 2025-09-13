get_ru_colnames <- function(data) {
  original_colnames <- names(data)
  
  new_colnames <- case_match(
    original_colnames,
    "id" ~ "ID в БД",
    "patient_num" ~ "Номер в порядке добавления",
    "patient_num_center" ~ "Номер в порядке добавления в клиническом центре",
    "name" ~ "ФИО пациента",
    "sex" ~ "Пол",
    "date_birth" ~ "Дата рождения",
    "center" ~ "Клинический центр",
    "treatment" ~ "Группа",
    "mts_localization" ~ "Локализация метастаза",
    "mts_interval" ~ "Срок метастазирования",
    "fong" ~ "Баллов по шкале Fong",
    "node_status" ~ "N-статус первичной опухоли",
    "mts_num" ~ "Количество метастазов",
    "mts_size" ~ "Размер наибольшего метастаза",
    "cea_preop" ~ "РЭА перед метастазэктомией",
    "mutation" ~ "Мутационный статус",
    "act_after_oper" ~ "АХТ после первичного лечения",
    "datetime_randomization" ~ "Дата и время рандомизации",
    .default = original_colnames
  )
  
  return(new_colnames)
}