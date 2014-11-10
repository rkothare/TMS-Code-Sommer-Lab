%%Calculate the baselines for cells before and after the tms pulse and then
%%plot the neuron response, after vs before.
close all
%load data
file='base_save_SFN.mat';
load(file);

%set the parameter
t_period=5000; %Time period for average firing rate before and after
base_bef=[];
base_aft=[];

%Create a file for each intensity
intensity=unique(base_save(3,:));
for h=1:9;%size(intensity,2)
    inten_pos=find(base_save(3,:)==intensity(h));
    pop(h,:)=size(inten_pos);
    base_inten=base_save(:,inten_pos);
    base_bef=nan(25,pop(h,2));
    base_aft=nan(25,pop(h,2));
    wave=wave_save(inten_pos,:);
    %Run through the structure
    for n=1:size(base_inten,2)
        blockdata=s(base_inten(1,n)); %save the particular block we are interested in
        pulses=blockdata.Pulses;
        clust_pos=find(blockdata.clusters==base_inten(2,n)); %Finds the cluster position for the clusters we are interested in
        clust_time=1000*blockdata.times(clust_pos); %Finds the times of the interested cluster: turns into ms
        rast=figure;
        subplot(2,1,1)
        title([blockdata.Name ' Intensity: ' num2str(h*10)])
        [~,~, num_spike_bef,~]=Raster(pulses,t_period,0,clust_time);
        hold on
        [~,~, num_spike_aft,~]=Raster(pulses,0,t_period,clust_time);
        close(rast)
        fire_bef=num_spike_bef./(t_period/1000);
        fire_aft=num_spike_aft./(t_period/1000);
        %         base_bef=[base_bef mean(fire_bef(1))];
        %         base_aft=[base_aft mean(fire_aft(1))];
        base_bef(1:length(fire_bef),n)=fire_bef;
        base_aft(1:length(fire_bef),n)=fire_aft;
%         if base_aft(1,n)-base_bef(1,n)>50
%             subplot(2,1,2)
%             plot(cell2mat(wave(n,2)),cell2mat(wave(n,1)))
%             xlabel(sprintf('Fire Before: %d Fire After: %d Diff: %d',...
%                 base_bef(1,n), base_aft(1,n), base_aft(1,n)-base_bef(1,n)))
%         else
%             close(rast)
%         end
    end
    figure
    plot(base_bef(1,:),base_aft(1,:),'o','MarkerFaceColor',[0 0 1])
    hold on
    unitx=linspace(min(min(base_bef(1,:))),ceil(1.1*max(max(base_bef(1,:)))),1000);
    plot(unitx,unitx,'k-')
    %xlim([-ceil(1.1*max(log10(base_bef)))  ceil(1.1*max(log10(base_bef)))])
    xlabel(['Scale Baseline ' num2str(t_period) ' Before TMS Pulse']);
    ylabel(['Baseline ' num2str(t_period) ' After TMS Pulse']);
    title(['Population at Intensity ' num2str(intensity(h)) '%, Cell Count=' num2str(pop(h,2))]);
    base_change=base_aft(1,:)-base_bef(1,:);
%     pwave=find(base_change>50);
%     if size(pwave)>0
%         figure
%         for z=1:length(pwave)
%             subplot(5,ceil(length(pwave)/5),z)
%             plot(cell2mat(wave(pwave(z),2)),cell2mat(wave(pwave(z),1)))
%             title(['Intensity: ' num2str(h*10) ' n=' num2str(z)])
%         end
%     end
    figure
    plot(base_change,'go','MarkerFaceColor',[0 1 0])
    hold on
    plot(base_aft(1,:),'bo','MarkerFaceColor',[0 0 1])
    plot(base_bef(1,:),'ro','MarkerFaceColor',[1 0 0])
    legend('Difference','After','Before',0)
    title(['Population at Intensity ' num2str(intensity(h)) '%, Cell Count=' num2str(pop(h,2))]);
    
    figure
    %hist(base_change,linspace(min(base_change),max(base_change),10))
    edge=linspace(-50,50,21);
    [N,Bin]=histc(base_change,edge);
    bar(edge,N./max(N),'histc')
    axis([min(edge) max(edge) 0 1.1])
    title(['Population at Intensity ' num2str(intensity(h)) '%, Cell Count=' num2str(pop(h,2))]);
    
    figure
    subplot(3,1,1)
    plot(1:25,nanmean(base_aft-base_bef,2),'o-')
    hold on
    plot(1:25,nanmedian(base_aft-base_bef,2),'ro-')
    axis([0 20 -8 8])
    title(['Population at Intensity ' num2str(intensity(h)) '%, Cell Count=' num2str(pop(h,2))]);
    subplot(3,1,2)
    plot(1:25,base_aft-base_bef,'o')
    hold on
    plot(1:25,zeros(size(1:25)),'k-')
    xlim([0 20])
    subplot(3,1,3)
    plot(1:24,diff(base_aft-base_bef),'o')
    xlim([0 20])
end