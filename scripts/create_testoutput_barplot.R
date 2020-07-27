
library(ggplot2)

data <- data.frame(val=factor(c("FALSE1","FALSE2","TRUE1","TRUE2"), levels=c("TRUE1","FALSE2","FALSE1","TRUE2")),
           pred=factor(c("TRUE","FALSE","FALSE","TRUE")),
           value=c(26,479,2,503),
           rect=c(-.5,1.5,-.5,1.5)           )

rect <- data.frame(x=)

# ggplot(data, aes(x=val,y=pred,size=value,color=pred,)) +
#   geom_tile(data=data, aes(x=val,y=pred,size=rect,fill=val,color=NA,alpha=0.2)) +
#   geom_point() +
#   geom_text(aes(label=value, size=10,color="z"),hjust=.5, vjust=.5) +
#   scale_size_area(max_size=30) +
#   #theme +
#   theme(
#     axis.text.y=element_text(face="bold",angle=90),
#     axis.text.x=element_text(face="bold"),
#     axis.ticks = element_blank(),
#     
#     legend.position = "none",
#     panel.background = element_blank()
#   ) +  scale_color_manual(values=c("firebrick3","deepskyblue3","black")) +
#   scale_fill_manual(values=c("firebrick1","deepskyblue1")) +
#   scale_x_discrete(position = "top") +
#   geom_hline(yintercept = 1.5,) +
#   geom_vline(xintercept = 1.5) +
#   xlab("Validation") +
#   ylab("Prediction")

ggplot(data, aes(x=pred, y=value, fill=val, label=value)) +
  geom_bar(stat="identity") +
  scale_fill_manual(name = "Label", values=c("firebrick1","firebrick3","deepskyblue1","deepskyblue3"), labels=c("FN","TN","FP","TP")) +
  theme(
    axis.text.y=element_text(face="bold"),
    axis.text.x=element_text(face="bold"),
    axis.ticks.x = element_blank(),
    panel.background = element_blank()
  ) +
  xlab("Prediction") +
  ylab("Number of SV's") +
  geom_text(position = "stack", aes(vjust=rect))