
library(lattice);library(doBy); library(lubridate)
library(minpack.lm); library(effects); library(nlme)
library(MuMIn); library(car)
library(sjPlot)
library(lattice);library(doBy); library(lubridate)
library(minpack.lm); library(plotrix)

rm(list=ls()); dev.off(); cat("\f") # ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

# setwd("F:/CSU/JSG 2022/files for analysis")
setwd("/Volumes/The Hive/CSU/BADDIE/ENV/SM")
# env<-read.csv("SM Master 9.12.csv")
# # env$SVP_kPa<-(610.78*(2.71828^(env$Temperature/(env$Temperature+238.3)*17.2694)))/1000
# # env$VPD_kPa<-env$SVP_kPa * (1- (env$RH/100))
# env$Date<-as.Date(env$Date, format = "%m/%d/%Y")
# 

# 
# # write.csv(env2, "Daily SM means JSG 2022.csv")
# env2$plot1pro<-(env2$plot1.mean-env2$plot1.15.mean)+ env2$plot1
env2<-read.csv("BADDIE SM Master.3.csv")
env2$Date<-as.Date(env2$Date, format = "%m/%d/%Y")

env2$beneath.master<-(env2$beneath.15+env2$beneath.15.1)/2
env2$east.master<-(env2$east.15+env2$east.15.1)/2
env2$between.master<-(env2$between.15+env2$between.15.1)/2
env2$west.master<-(env2$west.15+env2$west.15.1)/2

# 
# gsmplot1.15<-mean(env2$plot1.mean, env2)
# gsmplot1.30

# pdf(paste("JSG 2022 SM depths comparison.pdf"))
tiff(file = "BADDIE split SM.tiff", height = 8, width = 12, res = 600, units = "in", compression = "zip+p")
par(mfrow = c(1,1), omi = c(0.8, 1.5, 0.1, 0.1), mar = c(1,1,0.2,1))


# plotCI(env2$Date, env2$plot2.15.mean , env2$plot2.15.std.error*0, sfrac = 0,
#        xaxt="n",yaxt="n",xlab="",ylab="",pch=NA, col = "black", ylim = c(0.20,0.48))


plot(env2$beneath ~ env2$Date, env2, pch = NA, col = "white" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")


#########

par(new=T)
plot(env2$beneath.15 ~ env2$Date, env2, pch = 1, col = "aquamarine3" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
points(env2$beneath.15  ~ env2$Date, type = "l", col = "aquamarine3", lty = 2, lwd = 3)
par(new=T)
plot(env2$beneath.15.1 ~ env2$Date, env2, pch = 19, col = "aquamarine3" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
points(env2$beneath.15.1  ~ env2$Date, type = "l", col = "aquamarine3", lty = 1, lwd = 3)

# par(new=T)
# plot(env2$beneath.master ~ env2$Date, env2, pch = NA, col = "aquamarine3" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
# points(env2$beneath.master  ~ env2$Date, type = "l", col = "aquamarine3", lty = 1, lwd = 4)
#########

par(new=T)
plot(env2$east.15 ~ env2$Date, env2, pch = NA, col = "cornflowerblue" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
points(env2$east.15  ~ env2$Date, type = "l", col = "cornflowerblue", lty = 2, lwd = 4)
par(new=T)
plot(env2$east.15.1 ~ env2$Date, env2, pch = NA, col = "cornflowerblue" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
points(env2$east.15.1  ~ env2$Date, type = "l", col = "cornflowerblue", lty = 1, lwd = 4)
# 
# par(new=T)
# plot(env2$east.master ~ env2$Date, env2, pch = NA, col = "cornflowerblue" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
# points(env2$east.master  ~ env2$Date, type = "l", col = "cornflowerblue", lty = 1, lwd = 4)
##########


par(new=T)
plot(env2$between.15 ~ env2$Date, env2, pch = NA, col = "grey69" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
points(env2$between.15  ~ env2$Date, type = "l", col = "grey69", lty = 2, lwd = 4)
par(new=T)
plot(env2$between.15.1 ~ env2$Date, env2, pch = NA, col = "grey69" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
points(env2$between.15.1  ~ env2$Date, type = "l", col = "grey69", lty = 1, lwd = 4)

# par(new=T)
# plot(env2$between.master ~ env2$Date, env2, pch = NA, col = "grey69" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
# points(env2$between.master  ~ env2$Date, type = "l", col = "grey69", lty = 1, lwd = 4)
#########


par(new=T)
plot(env2$west.15.1 ~ env2$Date, env2, pch = NA, col = "indianred4" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
points(env2$west.15.1  ~ env2$Date, type = "l", col = "indianred4", lty = 2, lwd = 3)
par(new=T)
plot(env2$west ~ env2$Date, env2, pch = NA, col = "indianred4" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
points(env2$west  ~ env2$Date, type = "l", col = "indianred4", lty = 1, lwd = 3)

# par(new=T)
# plot(env2$west.master ~ env2$Date, env2, pch = NA, col = "indianred4" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
# points(env2$west.master  ~ env2$Date, type = "l", col = "indianred4", lty = 1, lwd = 4)
##########

par(new=T)
plot(env2$control15 ~ env2$Date, env2, pch = NA, col = "black" , ylim = c(0.20,0.60), xaxt="n",yaxt="n",xlab="",ylab="")
points(env2$control15  ~ env2$Date, type = "l", col = "black", lty = 2, lwd = 4)

# legend("bottom", c("0-15cm"), col=c("NA"), cex = 3, horiz = F, bty='n')

legend("topleft", c("Control","Beneath", "Between","East Edge","West Edge"), col=c("black","aquamarine3","grey69","cornflowerblue","indianred4"), pch= c(NA), lty = c(2,1,1,1,1), lwd = 4,cex = 1.6, horiz = F, bty='n')
# legend("topleft", c("15cm", "30cm"), col=c("gray"), pch= c(1,16), lty = c(2,1), cex = 2, horiz = F, bty='n')
axis(2, at = seq(0.20,0.60,0.05), las = 2, cex.axis = 1.8, labels = T)
mtext(side = 2, expression("0-15cm Soil Moisture (%)"), cex = 2, padj = -2.2, outer= T)

axis.Date(1, env2$Date, at = seq(min(env2$Date, na.rm = T), max(env2$Date, na.rm = T),"week"), las = 1, cex.axis = 1.2, labels = T)
mtext(side = 1, expression("Date"), cex = 2, padj = 2, outer= T)
######################
dev.off()


