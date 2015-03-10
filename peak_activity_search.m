%% Find the peak value immediately following the TMS pulse.
thres=0.01;
thresnorm=0.1;
bin_size=6;
endpt=500; 

% Calculate the values for all the peaks following the TMS pulse
% timeVal: Times at which peaks occur
% peakVal: values of peaks when they occur
for n=1:size(allptsh,1)
    [peak,time]=findpeaks(allptsh(n,3+tbase+gauss_size:end-gauss_size),'MinPeakHeight',thres);
    [pnorm,tnorm]=findpeaks(normptsh(n,3+tbase+gauss_size:end-gauss_size),'MinPeakHeight',thresnorm);
    if size(time,2)>0
        peakVal(n,1)=peak(1);
        timeVal(n,1)=time(1);
    else
        peakVal(n,1)=nan;
        timeVal(n,1)=nan;
    end
    
    if size(tnorm,2)>0
        peakVal(n,2)=pnorm(1);
        timeVal(n,2)=tnorm(1);
    else
        peakVal(n,2)=nan;
        timeVal(n,2)=nan;
    end
end

%Determine the histogram distribution for the stim files
[StBin,timeSt]=hist(timeVal(pSt,1),0:bin_size:endpt);
[StnormBin,tnormSt]=hist(timeVal(pSt,2),0:bin_size:endpt);
%Determine the histogram distribution for the sham files
[ShBin,timeSh]=hist(timeVal(pSh,1),0:bin_size:endpt);
[ShnormBin,tnormSh]=hist(timeVal(pSh,2),0:bin_size:endpt);

figure
subplot(2,1,1)
% plot(timeSt,StBin,'bo-',timeSh,ShBin,'go-')
% legend('Stim','Sham')
% subplot(2,1,2)
plot(tnormSt,StnormBin,'bo-',tnormSh,ShnormBin,'go-')
legend('Stim Normalized','Sham Normalized')
xlim([0 200])
subplot(2,1,2)
plot(tnormSt,StnormBin/sum(StnormBin),'bo-',...
    tnormSh,ShnormBin/sum(ShnormBin),'go-')
legend('Stim Normalized','Sham Normalized')
xlim([0 200])

% intenSt=figure;
intenN=figure;
% intenSt2=figure;
intenN2=figure;
for n=1:9
    posSt=find(stimps(:,2)<=n*10 & stimps(:,2)>10*(n-1));
    posSh=find(shamps(:,2)<=n*10 & shamps(:,2)>10*(n-1));
    %Determine the histogram distribution for the stim files
    [StBin(n,:),timeSt(n,:)]=hist(timeVal(posSt,1),0:bin_size:endpt);
    [StnormBin(n,:),tnormSt(n,:)]=hist(timeVal(posSt,2),0:bin_size:endpt);
    %Determine the histogram distribution for the sham files
    [ShBin(n,:),timeSh(n,:)]=hist(timeVal(posSh,1),0:bin_size:endpt);
    [ShnormBin(n,:),tnormSh(n,:)]=hist(timeVal(posSh,2),0:bin_size:endpt);
    % figure(intenSt)
    % subplot(3,3,n)
    % plot(timeSt(n,:),StBin(n,:),'bo-',timeSh(n,:),ShBin(n,:),'go-')
    % title([num2str(n*10) '% Stim'])
    % %xlim([0 150])
    figure(intenN)
    subplot(3,3,n)
    plot(tnormSt(n,:),StnormBin(n,:),'bo-',tnormSh(n,:),ShnormBin(n,:),'go-')
    title([num2str(n*10) '% Stim Normalized'])
    xlim([0 200])
    % figure(intenSt2)
    % subplot(3,3,n)
    % plot(timeSt(n,:),StBin(n,:)/sum(StBin(n,:)),'bo-',...
    %     timeSh(n,:),ShBin(n,:)/sum(ShBin(n,:)),'go-')
    % title([num2str(n*10) '% Stim Percentage'])
    xlim([0 200])
    figure(intenN2)
    subplot(3,3,n)
    plot(tnormSt(n,:),StnormBin(n,:)/sum(StnormBin(n,:)),...
        'bo-',tnormSh(n,:),ShnormBin(n,:)/sum(ShnormBin(n,:)),'go-')
    title([num2str(n*10) '% Stim Normalized Percentage'])
    xlim([0 200])
end

%% nANOVA for binned values across: time, Intensity, and type
% 3 dim matrix with all values.
%   1: Intensity
%   2: Times
%   3: Stim/Sham
dataAnova(:,:,1) = StnormBin;
dataAnova(:,:,2) = ShnormBin;

% Anova Parameters
gInt = 10:10:90;
gTimes = 0:6:498;
gType = 0:1;

% Vectorize Anova
dataAnovaVector = [];
dataAnovaVectorInd = 1;
gIntVector = [];
gTimesVector = [];
gTypeVector = [];

% Vectorize
for i = 1:size(dataAnova,3)
    for j = 1:size(dataAnova,2)
        for k = 1:size(dataAnova,1)
            % Vector:
            % stim sham stim sham stim sham stim sham stim sham stim sham
            % tim1 tim1 tim2 tim2 tim3 tim3 tim4 tim4 tim5 tim5 tim6 tim6
            % int1 int1 int1 int1 int1 int1 int1 int1 int1 int1 int1 int1
            dataAnovaVector(dataAnovaVectorInd) = dataAnova(k,j,i);
            gIntVector(dataAnovaVectorInd) = gInt(k);
            gTimesVector(dataAnovaVectorInd) = gTimes(j);
            gTypeVector(dataAnovaVectorInd) = gType(i);
            dataAnovaVectorInd = dataAnovaVectorInd + 1;
        end
    end
end

% Perform Anova
[A, B, stats] = anovan(dataAnovaVector,...
    {gTypeVector', gTimeVector', gIntenseVector'})

%% Anova for peak times across: Intensity, stim/sham