fname = ".\data\2d_5s1k5k10k_5ki.json";
nfname = ".\data\2d_5s1k5k10k_5ki_nocontrol.json";

fid = fopen(fname);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
val = jsondecode(jsondecode(str));

nfid = fopen(nfname);
nraw = fread(nfid,inf);
nstr = char(nraw');
fclose(nfid);
nval = jsondecode(jsondecode(nstr));

int500 = reshape(nval.intruder(1,:,:),[100,3]);
int1000 = reshape(nval.intruder(2,:,:),[100,3]);
int5000 = reshape(nval.intruder(3,:,:),[100,3]);
int10000 = reshape(nval.intruder(4,:,:),[100,3]);

ndist500 = vecnorm(nval.sat-int500,2,2);
ndist1000 = vecnorm(nval.sat-int1000,2,2);
ndist5000 = vecnorm(nval.sat-int5000,2,2);
ndist10000 = vecnorm(nval.sat-int10000,2,2);

dist500 = vecnorm(val.sat(1:100,:)-int500,2,2);
dist1000 = vecnorm(val.sat(1:100,:)-int1000,2,2);
dist5000 = vecnorm(val.sat(1:100,:)-int5000,2,2);
dist10000 = vecnorm(val.sat(1:100,:)-int10000,2,2);


figure
plot([0:length(ndist500)-1]*100,ndist500)
hold on
plot([0:length(ndist1000)-1]*100,ndist1000)
plot([0:length(ndist5000)-1]*100,ndist5000)
plot([0:length(ndist10000)-1]*100,ndist10000)
legend(["Intruder 1","Intruder 2","Intruder 3","Intruder 4"])
title("Distance between Satellites: No control")
xlabel("time")
ylabel("distance (m)")

figure

plot([0:length(dist500)-1]*100,dist500)
hold on
plot([0:length(dist1000)-1]*100,dist1000)
plot([0:length(dist5000)-1]*100,dist5000)
plot([0:length(dist10000)-1]*100,dist10000)
legend(["Intruder 1","Intruder 2","Intruder 3","Intruder 4"])
title("Distance between Satellites: MCTS Control")
xlabel("time")
ylabel("distance (m)")
figure
plot( [0:length(ndist1000)-1]*100,min([ndist500,ndist1000,ndist5000,ndist10000],[],2))
hold on
plot( [0:length(ndist1000)-1]*100,min([dist500,dist1000,dist5000,dist10000],[],2))
legend(["No Control","MCTS Control"])
title("Method Comparison: Dist to Nearest Satellite")
xlabel("time")
ylabel("distance (m)")




