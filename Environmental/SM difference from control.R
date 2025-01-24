
library(lattice);library(doBy); library(lubridate)
library(minpack.lm); library(effects); library(nlme)
library(MuMIn); library(car)
library(sjPlot)
library(lattice);library(doBy); library(lubridate)
library(minpack.lm); library(plotrix)

rm(list=ls()); dev.off(); cat("\f") # ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

# setwd("F:/CSU/JSG 2022/files for analysis")
setwd("C:\\Users\\jasig\\OneDrive - Colostate\\Documents\\My Projects\\BADDIE")
# env<-read.csv("SM Master 9.12.csv")
# # env$SVP_kPa<-(610.78*(2.71828^(env$Temperature/(env$Temperature+238.3)*17.2694)))/1000
# # env$VPD_kPa<-env$SVP_kPa * (1- (env$RH/100))
# env$Date<-as.Date(env$Date, format = "%m/%d/%Y")
# 

# 
# # write.csv(env2, "Daily SM means JSG 2022.csv")
# env2$plot1pro<-(env2$plot1.mean-env2$plot1.15.mean)+ env2$plot1
env2<-read.csv("BADDIE SM Master.4diff.csv")
env2$Date<-as.Date(env2$Date, format = "%m/%d/%Y")

env2$beneath.master<-(env2$beneath.15+env2$beneath.15.1)/2
env2$east.master<-(env2$east.15+env2$east.15.1)/2
env2$between.master<-(env2$between.15+env2$between.15.1)/2
env2$west.master<-(env2$west.15+env2$west.15.1)/2

# 
# gsmplot1.15<-mean(env2$plot1.mean, env2)
# gsmplot

dailywestdiff<-summaryBy(westdiff~Date, FUN = c(min, mean, max), na.rm = T, env2)
dailyeastdiff<-summaryBy(eastdiff~Date, FUN = c(min, mean, max), na.rm = T, env2)
dailybeneathdiff<-summaryBy(beneathdiff~Date, FUN = c(min, mean, max), na.rm = T, env2)
dailybetweendiff<-summaryBy(betweendiff~Date, FUN = c(min, mean, max), na.rm = T, env2)


# pdf(paste("JSG 2022 SM depths comparison.pdf"))
tiff(file = "BADDIE SM diff from control.tiff", height = 8, width = 12, res = 600, units = "in", compression = "zip+p")
par(mfrow = c(1,1), omi = c(0.8, 1.5, 0.1, 0.1), mar = c(1,1,0.2,1))


# plotCI(env2$Date, env2$plot2.15.mean , env2$plot2.15.std.error*0, sfrac = 0,
#        xaxt="n",yaxt="n",xlab="",ylab="",pch=NA, col = "black", ylim = c(0.20,0.48))


plot(env2$beneath ~ env2$Date, env2, pch = NA, col = "white" , ylim = c(-0.20,0.20), xaxt="n",yaxt="n",xlab="",ylab="")

abline(h=0, col = "black", lwd = 5, lty = 1)
box()

rect(xleft = as.Date("0023-06-12"), xright = as.Date("0023-06-14"), ybottom = -999, ytop = 999, col = "grey80", bty = "n", border = F)
rect(xleft = as.Date("0023-08-03"), xright = as.Date("0023-08-05"), ybottom = -999, ytop = 999, col = "grey80", bty = "n", border = F)
rect(xleft = as.Date("0023-06-24"), xright = as.Date("0023-06-25"), ybottom = -999, ytop = 999, col = "skyblue", bty = "n", border = F)
rect(xleft = as.Date("0023-07-09"), xright = as.Date("0023-07-10"), ybottom = -999, ytop = 999, col = "skyblue", bty = "n", border = F)
rect(xleft = as.Date("0023-07-21"), xright = as.Date("0023-07-22"), ybottom = -999, ytop = 999, col = "skyblue", bty = "n", border = F)
rect(xleft = as.Date("0023-07-31"), xright = as.Date("0023-08-01"), ybottom = -999, ytop = 999, col = "skyblue", bty = "n", border = F)
box()


par(new=T)
plot(dailybeneathdiff$beneathdiff.max ~ dailybeneathdiff$Date, dailybeneathdiff, pch = 1, col = "aquamarine3" , ylim = c(-0.20,0.20), xaxt="n",yaxt="n",xlab="",ylab="")
points(dailybeneathdiff$beneathdiff.max  ~ dailybeneathdiff$Date, type = "l", col = "aquamarine3", lty = 1, lwd = 3)


# par(new=T)
# plot(env2$beneath.master ~ env2$Date, env2, pch = NA, col = "aquamarine3" , ylim = c(-0.20,0.20), xaxt="n",yaxt="n",xlab="",ylab="")
# points(env2$beneath.master  ~ env2$Date, type = "l", col = "aquamarine3", lty = 1, lwd = 4)
#########

par(new=T)
plot(dailyeastdiff$eastdiff.max ~ dailyeastdiff$Date, dailyeastdiff, pch = 1, col = "cornflowerblue" , ylim = c(-0.20,0.20), xaxt="n",yaxt="n",xlab="",ylab="")
points(dailyeastdiff$eastdiff.max  ~ dailyeastdiff$Date, type = "l", col = "cornflowerblue", lty = 1, lwd = 4)
# 
# par(new=T)
# plot(env2$east.master ~ env2$Date, env2, pch = NA, col = "cornflowerblue" , ylim = c(-0.20,0.20), xaxt="n",yaxt="n",xlab="",ylab="")
# points(env2$east.master  ~ env2$Date, type = "l", col = "cornflowerblue", lty = 1, lwd = 4)
##########


par(new=T)
plot(dailybetweendiff$betweendiff.max ~ dailybetweendiff$Date, dailybetweendiff, pch = 1, col = "grey69" , ylim = c(-0.20,0.20), xaxt="n",yaxt="n",xlab="",ylab="")
points(dailybetweendiff$betweendiff.max  ~ dailybetweendiff$Date, type = "l", col = "grey69", lty = 1, lwd = 4)


# par(new=T)
# plot(env2$between.master ~ env2$Date, env2, pch = NA, col = "grey69" , ylim = c(-0.20,0.20), xaxt="n",yaxt="n",xlab="",ylab="")
# points(env2$between.master  ~ env2$Date, type = "l", col = "grey69", lty = 1, lwd = 4)
#########


par(new=T)
plot(dailywestdiff$westdiff.max ~ dailywestdiff$Date, dailywestdiff, pch = 1, col = "indianred4" , ylim = c(-0.20,0.20), xaxt="n",yaxt="n",xlab="",ylab="")
points(dailywestdiff$westdiff.max  ~ dailywestdiff$Date, type = "l", col = "indianred4", lty = 1, lwd = 3)

# par(new=T)
# plot(env2$west.master ~ env2$Date, env2, pch = NA, col = "indianred4" , ylim = c(-0.20,0.20), xaxt="n",yaxt="n",xlab="",ylab="")
# points(env2$west.master  ~ env2$Date, type = "l", col = "indianred4", lty = 1, lwd = 4)
##########


# legend("bottom", c("0-15cm"), col=c("NA"), cex = 3, horiz = F, bty='n')

legend("bottomleft", c("Control","Beneath", "Between","East Edge","West Edge"), col=c("black","aquamarine3","grey69","cornflowerblue","indianred4"), pch= c(NA), lty = c(1,1,1,1,1), lwd = 4,cex = 1.6, horiz = F, bty='n')
# legend("topleft", c("15cm", "30cm"), col=c("gray"), pch= c(1,16), lty = c(2,1), cex = 2, horiz = F, bty='n')
axis(2, at = seq(-0.20,0.20,0.05), las = 2, cex.axis = 1.8, labels = T)
mtext(side = 2, expression("Soil Moisture difference from control (%)"), cex = 2, padj = -2.2, outer= T)

axis.Date(1, env2$Date, at = seq(min(env2$Date, na.rm = T), max(env2$Date, na.rm = T),"month"), las = 1, cex.axis = 2, labels = T)
######################
dev.off()


