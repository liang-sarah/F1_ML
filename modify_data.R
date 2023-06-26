load("C://Users//waliang//Documents//UCSB//third year//pstat 131//read_data.rda")

# remove url column
constructors <- constructors %>% select(-url)
drivers <- drivers %>% select(-url)
circuit <- circuit %>% select(-url)
races <- races %>% select(-url)
seasons <- seasons %>% select(-url)


# McLaren is constructorId==1
constructor_standings %>%
  filter((raceId %in% (constructor_results %>%
                         # 2007 controversy year is denoted as "E" for excluded in positionText (the only rows w/ "E")
                         filter(status == "D"))[,2]) & constructorId==1) %>%
  select(-position)

# REMOVE 2007 McLaren observations from both data sets and RENAME variables for easy distinction
con_stand <- constructor_standings %>%
  filter(positionText!="E") %>%
  # con_sum_pnts = accumulated constructor points, helps determine the constructor's actual standing in the championship
  rename(con_sum_pnts = points, con_pos=position, con_posText=positionText, con_wins=wins)

con_res <- constructor_results %>%
  filter(status!="D") %>%
  # con_pnts = points earned at a race, helps determine a constructor's performance at certain races
  rename(con_pnts = points)%>%
  select(-status)   # status no longer denotes anything once we removed the 2007 McLaren data


merge_con <- full_join(con_res, con_stand, by=c("raceId", "constructorId"))

merge_con <- merge_con %>%
  select(-c("constructorResultsId","constructorStandingsId" ))

merge_con <- full_join(merge_con, constructors, by="constructorId")

# rename to make specific to constructors, not to get confused with the drivers specs
merge_con <- merge_con %>%
  rename(con_name=name, con_nation=nationality)





quali_na <- dim(qualifying %>%
      select(q1,q2,q3) %>%
      filter(q1=="\\N" & q2=="\\N" & q3 == "\\N"))[1]

# other than single digit minute timestamps and missing times, we have a double digit q1 timestamp and more blank missing values
rest_of_q1 <- qualifying %>%
  filter(str_length(q1) != 8 & q1!="\\N")

rest_of_q2 <- qualifying %>%      # we just have missing q2 values
  filter(str_length(q2) != 8 & q2!="\\N") %>%
  kable() %>% 
  kable_styling(full_width = F) %>% 
  scroll_box(width = "100%", height = "200px")

rest_of_q3 <- qualifying %>%      # jsut missing q3 values
  filter(str_length(q3) != 8 & q3!="\\N") %>%
  kable() %>% 
  kable_styling(full_width = F) %>% 
  scroll_box(width = "100%", height = "200px")



# converting timestamps into numeric seconds function
lap_time_convert <- function(x){
  if (x == ""){
    return(as.numeric(x))
  }
  
  else if (x=="\\N"){
    return(as.numeric(x))
  }
  
  # single digit (ex. 0, 1, 2) minute time
  else if ((str_which(x,"[[:digit:]]:")==1)==TRUE){
    # turn the minute mark into seconds
    return(as.numeric(gsub("^[[:digit:]]:", "", x))+(as.numeric(gsub(":[[:digit:]][[:digit:]]\\.[[:digit:]][[:digit:]][[:digit:]]$", "", x))*60))
  }
  
  # double digit (ex. 16) minute time
  else if ((str_which(x,"[[:digit:]][[:digit:]]:")==1)==TRUE){
    # turn minute mark into seconds
    return(as.numeric(gsub("^[[:digit:]][[:digit:]]:", "", x))+(as.numeric(gsub(":[[:digit:]][[:digit:]]\\.[[:digit:]][[:digit:]][[:digit:]]$", "", x))*60))
  }
}


# rename position to start_pos, avoid conflict with other variables in other data sets
quali <- qualifying %>%
  rename(driv_start_pos = position) %>%
  # remove driver number, we use driverId instead
  select(-number) %>%
  # convert q1, q2, q3 into numeric
  mutate(q1 = lap_time_convert(q1)) %>%
  mutate(q2 = lap_time_convert(q2))%>%
  mutate(q3= lap_time_convert(q3))

# new variable q_time = fastest time out of q1, q2, and q3
quali <- quali %>%
  group_by(raceId, driverId, constructorId, driv_start_pos) %>%
  summarise(q_time = min(c(q1,q2,q3),na.rm=TRUE)) %>%
  # make q_time NA if q1,q2,q3 were all NA
  replace_with_na(replace=list(quali$q_time=="Inf"))



sprint_res <- sprint_results %>%
  rename(driv_start_pos=positionOrder) %>%
  select(raceId, driverId, constructorId, driv_start_pos)

merge_quali <- full_join(quali, sprint_res, by=c("raceId", "driverId", "constructorId"))

# replace quali resulting start positions with sprint race resulting start positions
merge_quali <- merge_quali %>%
  mutate(driv_start_pos.y=replace(driv_start_pos.y, is.na(driv_start_pos.y), driv_start_pos.x[is.na(driv_start_pos.y)])) %>%
  select(-driv_start_pos.x) %>%
  rename(driv_start_pos=driv_start_pos.y)


res <- results %>%
  select(-c(number,position)) %>%
  # convert lap time
  mutate(fastestLapTime = lap_time_convert(fastestLapTime)) %>%
  # rename variables to be driver specific
  rename(driv_positionText=positionText, driv_positionOrder=positionOrder, driv_pnts = points, driv_statusId=statusId)

# convert positionText into factor
res$driv_positionText <- factor(res$driv_positionText)


merge_res <- full_join(res, merge_quali, by=c("raceId", "driverId", "constructorId"))

# where there isn't a qualifying resulting race start position, we have a grid start position
startpositions <- merge_res %>%
  filter(is.na(driv_start_pos)) %>%
  kable() %>% 
  kable_styling(full_width = F) %>% 
  scroll_box(width = "100%", height = "200px")

# replace driv_start_pos with grid where driv_start_pos is NA
merge_res <- merge_res %>%
  mutate(driv_start_pos=replace(driv_start_pos, is.na(driv_start_pos), grid[is.na(driv_start_pos)])) %>%
  select(-grid)


# remove time, milliseconds
merge_res <- merge_res %>%
  select(-c(time, milliseconds))



lap <- lap_times %>%
  mutate(time=lap_time_convert(time)) %>%
  select(raceId, driverId, time, position) %>%
  # average lap time, and position
  group_by(raceId, driverId) %>%
  summarise(avg_lap_time = mean(time), avg_lap_pos = round(mean(position)))



# convert pit stop duration (NOT time) into numeric
pit <- pit_stops %>%
  mutate(duration=as.numeric(duration)) %>%
  select(raceId, driverId, stop, duration) %>%
  # average pit stop duration (for a race)
  group_by(raceId, driverId) %>%
  summarise(avg_pit = mean(duration))


merge_res <- full_join(merge_res, lap, by=c("raceId", "driverId"))
merge_res <- full_join(merge_res, pit, by=c("raceId", "driverId"))


driver_stand <-  driver_standings %>%
  rename(driv_standing=position, driv_standingText=positionText, sum_driv_pnts=points, driv_wins=wins)

# nothing else to change about standings, let's merge our modified drivers related data set now
merge_driv <- full_join(merge_res, driver_stand, by=c("raceId", "driverId"))

# remove unnecessary variables, rename for more distinction
merge_driv <- merge_driv %>%
  select(-c(resultId, driverStandingsId)) %>%
  rename(fastestLapTime_rank=rank)



race <- races %>%
  rename(race_name=name, race_time=time, season=year) %>%
  select(raceId,season,round,circuitId,race_name)

circ <- circuit %>%
  rename(circ_name=name, circ_country=country) %>%
  select(circuitId, circ_country,circuitRef, circ_name)

race <- full_join(race, circ, by="circuitId")

stat <- status %>%
  rename(driv_statusId=statusId)

driv <- drivers %>%
  select(-number, -code) %>%
  mutate(dob = as.numeric(substr(dob, 1,4)))


# add race data: year, round, country etc.
merge_con <- full_join(merge_con, race, by="raceId")
merge_driv <- full_join(full_join(merge_driv, race, by="raceId"),driv, by="driverId")
# add status
merge_driv <- full_join(merge_driv, stat, by="driv_statusId")
merge_driv$status <- factor(merge_driv$status)



save(con_stand, con_res, merge_con, lap_time_convert, quali, sprint_res, merge_quali,
     res, merge_res, lap, pit, driver_stand, merge_driv, race, circ, stat, driv, rest_of_q1,
     rest_of_q2,rest_of_q3,quali_na, startpositions,
     file="modify_data.rda")



