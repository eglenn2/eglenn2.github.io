require(rvest)
require(dplyr)
require(purrr)
require(tidyr)

#Run below line if first time to install required packages - 
#install.packages(install.packages(c("rvest", "dplyr", "rio", "purrr", "tidyr"))


#####################################
#                FAQ                #
#What does this do?                 #
#Exports table of information from  #
#APPIC Directory Site Info Pages    #
#####################################

#############################################
#                 Credits                   #
#Made by Elizabeth Glenn, 2021              #
#PhD Student, University of Oregon          #
#Contact: eglenn2@uoregon.edu               #
#############################################

###############################################################
# Requirements (AKA INSTRUCTIONS) -                           # 
# .csv with one column titled "Link",                         #
# with list of directory links                                #
# (e.g., https://membership.appic.org/directory/display/045)  #
###############################################################

####################
# Set Dependencies #
####################

output_file <- "APPIC_info.xlsx" #change if you want to


#Press Run
#Choose your file that has a list of directory links
#Output file is set to APPIC_site_info.xlsx

dir_list <- read.csv(file.choose(), col.names = "Link")
counter = 1
APPIC_list = list()
for (website in dir_list$Link) {
  APPIC_info <- read_html(website)
  
  APPIC <- APPIC_info %>% 
    html_nodes(".collapsible fieldset table") %>% 
    html_table(header = FALSE, fill = TRUE) %>%
    keep(~ ncol(.x) == 2) %>%
    bind_rows %>%
    rename(var = X1) %>%
    rename(data = X2) %>%
    filter(var != "") %>%
    pivot_wider(names_from = var, 
                values_from = data)

program <- APPIC_info %>% 
  html_nodes(".collapsible:nth-child(9) .program-desc") %>% 
  html_text() %>% list("Program Description" = .)

APPIC <- c(APPIC, program)
APPIC_list[[website]] <- APPIC


percent <- round((counter/nrow(dir_list))*100, digits = 1)
counter <- counter + 1
print(paste(percent, "% of the way there."))
}

APPIC_data <- bind_rows(APPIC_list)
export(APPIC_data, paste(filepath, output_file))
print(paste("Data Exported to", filepath))