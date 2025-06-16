
rm(list=ls())
library(ggplot2)


set_cols <- c("#00caa9", "#ffb732")
names(set_cols) <- c("GG2", "GTDB")
mode_cols <- c("#ef5826", "#5dcdff", "#9f8500", "#00467e")
names(mode_cols) <- c("sintax", "usearch_global", "usearch-self", "search_exact")


head(way4 <- read.table("~/Dropbox/MTU/mtu__alfreed/input/mtu__alfreed__vsearch-4way.tsv", sep = "\t", quote = "")[ , -5 ])
colnames(way4) <- c( "mode","accession\nmatched %","species\nmatched %","genus\nmatched %","time (sec)","memory_kb","% classifications","subset")

way4[ , "memory\n(MB)"] <- way4$memory_kb/1000
way4[ , c(2,3,4,7)] <- (way4[ , c(2,3,4,7)]/1000)*100


# # for presenting only GTDB - hash out for full comparison
# dim(way4 <- dplyr::filter( way4, grepl("GTDB", subset)))


head( vm <- reshape2::melt( way4[ , -6], id.vars = c("mode", "subset")))
vm$variable <- factor( vm$variable, levels = c( "mode","accession\nmatched %","species\nmatched %","genus\nmatched %","time (sec)","memory\n(MB)","% classifications","subset") )
vm$value <- as.numeric( vm$value )

vm$set <- ifelse( grepl( "GTDB", vm$subset), "GTDB", "GG2")
vm$seqleng <- ifelse( grepl( "-full-", vm$subset), "full", "V3V4")
vm$range <- as.numeric(gsub(".*\\.(\\d)\\.\\d*\\.out", "\\1", vm$subset, perl = TRUE))

## essentially the same plot, but with points instead of bars. Better illustration of the spread of values
  # ggplot( dplyr::filter(vm), aes( x = mode, y = value, colour = set)) + 
  #   coord_flip() + 
  #   theme_minimal() +
  #   # geom_violin( aes( ) ) +
  #   geom_jitter(aes(shape = seqleng), size = 3, position = position_jitterdodge(jitter.width = 0.5, jitter.height = 0.5)) +
  #   facet_wrap( . ~ variable, scales ="free") + 
  #   scale_shape_manual( values = c(3,19), "sequence length:") +
  #   scale_colour_manual( values = set_cols, "vsearch mode:") +
  #   theme(
  #     text = element_text(size = 14),
  #     axis.text.x = element_text(angle = 0),
  #     axis.text.y = element_text(size = 14),
  #     axis.line = element_line(colour = "grey20"),
  #     strip.text.x = element_text(size = 18),
  #     legend.position = "bottom"
  #   ) +
  #   labs( x = "", y = ""  ) + 
  #   guides(
  #     colour = guide_legend(override.aes = list(alpha = 1, size = 8, shape = 19))
  #   )

head(vmm <- reshape2::melt(aggregate(value ~ mode + seqleng + set + variable, data = vm, FUN = mean))[, -5])
ggplot( vmm, aes( x = mode, y = value, colour = set, fill = set), drop = FALSE) + 
  theme_minimal() +
  coord_flip() + 
  facet_wrap( . ~ variable, scales ="free") + 
  geom_col(aes(alpha = seqleng), size = 1.25, position = position_dodge(width = 0.7), width = 0.6) +
  # stat_summary(geom = "errorbar", fun.data = mean_se, position = "dodge") +
  scale_colour_manual( values = set_cols, "vsearch mode:") +
  scale_fill_manual( values = set_cols, "vsearch mode:") +
  scale_alpha_manual(values = c(0.9,0.3), "sequence length:") +
  theme(
    text = element_text(size = 14),
    axis.text.x = element_text(angle = 0),
    axis.text.y = element_text(size = 14),
    axis.line = element_line(colour = "grey20"),
    strip.text.x = element_text(size = 18),
    legend.position = "bottom"
  ) +
  labs( x = "", y = ""  ) 


## dotplot of spc_accuracy * time
way4$seqleng <- ifelse( grepl("-full-", way4$subset), "full", "V3V4")
way4$nspec <- as.numeric(gsub(".*\\.(\\d)\\.\\d*\\.out", "\\1", way4$subset, perl = TRUE))
way4$db <- ifelse( grepl("GTDB", way4$subset), "GTDB", "GG2")
ggplot( way4, aes(y = `species\nmatched %`, x = log10(`time (sec)`), shape = seqleng) ) + 
  theme_minimal() +
  facet_wrap( . ~ db ) +
  geom_point(aes(, fill = mode), size = 5, alpha = 0.4) + 
  scale_shape_manual( values = c(21, 24,23,22), "sequence length:") + 
  scale_fill_manual( values = mode_cols, "vsearch mode:") + 
  # labs( x = "", y = ""  ) + 
  guides(
    fill = guide_legend(override.aes = list(alpha = 1, size = 8, shape = 22)),
    shape = guide_legend(override.aes = list(alpha = 1, size = 8, linewidth = 2))
  ) + 
  theme(
    text = element_text(size = 14),
    axis.line = element_line(colour = "grey20"),
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.position = c(0.15, 0.4)
  ) +
  labs(title = "accuracy of species level prediction v. time in seconds")

knitr::kable( aggregate( `accession\nmatched %` ~ nspec + seqleng  + mode + db, data = way4, FUN = mean ))

knitr::kable( 
  cbind( 
    aggregate( `species\nmatched %` ~ nspec + seqleng  + mode + db, data = way4, FUN = mean ),
    "genus matched %" = aggregate( `genus\nmatched %` ~ nspec + seqleng  + mode + db, data = way4, FUN = mean )[, 5],
    "time (sec)" = aggregate( `time (sec)` ~ nspec + seqleng  + mode + db, data = way4, FUN = mean )[, 5]
  ))

