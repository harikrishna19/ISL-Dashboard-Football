# When do the teams score and how?

library(worldfootballR)
library(StatsBombR)



# Fetching Match URLS -----------------------------------------------------

match_urls<- fb_match_urls(country = "IND", gender = "M", season_end_year = 2023, tier="1st")




# Report for every Game ---------------------------------------------------

match_report<-fb_match_report(match_url = match_urls)


match_summaries=fb_match_summary(match_url = match_urls)




