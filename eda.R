load("C://Users//waliang//Documents//UCSB//third year//pstat 131//modify_data.rda")


# MISSING DATA
merge_con <- merge_con %>%
  replace_with_na_all(~.x =="\\N") %>%
  filter(season!=2023)

merge_driv <- merge_driv %>%
  replace_with_na_all(~.x=="\\N")



# arrange each constructor's result in order throughout a season

# since I plan on using con_sum_pnts as a response variable and con_sum_pnts is an accumulation of con_pnts
# I want to fill out all NA con_sum_pnts using con_pnts
# and vice versa

merge_con1 <- merge_con %>%
  arrange(constructorId, season, raceId, round, con_sum_pnts) %>%
  mutate(con_sum_pnts = case_when((is.na(con_sum_pnts) & season==lag(season) & is.na(con_pnts)!=TRUE) ~ lag(con_sum_pnts)+con_pnts,
                                  (is.na(con_sum_pnts) & season!=lag(season) & is.na(con_pnts)!=TRUE) ~ con_pnts,
                                  is.na(con_sum_pnts)!=TRUE ~ con_sum_pnts))



merge_con2 <- merge_con1 %>%
  arrange(constructorId, season, raceId, round, con_sum_pnts) %>%
  mutate(con_pnts = case_when((is.na(con_pnts) & season==lag(season) & is.na(con_sum_pnts)!=TRUE) ~ con_sum_pnts-lag(con_sum_pnts),
                              (is.na(con_pnts) & season!=lag(season) & is.na(con_sum_pnts)!=TRUE) ~ con_sum_pnts,
                              is.na(con_pnts)!=TRUE ~ con_pnts))


merge_con3 <- merge_con2 %>%
   arrange(constructorId, season, raceId, round, con_sum_pnts) %>%
   mutate(con_sum_pnts = case_when((is.na(con_sum_pnts) & season==lag(season) & is.na(con_pnts)!=TRUE) ~ lag(con_sum_pnts)+con_pnts,
                                   (is.na(con_sum_pnts) & season!=lag(season) & is.na(con_pnts)!=TRUE) ~ con_pnts,
                                   is.na(con_sum_pnts)!=TRUE ~ con_sum_pnts))

# MERGE_CON3
# turn continuous variables (that aren't integers already) into integers
merge_con3$con_pnts <- as.integer(merge_con3$con_pnts)

# turn categorical variables (that aren't factors already) into factors
merge_con3$con_nation <- factor(merge_con3$con_nation)
merge_con3$raceId <- factor(merge_con3$raceId)
merge_con3$constructorId <- factor(merge_con3$constructorId)
merge_con3$circuitId <- factor(merge_con3$circuitId)
merge_con3$circ_country <- factor(merge_con3$circ_country)


# DRIV_MERGE  
# turn continuous variables (that aren't integers already) into integers
merge_driv$driv_pnts <- as.integer(merge_driv$driv_pnts)
merge_driv$fastestLapTime_rank <- as.integer(merge_driv$fastestLapTime_rank)
merge_driv$fastestLapSpeed <- as.integer(merge_driv$fastestLapSpeed)
merge_driv$avg_lap_time <- as.integer(merge_driv$avg_lap_time)
merge_driv$avg_lap_pos <- as.integer(merge_driv$avg_lap_pos)
merge_driv$dob <- as.integer(merge_driv$dob)

# turn categorical variables (that aren't factors already) into factors
merge_driv$raceId <- factor(merge_driv$raceId)
merge_driv$driverId <- factor(merge_driv$driverId)
merge_driv$constructorId <- factor(merge_driv$constructorId)
merge_driv$circuitId <- factor(merge_driv$circuitId)
merge_driv$circ_country <- factor(merge_driv$circ_country)
merge_driv$nationality <- factor(merge_driv$nationality)


# can't impute constructorId, omit those missing values
merge_driv1 <- merge_driv %>%
  filter(!is.na(constructorId)) %>%
  filter(!is.na(status))    # removes the <0.1% missing in some of the columns

# EXTRA MISING DATA WORK
merge_driv2 <- merge_driv1 %>%
  group_by(driverId, round) %>%
  # replace missing driv_standing with the median of the standings the driver gets in that round across seasons
  summarise(driv_standing_na = as.integer(median(driv_standing,na.rm=TRUE)))%>%
  replace_with_na(replace=list(merge_driv1$driv_standing_na=="Inf")) %>%
  replace_with_na(replace=list(merge_driv1$driv_standing_na=="-Inf"))

merge_driv3 <- full_join(merge_driv1, merge_driv2, by=c("driverId","round"))

merge_driv3 <- merge_driv3 %>%
  mutate(driv_standing = case_when(is.na(driv_standing) ~ driv_standing_na,
                                   !is.na(driv_standing) ~ driv_standing))

merge_driv4<- merge_driv3 %>%
  filter(!is.na(driv_standing))



# distribution of response variables
plot_con<-ggplot(merge_con3, aes(con_pos))+
  geom_bar(fill="black", width=0.5)+xlim(1,22)+ylim(0,1100)+
  labs(x="Constructor's position in standings",
       title="Distribution of Constructor's Position in Standings")+
  theme(plot.title = element_text(size=8, face="bold"))

plot_driv <- ggplot(merge_driv3, aes(driv_pnts))+
  geom_bar(fill="black",width=0.5)+ xlim(0,50)+ylim(0,1200)+
  labs(x="Driver's points earned at each race",
       title="Distribution of Driver's Points Earned at Each Race")+
  theme(plot.title = element_text(size=7, face="bold"))



save(merge_con, merge_con1, merge_con2,merge_con3,plot_con,
     plot_driv, merge_driv, merge_driv1, merge_driv2, 
     merge_driv3, merge_driv4,
     file="eda.rda")