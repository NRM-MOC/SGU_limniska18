library(tidyverse)
library(readxl)
library(MoCiS2) # devtools::install_github("NRM-MOC/MoCiS2")

# Cleans table of biodata to extract columns: PROV_KOD_ORIGINAL PROVTAG_DAT TOTV TOTL   ALDR ANTAL_DAGAR KON
biodata <- read_excel("data/limniska 18 bio data v2.xlsx", guess_max = 100000) %>% 
  select(PROV_KOD_ORIGINAL = `A ID`, PROVTAG_DAT = "Dödsdatum från", PROVTAG_DAT2 = "Dödsdatum till", Kön, 
         TOTV = Vikt, TOTL = Totallängd, ALDR = `Ålder från`) %>% 
  mutate(PROVTAG_DAT2 = as.Date(PROVTAG_DAT2),
         PROVTAG_DAT = as.Date(PROVTAG_DAT),
         ANTAL_DAGAR = 1,
         # ANTAL_DAGAR = as.numeric(PROVTAG_DAT2-PROVTAG_DAT),
         KON = case_when(Kön == "Hane" ~ "M",
                         Kön == "Hona" ~ "F"),
         TOTV = as.numeric(TOTV),
         TOTL = as.numeric(TOTL),
         ALDR = as.numeric(ALDR)) %>% 
  select(-Kön, -PROVTAG_DAT2)




metaller <- moc_read_lab("data/Metals_Limnic 2019_2018 prover_ACES.xlsm")
bromerade_UMU <- moc_read_lab("data/BFRs_Limnic 2019_2018 prover_UMU.xlsm")
bromerade_ACES <- moc_read_lab("data/BFRs_Limnic2019_2018ÅrsProver_200422.xlsm")
klorerade_UMU <- moc_read_lab("data/CLCs_Limnic 2019_2018 prover_UMU.xlsm")
klorerade_ACES <- moc_read_lab("data/CLCs_Limnic2019_2018ÅrsProver_200408.xlsm")
dioxiner_UMU <- moc_read_lab("data/Dioxins_Limnic 2019_2018 prover_UMU_NRM_20191018.xlsm")
dioxiner_SLV <- moc_read_lab("data/Dioxins_Limnic 2019_2018 prover_SLV.xlsm")
hg <- moc_read_lab("data/Hg_Limnic 2019_2018 prover_ACES.xlsm")
pfas <- moc_read_lab("data/PFASs_Limnic 2019_2018 prover_ACES.xlsm")
sia <- moc_read_lab("data/SI_Limnic 2019_2018 prover_ACES_MS added TPRC 200508.xlsm")



analysdata <- bind_rows(metaller, 
                        bromerade_UMU,
                        bromerade_ACES, 
                        klorerade_UMU, 
                        klorerade_ACES, 
                        dioxiner_UMU, 
                        dioxiner_SLV, 
                        hg, 
                        pfas, 
                        sia) %>% 
  mutate(PROV_KOD_ORIGINAL = ifelse(PROV_KOD_ORIGINAL == "C2018/01400-00411", "C2018/01400-01411", PROV_KOD_ORIGINAL))

SGU <- moc_join_SGU(biodata, analysdata)

moc_write_SGU(SGU, sheet = "PROVMETADATA", file = "limniska18_PROVMETADATA.xlsx", program = "limn")
moc_write_SGU(SGU, sheet = "PROVDATA_BIOTA", file =  "limniska18_PROVDATA_BIOTA.xlsx", program = "limn")
moc_write_SGU(SGU, sheet = "DATA_MATVARDE", file = "limniska18_DATA_MATVARDE.xlsx", program = "limn")
