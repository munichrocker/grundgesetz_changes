# This script analyzes the data_frame of the grundgesetz
library(tidyverse)
library(stringr)

d <- readRDS("parsed_gg.RData")

d$Text <- as.character(d$Text)

check_aufgehoben <- function(x) {
  result <- vector(length = length(x))
  for (i in 1:length(x)) {
    x[i] <- trimws(str_remove_all(x[i], "\\[-[\\s\\S]+?-\\]"))
    if (nchar(x[i]) > 17) {
      result[i] <- FALSE
    } else {
      result[i] <- TRUE
    }
  }
  result
}

check_aufgehoben_single <- function(x) {
  x[i] <- trimws(str_remove_all(x[i], "\\[-[\\s\\S]+?-\\]"))
  if (nchar(x[i]) > 17) {
    result <- FALSE
  } else {
    result <- TRUE
  }
  result
}

d$Aufgehoben <- check_aufgehoben(d$Text)

d %>% 
  rowwise() %>% 
  mutate(char_removed = nchar(paste0(unlist(str_extract_all(Text, "(?<=\\[-)[\\s\\S]+?(?=-\\])")), collapse = " ")),
         char_added = nchar(paste0(unlist(str_extract_all(Text, "(?<=\\{\\+)[\\s\\S]+?(?=\\+\\})")), collapse = " ")),
         Text = trimws(str_remove_all(Text, "\\s?\\[[\\s\\S]+?\\]|\\{[\\s\\S]+?\\}\\s?")),
         char_unchanged = nchar(Text),
         char_removed = ifelse(Aufgehoben == TRUE, 1, char_removed),
         char_added = ifelse(Aufgehoben == TRUE, 0, char_added)) -> d_ready

d_ready %>% 
  gather(type, value, starts_with("char")) %>% 
  mutate(type = factor(type, levels = c("char_removed", "char_added", "char_unchanged"))) %>%
  mutate(Headline = factor(Headline, levels = rev(d$Headline))) -> d_analyzed
  
# Erste Grafik: Veränderung nach einzelnen Elementen
ggplot(d_analyzed, aes(Headline, value, fill = type)) +
  geom_bar(stat = "identity")+
  coord_flip() +
  scale_fill_manual(values = c("char_unchanged" = "grey", "char_added" = "darkgreen", "char_removed" = "darkred"),
                    labels = c("gestrichen", "hinzugefügt", "unverändert"), name = "Text") +
  theme_minimal()

# Todo: combine all to relative Values on one stacked bar chart
d_ready$ID <- seq.int(nrow(d_ready))

d_ready %>% 
  mutate(sum_all = ifelse(sum(char_unchanged + char_removed + char_added, na.rm = TRUE) == 0, 1,
                          sum(char_unchanged + char_removed + char_added, na.rm = TRUE)),
         char_unchanged_rel = char_unchanged/sum_all,
         char_removed_rel = char_removed/sum_all,
         char_added_rel = char_added/sum_all) %>% 
  gather(type, value, ends_with("rel")) %>% 
  mutate(type = factor(type, levels = c("char_removed_rel", "char_added_rel", "char_unchanged_rel"))) %>%
  mutate(Headline = factor(Headline, levels = d$Headline)) %>% 
  ggplot(., aes(x = 1, y = value, fill = type, group = ID)) +
  geom_bar(stat = "identity") + 
  geom_hline(mapping = aes(yintercept = as.numeric(ID))) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  scale_y_reverse() +
  coord_flip() +
  theme_minimal() +
  theme(panel.background = element_blank(), 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank()) +
  scale_fill_manual(values = c("char_unchanged_rel" = "grey", "char_added_rel" = "darkgreen", "char_removed_rel" = "darkred"),
                    labels = c("gestrichen", "hinzugefügt", "unverändert"), name = "Text")


aspect_ratio <- 4.5
#ggsave("Aenderungen_Grundgesetz.pdf", last_plot(), height = 7, width = 7 * aspect_ratio)
