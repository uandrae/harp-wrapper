library(harpVis)

scores <- c("bias","rmse")

params          <- c("Pmsl","T2m","S10m","RH2m",
                     "CCtot","CClow","Cbase",
                     "Gmax","Td2m","Tmax","Tmin",
                     "AccPcp3h","AccPcp6h","AccPcp12h")

member_colours = data.frame(
  member = paste0("mbr", formatC(seq(0, 7), width = 3, flag = "0")),
  colour = c("#EC5581", rep("grey", 7))
)

for ( param in params ) {
 print (param)

 fname <- paste("/scratch/ms/se/snh/harp/VERTABLE_MCP/harpPointVerif.harp",param,"harp.2019020100-2019021400.harp.CY40h111.model.CY43b7_2.rds",sep=".")
 print (fname)
 verif <- readRDS(fname)

 for ( score in scores ) {

  score_sym <- rlang::sym(score)

  pname <- paste("/scratch/ms/se/snh/harp/VERTABLE_MCP/",score,"_",param,".png",sep="")
  print (pname)

  plot_point_verif(extend_y_to_zero=FALSE,
   verif, score=!!score_sym, facet_by = vars(mname), colour_by = member,
   verif_type = "det", legend_position = "none", colour_table = member_colours)
  ggsave( pname)

 }
}

