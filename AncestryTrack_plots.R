
library(ggplot2)
library(dplyr)
library(data.table)
library(ggpubr)

### Set Directory
setwd("~/Desktop/Giacomo/LAI/inputbychr/")

### Join population data

df <- read.delim("Roma.allchr.ancestrylength.csv", sep=',')

idpop <- read.delim("IDpop_info2pops.txt", header=TRUE, sep='\t') %>% 
  group_by(POP) %>%
  mutate(N = n())

dfjoin <- left_join(df,idpop,by=c("Haplotype"="ID"))

#### Do total average
avgtotal <- dfjoin %>% group_by(POP,Ancestry) %>% summarise(AvgTract=mean(TractLengths))
mediantotal <- dfjoin %>% group_by(POP,Ancestry) %>% summarise(AvgTract=median(TractLengths))

### do boxplot in R base
# Create a new variable that combines POP and Ancestry
dfjoin$POP_Ancestry <- paste(dfjoin$POP, dfjoin$Ancestry, sep = "_")

# Subset TractLengths by POP
european_lengths <- dfjoin$TractLengths[dfjoin$POP_Ancestry == "EuropeanRoma_0"]
iberian_lengths <- dfjoin$TractLengths[dfjoin$POP_Ancestry == "IberianRoma_0"]
european_lengths1 <- dfjoin$TractLengths[dfjoin$POP_Ancestry == "EuropeanRoma_1"]
iberian_lengths2 <- dfjoin$TractLengths[dfjoin$POP_Ancestry == "IberianRoma_1"]

# Create boxplot
boxplot(european_lengths, iberian_lengths, european_lengths1, iberian_lengths2, 
        names = c("EuropeanRoma_Europe", "IberianRoma_Europe","EuropeanRoma_SouthAsia", "IberianRoma_SouthAsia"),
        main = "Tract Length by Population",
        xlab = "Population_Ancestry",
        ylab = "Tract Length")

# Perform Wilcoxon rank sum test
wilcox1 <- wilcox.test(european_lengths, iberian_lengths,
                           alternative = "two.sided", 
                           conf.int = TRUE)

wilcox2 <- wilcox.test(european_lengths1, iberian_lengths2,
                           alternative = "two.sided", 
                           conf.int = TRUE)
wilcox1
wilcox2

combined_wilcox <- as.data.frame(cbind(wilcox1, wilcox2))

combined_wilcox_df <- do.call(rbind, combined_wilcox)

write.table(combined_wilcox_df,file = "/home/bioevo/Desktop/Giacomo/LAI/totalAVG_wilctest.csv",sep = "\t")

### plot wilcox results
boxplotwilc1 <- ggplot(dfjoin, aes(x = POP, y = TractLengths, fill = POP)) +
  geom_boxplot() +
  labs(title = "Boxplot of TractLengths by POP") +
  theme_minimal()

if(wilcox1$p.value < 0.05) {
  p_value <- format(wilcox1$p.value, digits = 2, scientific = TRUE)
  boxplotwilc1 <- boxplotwilc1 +
    annotate("text", x = 1, y = max(dfjoin$TractLengths), label = paste("p =", p_value), vjust = -1)
}
boxplotwilc1

boxplotwilc2 <- ggplot(dfjoin, aes(x = POP, y = TractLengths, fill = POP)) +
  geom_boxplot() +
  labs(title = "Boxplot of TractLengths by POP") +
  theme_minimal()

if(wilcox2$p.value < 0.05) {
  p_value <- format(wilcox2$p.value, digits = 2, scientific = TRUE)
  boxplotwilc2 <- boxplotwilc2 +
    annotate("text", x = 1, y = max(dfjoin$TractLengths), label = paste("p =", p_value), vjust = -1)
}
boxplotwilc2

### Define Categories of Length
# Short Tracts (0.5-20 megabases)
# Medium Tracts (20-100 megabases)
# Long Tracts (100-240 megabases)

lai_category <- dfjoin %>%
  mutate(Category = case_when(
    TractLengths >= 150 & TractLengths <= 250 ~ "150-250",
    TractLengths >= 100 & TractLengths < 150 ~ "100-150",
    TractLengths >= 20 & TractLengths < 100 ~ "20-100",
    TractLengths >= 0.03 & TractLengths < 20 ~ "0.03-20",
    TRUE ~ NA_character_  # Handling other cases, if any
  )) %>%
  ungroup()

### wilcox on total

### Boxplot by category

### optional segment
#  group_by(Haplotype, POP, lai_length_category) %>%
#  summarise(total_lai_length_per_ID = sum(TractLengths),
#           number_ROH_per_ID = n()) %>%

# calculate average length by population (multi pop)
#dfmean <- lai_category %>% group_by(POP,Ancestry,Category) %>% summarise(AvgTract=mean(TractLengths))

#dfmean$POP <- factor(dfmean$POP, levels = c("RomaEasternIberia","RomaCentralIberia","RomaNorthernIberia","RomaSouthernIberia","RomaWesternIberia","RomaIndeterminate","RomaBalkanMAK","RomaCzech","RomaLithuania","RomaRomungroHUN","RomaRomungroUKR","RomaVlaxHUN"))

# calculate average length by population (2 pop)

dfmean <- lai_category %>% group_by(POP,Ancestry,Category) %>% summarise(AvgTract=mean(TractLengths))

dfmean$POP <- factor(dfmean$POP, levels = c("IberianRoma","EuropeanRoma"))

dfmedian <- lai_category %>% group_by(POP,Ancestry,Category) %>% summarise(AvgTract=median(TractLengths))
dfmedian$POP <- factor(dfmedian$POP, levels = c("IberianRoma","EuropeanRoma"))

# Create a new variable that combines POP and Ancestry
dfmean$POP_Ancestry <- paste(dfmean$POP, dfmean$Ancestry, sep = "_")

dfmedian$POP_Ancestry <- paste(dfmedian$POP, dfmean$Ancestry, sep = "_")

# Define custom labels for x-axis
custom_labels <- c("IberianRoma_0", "IberianRoma_1", "EuropeanRoma_0", "EuropeanRoma_1")

# Reorder the levels of POP_Ancestry variable to ensure proper ordering
dfmean$POP_Ancestry <- factor(dfmean$POP_Ancestry, levels = custom_labels)

dfmedian$POP_Ancestry <- factor(dfmedian$POP_Ancestry, levels = custom_labels)

# Convert Category to a factor with ordered levels
dfmean$Category <- factor(dfmean$Category, levels = c("0.03-20", "20-100", "100-150", "150-250"))

dfmedian$Category <- factor(dfmedian$Category, levels = c("0.03-20", "20-100", "100-150", "150-250"))

# Plot with dodged bars for each category, population, and state
p1 <- ggplot(dfmean, aes(x = POP_Ancestry, y = AvgTract, fill = Category, color = Category)) +
  geom_col(position = "dodge", alpha = 0.5) +
  labs(x = "", y = "Average Tract Length (MB)") + # Modified y-axis title
  theme_bw() +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1)) + # Rotate x-axis labels for better readability
  scale_colour_manual(values = c("#AC61A1","#034424", "#FF5733","#59dbf3"), labels = c("Short", "Medium","Long","Very Long"), name = "Category") +
  scale_fill_manual(values = c("#AC61A1","#034424", "#FF5733","#59dbf3"), labels = c("Short", "Medium","Long","Very Long"), name = "Category") +
  guides(fill = guide_legend(title = "Length Category"),
         color = guide_legend(title = "Length Category")) + # Change the legend title for fill and color
  scale_x_discrete(labels = function(x) {
    x <- gsub("EuropeanRoma_0", "EuropeanRoma_Europe", x)
    x <- gsub("EuropeanRoma_1", "EuropeanRoma_SouthAsia", x)
    x <- gsub("IberianRoma_0", "IberianRoma_Europe", x)
    x <- gsub("IberianRoma_1", "IberianRoma_SouthAsia", x)
    return(x)
  }) # Replace labels
p1

p1 <- ggplot(dfmean, aes(x = POP_Ancestry, y = AvgTract, fill = Category, color = Category)) +
  geom_col(position = "dodge", alpha = 0.5) +
  labs(x = "", y = "Average Tract Length (MB)") + # Modified y-axis title
  theme_bw() +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1)) + # Rotate x-axis labels for better readability
  scale_colour_manual(values = c("#AC61A1","#034424", "#FF5733","#59dbf3"), labels = c("Short", "Medium","Long","Very Long"), name = "Category") +
  scale_fill_manual(values = c("#AC61A1","#034424", "#FF5733","#59dbf3"), labels = c("Short", "Medium","Long","Very Long"), name = "Category") +
  guides(fill = guide_legend(title = "Length Category"),
         color = guide_legend(title = "Length Category")) + # Change the legend title for fill and color
  scale_x_discrete(labels = function(x) {
    x <- gsub("EuropeanRoma_0", "EuropeanRoma_Europe", x)
    x <- gsub("EuropeanRoma_1", "EuropeanRoma_SouthAsia", x)
    x <- gsub("IberianRoma_0", "IberianRoma_Europe", x)
    x <- gsub("IberianRoma_1", "IberianRoma_SouthAsia", x)
    return(x)
  })
p1

## number of tracts
dfnumbermean <- lai_category %>% group_by(POP,Ancestry,Category,N) %>% summarise(NTract=n()) %>% 
  mutate(weightednumber=NTract/N)

# Create a new variable that combines POP and Ancestry
dfnumbermean$POP_Ancestry <- paste(dfnumbermean$POP, dfnumbermean$Ancestry, sep = "_")

# Define custom labels for x-axis
custom_labels <- c("IberianRoma_0", "IberianRoma_1", "EuropeanRoma_0", "EuropeanRoma_1")

# Reorder the levels of POP_Ancestry variable to ensure proper ordering
dfnumbermean$POP_Ancestry <- factor(dfnumbermean$POP_Ancestry, levels = custom_labels)

# Convert Category to a factor with ordered levels
dfnumbermean$Category <- factor(dfnumbermean$Category, levels = c("0.03-20", "20-100", "100-150", "150-250"))

### plot
p1 <- ggplot(dfnumbermean, aes(x = POP_Ancestry, y = weightednumber, fill = Category, color = Category)) +
  geom_col(position = "dodge", alpha = 0.5) +
  labs(x = "", y = "Average Number of Tracts by ID") + # Modified y-axis title
  theme_bw()+
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1)) + # Rotate x-axis labels for better readability
  scale_colour_manual(values = c("#AC61A1","#034424", "#FF5733","#59dbf3"), labels = c("Short", "Medium","Long","Very Long"), name = "Category") +
  scale_fill_manual(values = c("#AC61A1","#034424", "#FF5733","#59dbf3"), labels = c("Short", "Medium","Long","Very Long"), name = "Category") +
  guides(fill = guide_legend(title = "Length Category"),
         color = guide_legend(title = "Length Category")) + # Change the legend title for fill and color
  scale_x_discrete(labels = function(x) {
    x <- gsub("EuropeanRoma_0", "EuropeanRoma_Europe", x)
    x <- gsub("EuropeanRoma_1", "EuropeanRoma_SouthAsia", x)
    x <- gsub("IberianRoma_0", "IberianRoma_Europe", x)
    x <- gsub("IberianRoma_1", "IberianRoma_SouthAsia", x)
    return(x)
  })
p1

### violin plot version

# Convert Ancestry and POP to factors
lai_category$Ancestry <- factor(lai_category$Ancestry)
lai_category$POP <- factor(lai_category$POP)

lai_category$Category <- factor(lai_category$Category, levels = c("0.03-20", "20-100", "100-150", "150-250"))

# Create the violin plot
p <- ggplot(lai_category, aes(x = Category, y = TractLengths, fill = Ancestry)) +
  geom_violin(trim = FALSE) +
  facet_grid(POP ~ ., scales = "free", space = "free") +
  labs(x = "Category", y = "Tract Lengths", fill = "Ancestry", title = "Distribution of Tract Lengths") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
p

# Plot with dodged bars for each category, population, and state
p1median <- ggplot(dfmedian, aes(x = POP_Ancestry, y = AvgTract, fill = Category, color = Category)) +
  geom_col(position = "dodge", alpha = 0.5) +
  labs(x = "", y = "Average Tract Length (MB)") + # Modified y-axis title
  theme_bw() +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1)) + # Rotate x-axis labels for better readability
  scale_colour_manual(values = c("#AC61A1","#034424", "#FF5733","#59dbf3"), labels = c("Short", "Medium","Long","Very Long"), name = "Category") +
  scale_fill_manual(values = c("#AC61A1","#034424", "#FF5733","#59dbf3"), labels = c("Short", "Medium","Long","Very Long"), name = "Category") +
  guides(fill = guide_legend(title = "Length Category"),
         color = guide_legend(title = "Length Category")) + # Change the legend title for fill and color
  scale_x_discrete(labels = function(x) {
    x <- gsub("EuropeanRoma_0", "EuropeanRoma_Europe", x)
    x <- gsub("EuropeanRoma_1", "EuropeanRoma_SouthAsia", x)
    x <- gsub("IberianRoma_0", "IberianRoma_Europe", x)
    x <- gsub("IberianRoma_1", "IberianRoma_SouthAsia", x)
    return(x)
  }) # Replace labels
p1median

### Calculate and plot variance

tract_variance <- lai_category %>%
  group_by(POP, Ancestry) %>%
  summarise(variance = var(TractLengths))

p2 <- ggplot(tract_variance, aes(x = POP, y = variance, fill = as.factor(Ancestry))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "Population", y = "Variance of Tract Lengths", fill = "Ancestry") +
  theme_bw() +
  theme(legend.position = "top")

print(p2)

# Calculate standard deviation of tracts by population and ancestry
tract_sd <- lai_category %>%
  group_by(POP, Ancestry) %>%
  summarise(sd_length = sd(TractLengths))

# Plot standard deviation of tracts by population and ancestry
p3 <- ggplot(tract_sd, aes(x = POP, y = sd_length, fill = as.factor(Ancestry))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "Population", y = "Standard Deviation of Tract Lengths", fill = "Ancestry") +
  theme_bw() +
  theme(legend.position = "top")
p3

library(ggpubr)

ggarrange(p2, p3, common.legend = TRUE)

### Mann-U Test

############## wilcox test
lai_category_Utest1 <- lai_category %>% filter(Category=="0.03-20")
lai_category_Utest2 <- lai_category %>% filter(Category=="20-100")
lai_category_Utest3 <- lai_category %>% filter(Category=="100-150")
lai_category_Utest4 <- lai_category %>% filter(Category=="150-250")

lai_category_Utest1 <- unite(lai_category_Utest1, 
                             col = "POP_Ancestry", 
                             c("POP","Ancestry"), 
                             sep = "_")

testwilc <- pairwise.wilcox.test(lai_category_Utest1$TractLengths,
                                 lai_category_Utest1$POP_Ancestry, p.adjust.method = "bonferroni")

wilctable <- as.data.frame(testwilc[3])

#write.table(wilctable,file = "/home/bioevo/Desktop/Giacomo/LAI/LAI_wilctest.csv")

# Subset the data for the comparisons of interest
subset_data_1 <- lai_category_Utest1[lai_category_Utest1$POP_Ancestry %in% c("IberianRoma_0", "EuropeanRoma_0"), ]
subset_data_2 <- lai_category_Utest1[lai_category_Utest1$POP_Ancestry %in% c("IberianRoma_1", "EuropeanRoma_1"), ]

# Perform the Wilcoxon rank sum test for the comparisons
test_1 <- wilcox.test(TractLengths ~ POP_Ancestry, data = subset_data_1)
test_2 <- wilcox.test(TractLengths ~ POP_Ancestry, data = subset_data_2)

# Extract the p-values
p_value_1 <- test_1$p.value
p_value_2 <- test_2$p.value

# Check if the p-values are significant
alpha <- 0.05

## check
if (p_value_1 < alpha) {
  cat("Statistically significant difference between IberianRoma_0 and EuropeanRoma_0.\n")
} else {
  cat("No statistically significant difference between IberianRoma_0 and EuropeanRoma_0.\n")
}

if (p_value_2 < alpha) {
  cat("Statistically significant difference between IberianRoma_1 and EuropeanRoma_1.\n")
} else {
  cat("No statistically significant difference between IberianRoma_1 and EuropeanRoma_1.\n")
}

print(test_1)
print(test_2)

### Test how many IDs for each category
unique(lai_category_Utest4$Haplotype)

############# TRACTS Plot Test
tracts_category <- dfjoin %>%
  mutate(Category = case_when(
    TractLengths >= 0 & TractLengths < 5 ~ "0-5",
    TractLengths >= 5 & TractLengths < 10 ~ "5-10",
    TractLengths >= 10 & TractLengths < 15 ~ "10-15",
    TractLengths >= 15 & TractLengths < 20 ~ "15-20",
    TractLengths >= 20 & TractLengths < 25 ~ "20-25",
    TractLengths >= 25 & TractLengths < 30 ~ "25-30",
    TractLengths >= 30 & TractLengths < 35 ~ "30-35",
    TractLengths >= 35 & TractLengths < 40 ~ "35-40",
    TractLengths >= 40 & TractLengths < 45 ~ "40-45",
    TractLengths >= 45 & TractLengths < 50 ~ "45-50",
    TractLengths >= 50 & TractLengths < 55 ~ "50-55",
    TractLengths >= 55 & TractLengths < 60 ~ "55-60",
    TractLengths >= 60 & TractLengths < 65 ~ "60-65",
    TractLengths >= 65 & TractLengths < 70 ~ "65-70",
    TractLengths >= 70 & TractLengths < 75 ~ "70-75",
    TractLengths >= 75 & TractLengths < 80 ~ "75-80",
    TractLengths >= 80 & TractLengths < 85 ~ "80-85",
    TractLengths >= 85 & TractLengths < 90 ~ "85-90",
    TractLengths >= 90 & TractLengths < 95 ~ "90-95",
    TractLengths >= 95 & TractLengths < 100 ~ "95-100",
    TractLengths >= 100 & TractLengths < 105 ~ "100-105",
    TractLengths >= 105 & TractLengths < 110 ~ "105-110",
    TractLengths >= 110 & TractLengths < 115 ~ "110-115",
    TractLengths >= 115 & TractLengths < 120 ~ "115-120",
    TractLengths >= 120 & TractLengths < 125 ~ "120-125",
    TractLengths >= 125 & TractLengths < 130 ~ "125-130",
    TractLengths >= 130 & TractLengths < 135 ~ "130-135",
    TractLengths >= 135 & TractLengths < 140 ~ "135-140",
    TractLengths >= 140 & TractLengths < 145 ~ "140-145",
    TractLengths >= 145 & TractLengths < 150 ~ "145-150",
    TractLengths >= 150 & TractLengths < 155 ~ "150-155",
    TractLengths >= 155 & TractLengths < 160 ~ "155-160",
    TractLengths >= 160 & TractLengths < 165 ~ "160-165",
    TractLengths >= 165 & TractLengths < 170 ~ "165-170",
    TractLengths >= 170 & TractLengths < 175 ~ "170-175",
    TractLengths >= 175 & TractLengths < 180 ~ "175-180",
    TractLengths >= 180 & TractLengths < 185 ~ "180-185",
    TractLengths >= 185 & TractLengths < 190 ~ "185-190",
    TractLengths >= 190 & TractLengths < 195 ~ "190-195",
    TractLengths >= 195 & TractLengths < 200 ~ "195-200",
    TractLengths >= 200 & TractLengths < 205 ~ "200-205",
    TractLengths >= 205 & TractLengths < 210 ~ "205-210",
    TractLengths >= 210 & TractLengths < 215 ~ "210-215",
    TractLengths >= 215 & TractLengths < 220 ~ "215-220",
    TractLengths >= 220 & TractLengths < 225 ~ "220-225",
    TractLengths >= 225 & TractLengths < 230 ~ "225-230",
    TractLengths >= 230 & TractLengths < 235 ~ "230-235",
    TractLengths >= 235 & TractLengths < 240 ~ "235-240",
    TractLengths >= 240 & TractLengths < 245 ~ "240-245",
    TractLengths >= 245 & TractLengths < 250 ~ "245-250",
    TRUE ~ NA_character_  # Handling other cases, if any
  )) %>%
  ungroup()

tracts_category <- tracts_category %>% group_by(Category,POP,Ancestry) %>% summarise(NTract=n())

write.table(tracts_category,file = "/home/bioevo/Desktop/Giacomo/LAI/tracts_category.csv",sep = "\t")

# Convert Category to a factor with ordered levels
tracts_category$Category <- factor(tracts_category$Category, 
                                   levels = c("0-5", "5-10", "10-15", "15-20", "20-25", 
                                              "25-30", "30-35", "35-40", "40-45", "45-50", 
                                              "50-55", "55-60", "60-65", "65-70", "70-75", 
                                              "75-80", "80-85", "85-90", "90-95", "95-100", 
                                              "100-105", "105-110", "110-115", "115-120", 
                                              "120-125", "125-130", "130-135", "135-140", 
                                              "140-145", "145-150", "150-155", "155-160", 
                                              "160-165", "165-170", "170-175", "175-180", 
                                              "180-185", "185-190", "190-195", "195-200", 
                                              "200-205", "205-210", "210-215", "215-220", 
                                              "220-225", "225-230", "230-235", "235-240", 
                                              "240-245", "245-250"))

# Plot with dodged bars for each category, population, and state

tractplot1 <- ggplot(tracts_category, aes(x = Category, y = log(NTract), fill = as.character(Ancestry), color = as.character(Ancestry))) +
  geom_point() +
  geom_smooth(method = "auto", aes(group = Ancestry, color = as.character(Ancestry)))+
  theme_minimal()+
  facet_wrap(~POP)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(fill = "Ancestry",  # Change legend title
       color = "Ancestry", # Change legend title for color
       x = "Tract Length (MB)",      # Change x-axis label
       y = "Number of Tracts")+
  scale_fill_manual(values = c("0" = "#3CB371", "1" = "#4682B4"), labels = new_labels) +
  scale_color_manual(values = c("0" = "#3CB371", "1" = "#4682B4"), labels = new_labels)

tractplot1

### Subsample test

# Filter EuropeanRoma haplotypes
european_haplotypes <- dfjoin %>%
  filter(POP == "EuropeanRoma")

# Filter and sample 50 random IberianRoma haplotypes
iberian_haplotypes <- dfjoin %>%
  filter(POP == "IberianRoma") %>%
  distinct(Haplotype) %>%  # Keep only unique haplotypes
  sample_n(size = 50, replace = FALSE)  # Sample 50 random haplotypes

# Filter dfjoin to keep segments related to the sampled IberianRoma haplotypes
filtered_df <- dfjoin %>%
  filter(POP == "EuropeanRoma" | (POP == "IberianRoma" & Haplotype %in% iberian_haplotypes$Haplotype))

# Modify the value in the N column for IberianRoma to be 50
filtered_df <- filtered_df %>%
  mutate(N = ifelse(POP == "IberianRoma", 50, N))

tracts_category1 <- filtered_df %>%
  mutate(Category = case_when(
    TractLengths >= 0 & TractLengths < 5 ~ "0-5",
    TractLengths >= 5 & TractLengths < 10 ~ "5-10",
    TractLengths >= 10 & TractLengths < 15 ~ "10-15",
    TractLengths >= 15 & TractLengths < 20 ~ "15-20",
    TractLengths >= 20 & TractLengths < 25 ~ "20-25",
    TractLengths >= 25 & TractLengths < 30 ~ "25-30",
    TractLengths >= 30 & TractLengths < 35 ~ "30-35",
    TractLengths >= 35 & TractLengths < 40 ~ "35-40",
    TractLengths >= 40 & TractLengths < 45 ~ "40-45",
    TractLengths >= 45 & TractLengths < 50 ~ "45-50",
    TractLengths >= 50 & TractLengths < 55 ~ "50-55",
    TractLengths >= 55 & TractLengths < 60 ~ "55-60",
    TractLengths >= 60 & TractLengths < 65 ~ "60-65",
    TractLengths >= 65 & TractLengths < 70 ~ "65-70",
    TractLengths >= 70 & TractLengths < 75 ~ "70-75",
    TractLengths >= 75 & TractLengths < 80 ~ "75-80",
    TractLengths >= 80 & TractLengths < 85 ~ "80-85",
    TractLengths >= 85 & TractLengths < 90 ~ "85-90",
    TractLengths >= 90 & TractLengths < 95 ~ "90-95",
    TractLengths >= 95 & TractLengths < 100 ~ "95-100",
    TractLengths >= 100 & TractLengths < 105 ~ "100-105",
    TractLengths >= 105 & TractLengths < 110 ~ "105-110",
    TractLengths >= 110 & TractLengths < 115 ~ "110-115",
    TractLengths >= 115 & TractLengths < 120 ~ "115-120",
    TractLengths >= 120 & TractLengths < 125 ~ "120-125",
    TractLengths >= 125 & TractLengths < 130 ~ "125-130",
    TractLengths >= 130 & TractLengths < 135 ~ "130-135",
    TractLengths >= 135 & TractLengths < 140 ~ "135-140",
    TractLengths >= 140 & TractLengths < 145 ~ "140-145",
    TractLengths >= 145 & TractLengths < 150 ~ "145-150",
    TractLengths >= 150 & TractLengths < 155 ~ "150-155",
    TractLengths >= 155 & TractLengths < 160 ~ "155-160",
    TractLengths >= 160 & TractLengths < 165 ~ "160-165",
    TractLengths >= 165 & TractLengths < 170 ~ "165-170",
    TractLengths >= 170 & TractLengths < 175 ~ "170-175",
    TractLengths >= 175 & TractLengths < 180 ~ "175-180",
    TractLengths >= 180 & TractLengths < 185 ~ "180-185",
    TractLengths >= 185 & TractLengths < 190 ~ "185-190",
    TractLengths >= 190 & TractLengths < 195 ~ "190-195",
    TractLengths >= 195 & TractLengths < 200 ~ "195-200",
    TractLengths >= 200 & TractLengths < 205 ~ "200-205",
    TractLengths >= 205 & TractLengths < 210 ~ "205-210",
    TractLengths >= 210 & TractLengths < 215 ~ "210-215",
    TractLengths >= 215 & TractLengths < 220 ~ "215-220",
    TractLengths >= 220 & TractLengths < 225 ~ "220-225",
    TractLengths >= 225 & TractLengths < 230 ~ "225-230",
    TractLengths >= 230 & TractLengths < 235 ~ "230-235",
    TractLengths >= 235 & TractLengths < 240 ~ "235-240",
    TractLengths >= 240 & TractLengths < 245 ~ "240-245",
    TractLengths >= 245 & TractLengths < 250 ~ "245-250",
    TRUE ~ NA_character_  # Handling other cases, if any
  )) %>%
  ungroup()

tracts_category1 <- tracts_category1 %>% group_by(Category,POP,Ancestry) %>% summarise(NTract=n())

# Convert Category to a factor with ordered levels
tracts_category1$Category <- factor(tracts_category1$Category, 
                                   levels = c("0-5", "5-10", "10-15", "15-20", "20-25", 
                                              "25-30", "30-35", "35-40", "40-45", "45-50", 
                                              "50-55", "55-60", "60-65", "65-70", "70-75", 
                                              "75-80", "80-85", "85-90", "90-95", "95-100", 
                                              "100-105", "105-110", "110-115", "115-120", 
                                              "120-125", "125-130", "130-135", "135-140", 
                                              "140-145", "145-150", "150-155", "155-160", 
                                              "160-165", "165-170", "170-175", "175-180", 
                                              "180-185", "185-190", "190-195", "195-200", 
                                              "200-205", "205-210", "210-215", "215-220", 
                                              "220-225", "225-230", "230-235", "235-240", 
                                              "240-245", "245-250"))

# Plot with dodged bars for each category, population, and state
new_labels <- c("Europe", "SouthAsia")

tractplot2 <- ggplot(tracts_category1, aes(x = Category, y = log(NTract), fill = as.character(Ancestry), color = as.character(Ancestry))) +
  geom_point() +
  geom_smooth(method = "auto", aes(group = Ancestry, color = as.character(Ancestry)))+
  theme_minimal()+
  facet_wrap(~POP)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(fill = "Ancestry",  # Change legend title
       color = "Ancestry", # Change legend title for color
       x = "Tract Length (MB)",      # Change x-axis label
       y = "Number of Tracts")+
  scale_fill_manual(values = c("0" = "#3CB371", "1" = "#4682B4"), labels = new_labels) +
  scale_color_manual(values = c("0" = "#3CB371", "1" = "#4682B4"), labels = new_labels)

tractplot2

ggarrange(tractplot1, tractplot2,common.legend = TRUE)

### boxplot by category
# Create a new variable that combines POP and Ancestry
lai_category$POP_Ancestry_Category <- paste(lai_category$POP, lai_category$Ancestry, lai_category$Category, sep = "_")

# Subset TractLengths by POP
# Create lines for each category
european_lengthsEUR_150_250 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "EuropeanRoma_0_150-250"]
iberian_lengthsEUR_150_250 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "IberianRoma_0_150-250"]
european_lengthsEUR_100_150 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "EuropeanRoma_0_100-150"]
iberian_lengthsEUR_100_150 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "IberianRoma_0_100-150"]
european_lengthsEUR_20_100 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "EuropeanRoma_0_20-100"]
iberian_lengthsEUR_20_100 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "IberianRoma_0_20-100"]
european_lengthsEUR_0.03_20 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "EuropeanRoma_0_0.03-20"]
iberian_lengthsEUR_0.03_20 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "IberianRoma_0_0.03-20"]

### SouthAsia

european_lengthsSA_100_150 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "EuropeanRoma_1_100-150"]
european_lengthsSA_20_100 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "EuropeanRoma_1_20-100"]
iberian_lengthsSA_20_100 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "IberianRoma_1_20-100"]
european_lengthsSA_0.03_20 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "EuropeanRoma_1_0.03-20"]
iberian_lengthsSA_0.03_20 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "IberianRoma_1_0.03-20"]

# Create boxplot
boxplotcatEUR <- boxplot(european_lengthsEUR_150_250, iberian_lengthsEUR_150_250, european_lengthsEUR_100_150, iberian_lengthsEUR_100_150, 
        european_lengthsEUR_20_100, iberian_lengthsEUR_20_100, european_lengthsEUR_0.03_20, iberian_lengthsEUR_0.03_20,
        names = c("EuropeanRoma_150-250", "IberianRoma_150-250", "EuropeanRoma_100-150", "IberianRoma_100-150",
                  "EuropeanRoma_20-100", "IberianRoma_20-100", "EuropeanRoma_0.03-20", "IberianRoma_0.03-20"),
        main = "Tract Length by Population",
        xlab = "Population_Ancestry",
        ylab = "Tract Length")

  axis(side = 1, at = 1:8, labels = c("EuropeanRoma_150-250", "IberianRoma_150-250", "EuropeanRoma_100-150", "IberianRoma_100-150",
                                      "EuropeanRoma_20-100", "IberianRoma_20-100", "EuropeanRoma_0.03-20", "IberianRoma_0.03-20"),
       las = 2)

## GGplot
# Count the number of rows in each dataset
lengths <- c(length(european_lengthsEUR_150_250), length(iberian_lengthsEUR_150_250),
             length(european_lengthsEUR_100_150), length(iberian_lengthsEUR_100_150),
             length(european_lengthsEUR_20_100), length(iberian_lengthsEUR_20_100),
             length(european_lengthsEUR_0.03_20), length(iberian_lengthsEUR_0.03_20))

# Find the minimum length
min_length <- min(lengths)

# Sample the data to make them of the same length
european_lengthsEUR_150_250 <- sample(european_lengthsEUR_150_250, min_length)
iberian_lengthsEUR_150_250 <- sample(iberian_lengthsEUR_150_250, min_length)
european_lengthsEUR_100_150 <- sample(european_lengthsEUR_100_150, min_length)
iberian_lengthsEUR_100_150 <- sample(iberian_lengthsEUR_100_150, min_length)
european_lengthsEUR_20_100 <- sample(european_lengthsEUR_20_100, min_length)
iberian_lengthsEUR_20_100 <- sample(iberian_lengthsEUR_20_100, min_length)
european_lengthsEUR_0.03_20 <- sample(european_lengthsEUR_0.03_20, min_length)
iberian_lengthsEUR_0.03_20 <- sample(iberian_lengthsEUR_0.03_20, min_length)

# Combine the data into a single data frame
data <- data.frame(
  TractLength = c(european_lengthsEUR_150_250, iberian_lengthsEUR_150_250, 
                  european_lengthsEUR_100_150, iberian_lengthsEUR_100_150, 
                  european_lengthsEUR_20_100, iberian_lengthsEUR_20_100, 
                  european_lengthsEUR_0.03_20, iberian_lengthsEUR_0.03_20),
  Population = rep(c("EuropeanRoma_150-250", "IberianRoma_150-250",
                     "EuropeanRoma_100-150", "IberianRoma_100-150",
                     "EuropeanRoma_20-100", "IberianRoma_20-100",
                     "EuropeanRoma_0.03-20", "IberianRoma_0.03-20"), each = min_length)
)

# Define the order of levels for the Population variable
order_levels <- c("EuropeanRoma_0.03-20", "IberianRoma_0.03-20",
                  "EuropeanRoma_20-100", "IberianRoma_20-100",
                  "EuropeanRoma_100-150", "IberianRoma_100-150",
                  "EuropeanRoma_150-250", "IberianRoma_150-250")

# Convert Population to a factor with specified order of levels
data$Population <- factor(data$Population, levels = order_levels)

# Create the box plot
pEUR <- ggplot(data, aes(x = Population, y = TractLength)) +
  geom_boxplot() +
  geom_point(position = position_dodge(width = 0), shape = 1, color = "black") +  # Use shape 1 for empty circles
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  labs(title = "Tract Length - European Ancestry",
       x = "Population_Category",
       y = "Tract Length")
pEUR

############################ South asia
min_length_SA <- min(length(european_lengthsSA_100_150),
                     length(european_lengthsSA_20_100),
                     length(iberian_lengthsSA_20_100),
                     length(european_lengthsSA_0.03_20),
                     length(iberian_lengthsSA_0.03_20))

# Combine the data into a single data frame
data_SA <- data.frame(
  TractLength = c(european_lengthsSA_150_250, iberian_lengthsSA_150_250, 
                  european_lengthsSA_100_150, iberian_lengthsSA_100_150, 
                  european_lengthsSA_20_100, iberian_lengthsSA_20_100, 
                  european_lengthsSA_0.03_20, iberian_lengthsSA_0.03_20),
  Population = rep(c("EuropeanRoma_150-250", "IberianRoma_150-250",
                     "EuropeanRoma_100-150", "IberianRoma_100-150",
                     "EuropeanRoma_20-100", "IberianRoma_20-100",
                     "EuropeanRoma_0.03-20", "IberianRoma_0.03-20"), each = min_length)
)

# Define the order of levels for the Population variable
order_levels_SA <- c("EuropeanRoma_0.03-20", "IberianRoma_0.03-20",
                     "EuropeanRoma_20-100", "IberianRoma_20-100",
                     "EuropeanRoma_100-150", "IberianRoma_100-150",
                     "EuropeanRoma_150-250", "IberianRoma_150-250")

# Convert Population to a factor with specified order of levels
data_SA$Population <- factor(data_SA$Population, levels = order_levels_SA)

# Create the box plot
p_SA <- ggplot(data_SA, aes(x = Population, y = TractLength)) +
  geom_boxplot() +
  geom_point(position = position_dodge(width = 0), shape = 1, color = "black") +  # Use shape 1 for empty circles
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  labs(title = "Tract Length - SouthAsian Ancestry",
       x = "Population_Category",
       y = "Tract Length")
p_SA

################################################ Alt

# Count the number of rows in each dataset
lengthsSA <- c(length(european_lengthsEUR_150_250), length(iberian_lengthsEUR_150_250),
             length(european_lengthsEUR_100_150), length(iberian_lengthsEUR_100_150),
             length(european_lengthsEUR_20_100), length(iberian_lengthsEUR_20_100),
             length(european_lengthsEUR_0.03_20), length(iberian_lengthsEUR_0.03_20))

european_lengthsSA_100_150 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "EuropeanRoma_1_100-150"]
european_lengthsSA_20_100 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "EuropeanRoma_1_20-100"]
iberian_lengthsSA_20_100 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "IberianRoma_1_20-100"]
european_lengthsSA_0.03_20 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "EuropeanRoma_1_0.03-20"]
iberian_lengthsSA_0.03_20 <- lai_category$TractLengths[lai_category$POP_Ancestry_Category == "IberianRoma_1_0.03-20"]

# Find the minimum length
min_length <- min(lengths)

# Sample the data to make them of the same length
european_lengthsEUR_150_250 <- sample(european_lengthsEUR_150_250, min_length)
iberian_lengthsEUR_150_250 <- sample(iberian_lengthsEUR_150_250, min_length)
european_lengthsEUR_100_150 <- sample(european_lengthsEUR_100_150, min_length)
iberian_lengthsEUR_100_150 <- sample(iberian_lengthsEUR_100_150, min_length)
european_lengthsEUR_20_100 <- sample(european_lengthsEUR_20_100, min_length)
iberian_lengthsEUR_20_100 <- sample(iberian_lengthsEUR_20_100, min_length)
european_lengthsEUR_0.03_20 <- sample(european_lengthsEUR_0.03_20, min_length)
iberian_lengthsEUR_0.03_20 <- sample(iberian_lengthsEUR_0.03_20, min_length)

# Combine the data into a single data frame
data <- data.frame(
  TractLength = c(european_lengthsEUR_150_250, iberian_lengthsEUR_150_250, 
                  european_lengthsEUR_100_150, iberian_lengthsEUR_100_150, 
                  european_lengthsEUR_20_100, iberian_lengthsEUR_20_100, 
                  european_lengthsEUR_0.03_20, iberian_lengthsEUR_0.03_20),
  Population = rep(c("EuropeanRoma_150-250", "IberianRoma_150-250",
                     "EuropeanRoma_100-150", "IberianRoma_100-150",
                     "EuropeanRoma_20-100", "IberianRoma_20-100",
                     "EuropeanRoma_0.03-20", "IberianRoma_0.03-20"), each = min_length)
)

# Define the order of levels for the Population variable
order_levels <- c("EuropeanRoma_0.03-20", "IberianRoma_0.03-20",
                  "EuropeanRoma_20-100", "IberianRoma_20-100",
                  "EuropeanRoma_100-150", "IberianRoma_100-150",
                  "EuropeanRoma_150-250", "IberianRoma_150-250")

# Convert Population to a factor with specified order of levels
data$Population <- factor(data$Population, levels = order_levels)

# Create the box plot
pEUR <- ggplot(data, aes(x = Population, y = TractLength)) +
  geom_boxplot() +
  geom_point(position = position_dodge(width = 0), shape = 1, color = "black") +  # Use shape 1 for empty circles
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  labs(title = "Tract Length - European Ancestry",
       x = "Population_Category",
       y = "Tract Length")
pEUR


# Perform Wilcoxon rank sum test
wilcox1 <- wilcox.test(european_lengths, iberian_lengths,
                       alternative = "two.sided", 
                       conf.int = TRUE)

wilcox2 <- wilcox.test(european_lengths1, iberian_lengths2,
                       alternative = "two.sided", 
                       conf.int = TRUE)
wilcox1
wilcox2

combined_wilcox <- as.data.frame(cbind(wilcox1, wilcox2))

combined_wilcox_df <- do.call(rbind, combined_wilcox)

write.table(combined_wilcox_df,file = "/home/bioevo/Desktop/Giacomo/LAI/totalAVG_wilctest.csv",sep = "\t")

