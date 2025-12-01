## Visualize result

library(tidyverse)

Direc = char(getwd())
Sample_name = substring(char(getwd()),130,150)

# set up ggplot theme
theme_set(theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()))

# Read data
S <- read.table('Output/Result.txt',header = TRUE) %>% tibble() %>%
  mutate(Size = as.numeric(Size))

# Calculate MIC
  S_mic <-
    S %>%
    mutate(Plate = paste0('Plate',Plate)) %>%
    select(Row.Label,Col,Plate,Size) %>%
    pivot_wider(id_cols = c(Row.Label,Col), names_from = Plate, values_from = Size) %>% # long to wide
    mutate(mic = ifelse(Plate10<0.05*Plate1,16,999)) %>%
    mutate(mic = ifelse(Plate9<0.05*Plate1,8,mic)) %>%
    mutate(mic = ifelse(Plate8<0.05*Plate1,4,mic)) %>%
    mutate(mic = ifelse(Plate7<0.05*Plate1,2,mic)) %>%
    mutate(mic = ifelse(Plate6<0.05*Plate1,1,mic)) %>%
    mutate(mic = ifelse(Plate5<0.05*Plate1,0.5,mic)) %>%
    mutate(mic = ifelse(Plate4<0.05*Plate1,0.25,mic)) %>%
    mutate(mic = ifelse(Plate3<0.05*Plate1,0.125,mic)) %>%
    mutate(mic = ifelse(Plate2<0.05*Plate1,0.0625,mic)) %>%
    mutate(mic = ifelse(Plate1<100,0,mic))

# Visualization
    # Colony size
    pdf('Output/Visualization.pdf',width = 7,height = 4)
    S %>%
      mutate(Well = paste0(Row.Label,Col)) %>%
      mutate(type = ifelse(Well=='A1'|Well=='A2'|Well=='A3'|
                             Well=='A4'|Well=='A5'|Well=='A6','Lab','Clinical')) %>%
      ggplot(aes(as.factor(Plate),sqrt(Size),col=type)) +
      # scale_x_discrete(limits = (0,0.0625,0.125,0.25,0.5,1,2,4,8,16)) +
      xlab('Plate number') +
      geom_point(alpha = 0.5, size=0.5,
                 position=position_jitterdodge(jitter.width = 0.1, dodge.width = 0.5)) +
      ggtitle(paste0('Colony size of ',Sample_name))
    # hist
    S_mic %>%
      select(Row.Label,Col,mic) %>%
      mutate(Well = paste0(Row.Label,Col)) %>%
      mutate(type = ifelse(Well=='A1'|Well=='A2'|Well=='A3'|
                             Well=='A4'|Well=='A5'|Well=='A6','Lab','Clinical')) %>%
      filter(type == 'Clinical') %>%
      ggplot(aes(mic)) +
      geom_histogram(binwidth=0.0625) +
      xlab('MIC') +
      scale_x_continuous(breaks = c(0,0.0625,0.125,0.25,0.5,1,2,4,8,16), limits = c(0,16)) +
      theme(axis.text.x = element_text(angle = 45,hjust = 1)) +
      ggtitle(paste0('Histegram of MIC of ',Sample_name))
    # plot mic
    S_mic %>%
      select(Row.Label,Col,mic) %>%
      mutate(Well = paste0(Row.Label,Col)) %>%
      mutate(type = ifelse(Well=='A1'|Well=='A2'|Well=='A3'|
                             Well=='A4'|Well=='A5'|Well=='A6','Lab','Clinical')) %>%
      ggplot(aes(as.factor(mic),Row.Label,col = type)) +
      scale_y_discrete(limits = c('H','G','F','E','D','C','B','A')) +
      geom_jitter(width = 0.25)
    # microplate graph
        library(ggforce)
        # create a function
        ggmicroplate <- function(sample =Sample_name){
          temp <- filter(S_mic %>% mutate(Sample =Sample_name),Sample == sample ) %>%
            mutate(fillcol=ifelse(mic == 999,50,mic))
          letter2numb <- LETTERS[1:26] # create a function for transfer letter into number
          p <- ggplot(data = temp) +
            geom_circle(aes(x0 = as.integer(Col), y0 = match(Row.Label,letter2numb),
                            r = 0.45, fill = fillcol))
          p <- p + coord_equal() # fixed smashed well
          # fixed the scale and order of layout
          library(scales)
          p <- p +
            scale_x_continuous(breaks = 1:12, expand = expansion(mult = c(0.01, 0.01))) +
            scale_y_continuous(breaks = 1:8, labels = LETTERS[1:8], expand = expansion(mult = c(0.01, 0.01)), trans = reverse_trans())
          p
          # fix grids
          p <- p +
            scale_fill_gradient(low = "white", high = "Orange") +
            labs(title = paste0("MIC of ",Sample_name,' Plate'), subtitle = sample, x = "Col", y = "Row") +
            theme_bw() +
            theme(panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  legend.position = "none")
          p
          # add mic as text
          p <- p + geom_text(aes(x = as.integer(Col), y = match(Row.Label,letter2numb), label = paste0(mic)), size = 3)
          p }
        ggmicroplate()
        dev.off()
