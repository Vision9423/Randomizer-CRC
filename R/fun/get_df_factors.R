get_df_factors <- function(data) {
  data <- data %>% 
    mutate(
      
      sex = factor(
        x = sex,
        levels = c(0, 1),
        labels = c('Мужской', 'Женский')
      ),
      
      center = factor(
        x = center,
        levels = c(0, 1, 2, 3),
        labels = c(
          'МНИОИ им. П.А. Герцена',
          'НМИЦ онкологии им. Н.Н. Блохина',
          'ММКЦ "Коммунарка"',
          'Онкологический центр № 1 ГКБ имени С.С. Юдина'
        )
      ),
      
      mts_localization = factor(
        x = mts_localization,
        levels = c(0, 1),
        labels = c('Печень', 'Лёгкие')
      ),
      
      mts_interval = factor(
        x = mts_interval,
        levels = c(0, 1),
        labels = c('6-12 месяцев', 'Более 12 месяцев')
      ),
      
      node_status = factor(
        x = node_status,
        levels = c(0, 1),
        labels = c("N0", "N+")
      ),
      
      mts_num = factor(
        x = mts_num,
        levels = c(0, 1),
        labels = c("Один", "Более одного")
      ),
      
      mts_size = factor(
        x = mts_size,
        levels = c(0, 1),
        labels = c("Не более 5,0 см", "Более 5,0 см")
      ),
      
      cea_preop = factor(
        x = cea_preop,
        levels = c(0, 1),
        labels = c("Не более 200 нг/мл", "Более 200 нг/мл")
      ),
      
      mutation = factor(
        x = mutation,
        levels = c(0, 1),
        labels = c("wtRAS", "mRAS")
      ),
      
      act_after_oper = factor(
        x = act_after_oper,
        levels = c(0, 1),
        labels = c("Не проводилась", "Проводилась")
      ),
      
      treatment = factor(
        x = treatment,
        levels = c(0, 1),
        labels = c('Динамическое наблюдение', 'Адъювантная химиотерапия')
      )
    )
  
  return(data)
}