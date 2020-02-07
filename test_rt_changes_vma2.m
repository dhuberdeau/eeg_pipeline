% does the RT get faster / shorter for Type2 trials?

load('rt_set_short');

%% 
figure;
for i_sub = 1:length(rt_set)
    rt = rt_set{i_sub};
    inds = 1:length(rt);
    
    inds0 = inds(rt(:,2)==0);
    inds1 = inds(rt(:,2)==1);
    inds2 = inds(rt(:,2)==2);
    
    rt0 = rt(rt(:,2) == 0, 1);
    rt1 = rt(rt(:,2) == 1, 1);
    rt2 = rt(rt(:,2) == 2, 1);
    
    subplot(3,4,i_sub);
%     plot(rt
end