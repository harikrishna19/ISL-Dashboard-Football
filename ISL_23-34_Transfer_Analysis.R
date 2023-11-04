# When do the teams score and how?


library(reactable)
library(reactablefmtr)
library(tidyverse)
library(rvest)


site<-"https://www.indiansuperleague.com"

aa<-read_html(site) %>% html_elements(".club-image img") %>% html_attr("src")
aa<-paste0(site,aa)

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
  All_Transfers[[i]]$Club_Logo_URL<-aa[[i]]
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

All_Transfers<-All_Transfers %>% select(-Nat.)



write.csv(All_Transfers,"All_Transfers.csv")

reactable(
  All_Transfers %>% filter(
    Team_Name == "Bengaluru FC",
    Transfer_Type ==
      "Arrivals"
  ) %>% select(`Player Name`, Club_Logo_URL, everything()),
  theme = flatly(
    font_size = 12,
    font_color = "grey",
    cell_padding = 3
  ),
  pagination = F,
  striped = T,
  bordered = T,
  highlight = T,
  compact = T,
  columns = list(
    #Club_Logo_URL = colDef(show = FALSE),
    `Player Name`= colDef(align="center"),
    Age=colDef(align="center"),
    Position=colDef(align="center"),
    Fee=colDef(align="center"),
    Pos=colDef(align="center"),
    `Market value`=colDef(align="center"),
    Team_Name=colDef(show=F),
    Transfer_Type=colDef(show=F),
    Club_Logo_URL = colDef(
      name = "Team",
      align = "center",
      cell = embed_img( width = 40)
    )
    #Club_Logo_URL = colDef(cell = embed_img(width = "20px", height = "30px"))
  )
)




# Report for every Game ---------------------------------------------------

match_report<-fb_match_report(match_url = match_urls[1])


match_summaries=fb_match_summary(match_url = match_urls[1])


#Getting MAtch LineUps

match_lineups=fb_match_lineups(match_urls[1])



adv<-fb_advanced_match_stats(match_url = match_urls[1], stat_type = "possession", team_or_player = "team")



# Access one game ---------------------------------------------------------













