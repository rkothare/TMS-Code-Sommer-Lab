%%Bootstrap modeling of the data.
clear

%Load the data
[filename, pathname]=uigetfile('*.mat')%'oxford_2014.mat';
load([pathname filename])

%Load the values.
pvalue=.05/1000;

ta=400;
crop = (tbase+1)-50:(tbase+1)+ta;
compcrop = (tbase+1):(tbase+1)+ta;
Trunk=3+gauss_size:size(shamps,2)-gauss_size;

wStimSub=stimps(stimps(:,2)<=50,Trunk);
wStimSup=stimps(stimps(:,2)>50,Trunk);
wShamSub=shamps(shamps(:,2)<=50,Trunk);
wShamSup=shamps(shamps(:,2)>50,Trunk);

%Run the bootstrap

N=10000; %Number of bootstraps to run
cint=95; %Confidence interval given in a percent

allSup=[wStimSup; wShamSup];
allSub=[wStimSub; wShamSub];

allStim=[wStimSub; wStimSup];
allSham=[wShamSub; wShamSup];

for n=1:N
    %Randomly Choose Between Stim vs Sham
    bootStSup(:,n)=randsample(size(allSup,1),size(wStimSup,1),true);
    bootStSub(:,n)=randsample(size(allSub,1),size(wStimSub,1),true);
    bootShSup(:,n)=randsample(size(allSup,1),size(wShamSup,1),true);
    bootShSub(:,n)=randsample(size(allSub,1),size(wShamSub,1),true);
    
    avgBtStSup(n,:)=mean(allSup(bootStSup(:,n),:));
    avgBtStSub(n,:)=mean(allSub(bootStSub(:,n),:));
    avgBtShSup(n,:)=mean(allSup(bootShSup(:,n),:));
    avgBtShSub(n,:)=mean(allSub(bootShSub(:,n),:));
    
    %Randomly Choose Between Sup and Sub
    bootSupSt(:,n)=randsample(size(allStim,1),size(wStimSup,1),true);
    bootSubSt(:,n)=randsample(size(allStim,1),size(wStimSub,1),true);
    bootSupSh(:,n)=randsample(size(allSham,1),size(wShamSup,1),true);
    bootSubSh(:,n)=randsample(size(allSham,1),size(wShamSub,1),true);
    
    avgBtSupSh(n,:)=mean(allSham(bootSupSh(:,n),:));
    avgBtSubSh(n,:)=mean(allSham(bootSubSh(:,n),:));
    avgBtSupSt(n,:)=mean(allStim(bootSupSt(:,n),:));
    avgBtSubSt(n,:)=mean(allStim(bootSubSt(:,n),:));
    
   
    diffBtSup(n,:)=avgBtStSup(n,:)-avgBtShSup(n,:);
    diffBtSub(n,:)=avgBtStSub(n,:)-avgBtShSub(n,:);
    diffSham(n,:)=avgBtSupSh(n,:)-avgBtSubSh(n,:);
    diffStim(n,:)=avgBtSupSt(n,:)-avgBtSubSt(n,:);
end

%Calculate the confidence interval at each time point for all the values
for k=1:size(wStimSup,2)
    savgBtStSup=sort(avgBtStSup(:,k));
    savgBtStSub=sort(avgBtStSub(:,k));
    savgBtShSup=sort(avgBtShSup(:,k));
    savgBtShSub=sort(avgBtShSub(:,k));
    
    sdiffBtSup=sort(diffBtSup(:,k));
    sdiffBtSub=sort(diffSham(:,k));
    sdiffSham=sort(diffSham(:,k));
    sdiffStim=sort(diffStim(:,k));
    
    %ciStSup(k,:)=savgBtStSup([floor(N*(1-cint/100)) ceil(cint*N/100)]);
    ciStSup(k)=savgBtStSup(ceil(cint*N/100));
    ciStSub(k)=savgBtStSub(ceil(cint*N/100));
    ciShSup(k)=savgBtShSup(ceil(cint*N/100));
    ciShSub(k)=savgBtShSup(ceil(cint*N/100));
    cidiffSup(k)=sdiffBtSup(ceil(cint*N/100));
    cidiffSub(k)=sdiffBtSub(ceil(cint*N/100));
    cidiffSham(k)=sdiffSham(ceil(cint*N/100));
    cidiffStim(k)=sdiffStim(ceil(cint*N/100));
end

figure;
subplot(2,2,1)
hold on
%plot_variance(time,mean(avgBtStSup)-ciStSup,mean(avgBtStSup)+ciStSup,[0 .75 1])
%plot_variance(time,mean(avgBtShSup)-ciStSup,mean(avgBtShSup)+ciStSup,[1 .75 0])
plot_variance(time(crop),mean(diffBtSup(:,crop))-cidiffSup(crop),mean(diffBtSup(:,crop))+cidiffSup(crop),[.5 .5 .5])
plot(time(crop),mean(avgBtStSup(:,crop)),'b',time(crop),mean(avgBtShSup(:,crop)),'r',time(crop),mean(diffBtSup(:,crop)),'k')
xlim([time(crop(1)) time(crop(end))])
title('Suprathreshold')

subplot(2,2,2)
plot_variance(time(crop),mean(diffBtSub(:,crop))-cidiffSub(crop),mean(diffBtSub(:,crop))+cidiffSub(crop),[.5 .5 .5])
hold on
plot(time(crop),mean(avgBtStSub(:,crop)),'c',time(crop),mean(avgBtShSub(:,crop)),'m',time(crop),mean(diffBtSub(:,crop)),'k')
xlim([time(crop(1)) time(crop(end))])
title('Subthreshold')

subplot(2,2,3)
plot_variance(time(crop),mean(diffSham(:,crop))-cidiffSham(crop),mean(diffSham(:,crop))+cidiffSham(crop),[.5 .5 .5])
hold on
plot(time(crop),mean(avgBtSubSh(:,crop)),'c',time(crop),mean(avgBtSupSh(:,crop)),'m',time(crop),mean(diffSham(:,crop)),'k')
xlim([time(crop(1)) time(crop(end))])
title('Sham')

subplot(2,2,4)
plot_variance(time(crop),mean(diffStim(:,crop))-cidiffStim(crop),mean(diffStim(:,crop))+cidiffStim(crop),[.5 .5 .5])
hold on
plot(time(crop),mean(avgBtSubSt(:,crop)),'c',time(crop),mean(avgBtSupSt(:,crop)),'m',time(crop),mean(diffStim(:,crop)),'k')
xlim([time(crop(1)) time(crop(end))])
title('Stim')
% figure;
% subplot(2,1,1)
% plot(time,avgBtStSup,'b',time,avgBtShSup,'r',time,diffBtSup,'k')
% title('Subthreshold')
% subplot(2,1,2)
% plot(time,avgBtStSub,'c',time,avgBtShSub,'m',time,diffBtSub,'k')
% title('Subthreshold')