# When do the teams score and how?

library(worldfootballR)
library(StatsBombR)
library(reactable)
library(reactablefmtr)
library(tidyverse)



# Getting Transfer Market Data --------------------------------------------

# 
# team_urls <- tm_league_team_urls(country_name = "India", start_year = 2023)
# 
# 
# all_teams_transfers <- tm_team_transfers(team_url = team_urls, transfer_window = "all")
# 
# 
# isl_league_valuations <- tm_player_market_values(country_name = "India",
#                                                start_year = 2023)
# 
# 
# 
# # Fetching Match URLS -----------------------------------------------------
# 
# match_urls<- fb_match_urls(country = "IND", gender = "M", season_end_year = 2024, tier="1st")
# 





library(rvest)

scrape_image <-
  read_html(
    "https://www.transfermarkt.co.in/indian-super-league/transfers/wettbewerb/IND1"
  ) %>% html_elements(".content-box-headline--logo img") %>% html_attr("src") 

scrape_image<-rep(scrape_image,each=2)

Fetch_titles<-read_html(
  "https://www.transfermarkt.co.in/indian-super-league/transfers/wettbewerb/IND1"
) %>% html_elements(".content-box-headline--logo a") %>% html_attr("title")

Fetch_titles<-gsub("Array","",Fetch_titles)

All_Transfers<-read_html(
  "https://www.transfermarkt.co.in/indian-super-league/transfers/wettbewerb/IND1"
) %>% html_elements(".responsive-table") %>% html_table() 



for (i in 1:length(All_Transfers)) {

  
  All_Transfers[[i]]$Team_Name<-Fetch_titles[[i]]
  All_Transfers[[i]]$Club_Logo_URL<-scrape_image[[i]]
  if(grepl("In",colnames(All_Transfers[[i]])[1])==T){
    All_Transfers[[i]]$Transfer_Type="Arrivals"
    All_Transfers[[i]]<-All_Transfers[[i]] %>% select(-Left)
  }
  else{
    All_Transfers[[i]]$Transfer_Type="Departures"
    All_Transfers[[i]]<-All_Transfers[[i]] %>% select(-Joined)
  }
  colnames(All_Transfers[[i]])[1]<-"Player Name"
  #Dropping columns Left and Joined for now
  
}

All_Transfers<-do.call(rbind,All_Transfers)
All_Transfers<-as.data.frame(All_Transfers)



reactable(All_Transfers %>% filter(Team_Name=="East Bengal FC") %>% select(`Player Name`,Club_Logo_URL,everything()),
          columns = list(
            Club_Logo_URL = colDef(cell = embed_img())))





# Report for every Game ---------------------------------------------------

match_report<-fb_match_report(match_url = match_urls[1])


match_summaries=fb_match_summary(match_url = match_urls[1])


#Getting MAtch LineUps

match_lineups=fb_match_lineups(match_urls[1])



adv<-fb_advanced_match_stats(match_url = match_urls[1], stat_type = "possession", team_or_player = "team")



# Access one game ---------------------------------------------------------













