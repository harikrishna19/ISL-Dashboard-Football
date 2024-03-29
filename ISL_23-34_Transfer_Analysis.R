# When do the teams score and how?


library(reactable)
library(reactablefmtr)
library(tidyverse)
library(rvest)


site <- "https://www.indiansuperleague.com"

club_image_url <-
  read_html(site) %>% html_elements(".club-image img") %>% html_attr("src")
club_image_url <- paste0(site, club_image_url)


club_image_titles <-
  read_html(site) %>% html_elements(".club-name") %>% html_text() %>% .[1:24]

club_img_details <-
data.frame("Club_Image_URL" = club_image_url, "Club_Title" = club_image_titles)




Fetch_titles<-read_html(
  "https://www.transfermarkt.co.in/indian-super-league/transfers/wettbewerb/IND1"
) %>% html_elements(".content-box-headline--logo a") %>% html_attr("title")

Fetch_titles<-gsub("Array","",Fetch_titles)


# Get the indices for sorting
indices <- order(match(club_img_details$Club_Title, Fetch_titles))

# Sort the data frame based on the vector
club_img_details1 <- club_img_details[indices, ]



All_Transfers<-read_html(
  "https://www.transfermarkt.co.in/indian-super-league/transfers/wettbewerb/IND1"
) %>% html_elements(".responsive-table") %>% html_table() 



for (i in 1:length(All_Transfers)) {
  All_Transfers[[i]]$Team_Name<-club_img_details1$Club_Title[[i]]
  All_Transfers[[i]]$Club_Logo_URL<-club_img_details1$Club_Image_URL[[i]]
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



write.csv(All_Transfers,"All_Transfers.csv",row.names =FALSE,fileEncoding ="UTF-8")

# Add CSS to remove scrollbar and set table height
css <- "
.reactable-container {
  overflow: auto !important;
  max-height: none !important;
}
"

reactable(
  data,
  theme = fivethirtyeight(header_font_color = "red",centered = T),
  pagination = T,
  fullWidth = T,
  striped = T,
  bordered = T,
  highlight = T,
  compact = T,
  columns = list(
    `Player Name`= colDef(align="center",width=200,sticky = "right"),
    Age=colDef(align="center",width=200),
    Position=colDef(align="center",width=200),
    Fee=colDef(align="center",width=200),
    Pos=colDef(align="center",width=100),
    `Market values`=colDef(align="center",width=200),
    Team_Name=colDef(show=F),
    Transfer_Type=colDef(show=F),
    Club_Logo_URL = colDef(
      name = "Team",
      align = "center",
      cell = embed_img( width = "55px",height="35px")
    )
    #Club_Logo_URL = colDef(cell = embed_img(width = "20px", height = "30px"))
  )
)



# # Report for every Game ---------------------------------------------------
#
# match_report<-fb_match_report(match_url = match_urls[1])
#
#
# match_summaries=fb_match_summary(match_url = match_urls[1])
#
#
# #Getting MAtch LineUps
#
# match_lineups=fb_match_lineups(match_urls[1])
#
#
#
# adv<-fb_advanced_match_stats(match_url = match_urls[1], stat_type = "possession", team_or_player = "team")
#
#
#
# # Access one game ---------------------------------------------------------