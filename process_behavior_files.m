raw_files_dir = {'/Users/david/Box Sync/iEEG/Data/behavior/SL_P001/',...
    '/Users/david/Box Sync/iEEG/Data/behavior/SL_P002/',...
    '/Users/david/Box Sync/iEEG/Data/behavior/SL_P003/',...
    '/Users/david/Box Sync/iEEG/Data/behavior/SL_P004/',...
    '/Users/david/Box Sync/iEEG/Data/behavior/SL_P005/',...
    '/Users/david/Box Sync/iEEG/Data/behavior/SL_P006/',...
    '/Users/david/Box Sync/iEEG/Data/behavior/SL_P007/',...
    '/Users/david/Box Sync/iEEG/Data/behavior/SL_P008/',...
    '/Users/david/Box Sync/iEEG/Data/behavior/SL_P009/',...
    '/Users/david/Box Sync/iEEG/Data/behavior/SL_P010/',...
    };
% raw_files_dir = {'/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/data/behavior/PSL_001/',...
%     '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/data/behavior/PSL_002/',...
%     '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/data/behavior/PSL_003/',...
%     '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/data/behavior/PSL_004/',...
%     };

% output_dir = '/gpfs/milgram/project/turk-browne/projects/vma_statlearning_iEEG/intermediate_data/';
output_dir = pwd;

raw_files = {...
{...
'P001_statlearn7375795311870718.mat',...
'P001_statlearn7375795344488195.mat',...
'P001_statlearn7375795363007870.mat',...
'P001_statlearn7375795440740046.mat',...
'P001_statlearn7375797489282407.mat',...
'P001_statlearn7375797565194676.mat',...
'P001_statlearn7375797622670024.mat',...
},...
{...
'P002_statlearn7376214049463426.mat',... %7/15
'P002_statlearn7376214071538195.mat',... %7/15
'P002_statlearn7376214090459838.mat',... %7/15
'P002_statlearn7376214148244560.mat',... %7/15
'P002_statlearn7376244189293634.mat',... %7/18
'P002_statlearn7376244243949653.mat',... %7/18
'P002_stim_statlearn7376284279614005.mat',... %7/22
'P002_stim_statlearn7376284324538773.mat',... %7/22 %THIS COMPLETES 1 FULL STUDY
'P002_statlearn7376334478170138.mat',... % 7/27
'P002_statlearn7376356264536227.mat',... % 7/29 %CALL THIS _SHORT because future blocks had messed up triggers.
...'P002_statlearn7376356472231597.mat',... %7/29
...'P002_statlearn7376383943435185.mat',... %8/1
...'P002_statlearn7376385576601041.mat',... %8/1
...'P002_statlearn7376385634927894.mat',... %8/1
...'P002_statlearn7376385676725116.mat',... %8/1
...'P002_statlearn7376424357765162.mat',... %8/5
...'PSL002_statlearn_final7376563928937500.mat',... % 8/19
...'PSL002_statlearn_final7376563983477199.mat'... % 8/19
},...
{...
'P003_statlearn7376426220612500.mat',...
'P003_statlearn7376426236731366.mat',...
'P003_statlearn7376426265767129.mat',...
'P003_statlearn7376426335925347.mat',...
'P003_statlearn7376426346528820.mat',...
'P003_statlearn7376426349853241.mat',...
'P003_statlearn7376426413970833.mat'...
},...
{...
'PSL004_statlearn_7376636173737963.mat',...
'PSL004_statlearn_7376636190091087.mat',...
'PSL004_statlearn_7376636206212384.mat',...
'PSL004_statlearn_7376636267877314.mat',...
'PSL004_statlearn_7376637273807176.mat',...
'PSL004_statlearn_7376666220465162.mat',...
'PSL004_statlearn_7376666284878820.mat',...
'PSL004_statlearn_7376666355135301.mat',...
},...
{...
'PSL005_statlearn_7376895827384606.mat',...
'PSL005_statlearn_7376895849141551.mat',...
'PSL005_statlearn_7376895871109838.mat',...
'PSL005_statlearn_7376895948917709.mat',...
'PSL005_statlearn_7376896066622917.mat',...
'PSL005_statlearn_7376896156652893.mat',...
'PSL005_statlearn_7376897248135533.mat',...
'PSL005_statlearn_7376897320921990.mat',...
},...
{...
'PSL006_statlearn_7377244309514815.mat',...
'PSL006_statlearn_7377244363762153.mat',...
'PSL006_statlearn_7377244415936111.mat',...
'PSL006_statlearn_7377244492244560.mat',...
'PSL006_statlearn_7377244572147107.mat',...
'PSL006_statlearn_7377244648810070.mat',...
'PSL006_statlearn_7377247069078472.mat',...
'PSL006_statlearn_7377247135662731.mat',...
'PSL006_statlearn_7377266843038079.mat',...
'PSL006_statlearn_7377266914470139.mat',...
},...
{...
'PSL007_statlearn_7377386544085069.mat',...
'PSL007_statlearn_7377386616530903.mat',...
'PSL007_statlearn_block5_b.mat',...
'PSL007_statlearn_7377386770349884.mat',...
'PSL007_statlearn_7377404374553473.mat',...
'PSL007_statlearn_7377404433836227.mat',...
'PSL007_statlearn_7377407251370718.mat',...
'PSL007_statlearn_7377407320366204.mat',...
'PSL007_statlearn_7377407383625000.mat'...
},...
{...
'PSL008_statlearn_7377503933620949.mat',...
'PSL008_statlearn_7377503949298959.mat',...
'PSL008_statlearn_7377503966323611.mat',...
'PSL008_statlearn_7377504023917130.mat',...
'PSL008_statlearn_7377504080284144.mat',...
'PSL008_statlearn_7377504144864468.mat',...
'PSL008_statlearn_7377504200106366.mat',...
'PSL008_statlearn_7377506413916667.mat',...
'PSL008_statlearn_7377506431423379.mat',...
'PSL008_statlearn_7377506531864352.mat',...
'PSL008_statlearn_7377506537911806.mat',...
'PSL008_statlearn_7377506594784954.mat',...
'PSL008_statlearn_7377506652189121.mat',...
'PSL008_statlearn_7377506655676620.mat',...
'PSL008b_statlearn_7377614128727663.mat',...
'PSL008b_statlearn_7377614191599652.mat',...
'PSL008b_statlearn_7377614247533333.mat'...
},...
{...
'PSL0097377966867362848.mat',...
'PSL0097377966884218055.mat',...
'PSL0097377966905793750.mat',...
'PSL0097377966970349537.mat',...
'PSL0097377967029627546.mat',...
'PSL_block6_01062020.mat'...
},...
{...
'PSL0107378104509199189.mat',...
'PSL0107378104533252199.mat',...
'PSL0107378104556498843.mat',...
'PSL0107378104638325694.mat',...
'PSL0107378104707777894.mat',...
'PSL0107378104789598958.mat',...
'PSL0107378104854218634.mat',...
'PSL0107378106775676621.mat',...
'PSL0107378106824444560.mat',...
'PSL0107378136706275231.mat',...
'PSL0107378136767822569.mat',...
'PSL0107378136828462615.mat',...
'PSL0107378136884704167.mat',...
'PSL0107378136937094792.mat'...
}...
};

%% run the analyzes
divs = 4;
rt_set = cell(1, length(raw_files_dir));
rt_mean = nan(3, length(raw_files_dir));
rt_qrt = nan(3, length(raw_files_dir), divs);
rt_var_se = nan(3, length(raw_files_dir));
for i_sub = 1:length(raw_files_dir)
    rt = analyze_behavior_milg_v2(raw_files_dir{i_sub}, raw_files{i_sub});
    rt_set{i_sub} = rt;
    rt_mean(:, i_sub) = [nanmedian(rt(rt(:,2) == 0), 1),...
        nanmedian(rt(rt(:,2) == 1), 1),...
        nanmedian(rt(rt(:,2) == 2), 1)]';
    rt_var_se(:, i_sub) = [sqrt(nanvar(rt(rt(:,2) == 0), [], 1)./sum(rt(:,2) == 0)),...
        sqrt(nanvar(rt(rt(:,2) == 1), [], 1)./sum(rt(:,2) == 0)),...
        sqrt(nanvar(rt(rt(:,2) == 2), [], 1)./sum(rt(:,2) == 0))]';
    qrt_len = floor(size(rt,1)/4);
    k_q_ind = 1;
    for i_q = 1:divs
        inds = k_q_ind - 1 + (1:qrt_len);
        rt_q = rt(inds, :);

        rt_qrt(:, i_sub, i_q) =  [nanmedian(rt_q(rt_q(:,2) == 0), 1),...
        nanmedian(rt_q(rt_q(:,2) == 1), 1),...
        nanmedian(rt_q(rt_q(:,2) == 2), 1)]';

        k_q_ind = k_q_ind + qrt_len;
    end
end
save([output_dir,filesep, 'rt_set_short'], 'rt_set');


%% plot the results
f_mean_rt = figure; hold on;
errorbar(1:size(rt_mean,1), nanmean(rt_mean,2), sqrt(nanstd(rt_mean,[],2)./4), '.');
bar(1:size(rt_mean,1), nanmean(rt_mean,2),'k');
saveas(f_mean_rt, 'behavior_mean_rt.pdf', 'pdf')
axis([0 4 0 1]);

%% plot the results
select_subs = [3,5,6,8];
f_mean_qt = figure;
inds = 1:size(rt_qrt,1);
for i_q = 1:divs
    subplot(1,4,i_q); hold on;
    errorbar(1:size(rt_qrt(:,select_subs,i_q),1), nanmean(rt_qrt(:,select_subs,i_q),2),...
        sqrt(nanvar(rt_qrt(:,select_subs,i_q),[],2)./4), 'k.');
%     bar(1:size(rt_qrt,1), nanmean(rt_qrt(:,:,i_q),2),'k');
    temp_mean = nanmean(rt_qrt(:,select_subs,i_q),2);
    bar(inds(1), temp_mean(1), 'r');
    bar(inds(2), temp_mean(2), 'g');
    bar(inds(3), temp_mean(3), 'b');

    axis([0 4 0 1]);
end
saveas(f_mean_qt, 'behavior_rt_quarters.pdf', 'pdf')
