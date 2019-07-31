# This scripts parses the text files created by wdiff and brings them into a usable R format.
# CLI: wdiff gg_1949_Kopie.txt gg_2012_Kopie.txt > compare.txt

library(dplyr)

d <- readLines("data/wdiff_49_12_complete.txt")

# Get Headlines
headlines <- c()
for (i in seq_along(d)) {
  current_line <- d[i]
  
  if (grepl("---|===", current_line, ignore.case = TRUE)) {
    headline <- i-1
    headlines <- c(headlines, headline)
    print(i-1)
    print(d[i-1])
  }
}

full_text <- c()
# Get Text between Headlines
for (j in seq_along(headlines)) {
  
  headline_before <- headlines[j] + 2
  headline_after <- headlines[j+1] - 1
  
  print(paste0(headline_before, " / ", headline_after))
  
  if (is.na(headline_after)) {
    headline_after <- length(d)
  }
  
  prior_text <- case_when(
    grepl("\\{+", d[headlines[j]]) ~ "{+",
    grepl("\\[-", d[headlines[j]]) ~ "[-",
    TRUE ~ ""
  )
  
  after_text <- case_when(
    grepl("\\+\\}", d[headlines[j]]) ~ "+}",
    grepl("\\-\\]", d[headlines[j]]) ~ "-]",
    TRUE ~ ""
  )
  
  print(paste(prior_text, "//", after_text))
  
  if (after_text != "") {
    full_text[j-1] <- paste0(full_text[j-1], after_text, collapse = "")
  }
  
  current_text <- trimws(d[headline_before:headline_after])
  
  current_text <- trimws(paste(current_text, collapse = " "))
  current_text <- paste0(prior_text, current_text, collapse = "")
  
  full_text <- c(full_text, current_text)
  
  print(paste0(current_text, collapse = ""))
  print("-------------------")
}

d_complete <- tibble(d[headlines], trimws(full_text))

names(d_complete) <- c("Headline", "Text")

#saveRDS(d_complete, "parsed_gg.RData")





