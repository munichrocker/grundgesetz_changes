library(dplyr)
library(stringr)

files_1949 <- list.files("data/markdown/1949")
files_2019 <- list.files("data/markdown/2019")

texts <- vector(length = length(files_2019))

for (i in seq_along(files_2019)) {
  file_19i <- paste0("data/markdown/2019/", files_2019[i])
  file_49i <- paste0("data/markdown/1949/", files_2019[i])
  print(file_19i)
  
  if (!file.exists(file_49i)) {
    print(paste0("Does not exist in 1949: ", files_2019[i]))
    texts[i] <- paste0("{+", paste0(readLines(file_19i), collapse = "\n"), "+}")
    next
  }
  system_cmd <- paste0("wdiff -i ", file_49i, " ", file_19i)
  texts[i] <- try(paste0(system(system_cmd, intern = TRUE), collapse = "\n"))
}

# vorher: "\\[(.+?)\\]\\(\\#.+?\\)"
texts <- gsub(pattern = "\\[(?!-)(.+?)\\]\\(\\#.+?\\)", replacement = "\\1", texts, perl = TRUE) # remove Artikel-Links
texts[22] <- "## Artikel 18\n\nWer die Freiheit der Meinungsäußerung, insbesondere die Pressefreiheit (Artikel 5 Absatz 1), die Lehrfreiheit (Artikel 5 Absatz 3), die Versammlungsfreiheit (Artikel 8), die Vereinigungsfreiheit (Artikel 9), das Brief-, Post- und Fernmeldegeheimnis (Artikel 10), das Eigentum (Artikel 14) oder das Asylrecht (Artikel [-16 Absatz 2-] {+16a+}) zum Kampfe gegen die freiheitliche demokratische Grundordnung mißbraucht, verwirkt diese Grundrechte. Die Verwirkung und ihr Ausmaß werden durch das Bundesverfassungsgericht ausgesprochen.\n" # hard coded for Sonderfall Artikel 18
headlines <- unlist(lapply(str_match_all(texts, "\\#{1,2}\\s?(.*?)\\n"), function(x) paste(x[,2], collapse = "\n")))
texts <- gsub("\\#{1,2}\\s?(.*?)\\n", "", texts) # remove Headlines from texts

d_complete <- data.frame(Headline = headlines, Text = texts)

#saveRDS(d_complete, "parsed_gg.RData")
