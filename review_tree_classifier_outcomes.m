EXPERIMENT = 2;
if EXPERIMENT == 1
    acc_file_1 = 'tree_accuracy_1.mat';
    acc_file_2 = 'tree_accuracy_2.mat';

    ch_file_1 = 'channel_sort_1.mat';
    ch_file_2 = 'channel_sort_2.mat';

    score_file_1 = 'score_sort_1.mat';
    score_file_2 = 'score_sort_1.mat';
elseif EXPERIMENT == 2
    acc_file_1 = 'vma2_tree_accuracy_1.mat';
    acc_file_2 = 'vma2_tree_accuracy_2.mat';

    ch_file_1 = 'vma2_channel_sort_1.mat';
    ch_file_2 = 'vma2_channel_sort_2.mat';

    score_file_1 = 'vma2_score_sort_1.mat';
    score_file_2 = 'vma2_score_sort_1.mat';
else
    error('Experiment not specified.')
end
%% compare classification accuracy:
load(acc_file_1)
acc_1 = acc_;
load(acc_file_2)
acc_2 = acc_;
h1 = figure; hold on;
bar([1 2], [mean(acc_1) mean(acc_2)],'k');
errorbar([1 2], [mean(acc_1) mean(acc_2)],...
    [sqrt(var(acc_1)./length(acc_1)), sqrt(var(acc_2)./length(acc_2))], 'k.');

set(h1, 'Position', [1547 669 134 286]);
acc_diff = acc_2 - acc_1;
[h_diff,p_diff] = ttest(acc_diff); 
[h_1,p_1] = ttest(acc_1 - .5);
[h_2,p_2] = ttest(acc_2 - .5);

disp(['Difference in accuracy, p-val: ', num2str(p_diff)]);
disp(['Accuracy, type 1, p-val: ', num2str(p_1)]);
disp(['Accuracy, type 2, p-val: ', num2str(p_2)]);

%% Inspect sorted channels:
load(ch_file_1)
ch_1_ = channel_sort_;
ch_1 = cell(1,length(ch_1_));
for i_s = 1:length(ch_1_)
    sub_ch = cell(1, size(ch_1_{i_s},1));
    for i_ch = 1:size(ch_1_{i_s},1)
        sub_ch{i_ch} = ch_1_{i_s}(i_ch, :);
    end
    ch_1{i_s} = sub_ch;
end

load(ch_file_2)
ch_2_ = channel_sort_;
ch_2 = cell(1,length(ch_2_));
for i_s = 1:length(ch_2_)
    sub_ch = cell(1, size(ch_2_{i_s},1));
    for i_ch = 1:size(ch_2_{i_s},1)
        sub_ch{i_ch} = ch_2_{i_s}(i_ch, :);
    end
    ch_2{i_s} = sub_ch;
end

load(score_file_1)
scr_1 = score_sort_;
load(score_file_2)
scr_2 = score_sort_;

h2 = figure; 
for i_s = 1:length(ch_2)
    subplot(3,4,i_s);
    bar(1:length(ch_2{i_s}), scr_2{i_s}, 'k');
    xticks(1:length(ch_2{i_s}));
    xticklabels(ch_2{i_s});
    ylim([0 .6])
    title(['Score: ', num2str(acc_2(i_s))]);
end
suptitle(['Electrode Importance: Type 2 (Acc: ', num2str(mean(acc_2)), ')']);
set(h2, 'Position', [1 574 1335 381]);

h3 = figure; 
for i_s = 1:length(ch_1)
    subplot(3,4,i_s);
    bar(1:length(ch_1{i_s}), scr_1{i_s}, 'k');
    xticks(1:length(ch_1{i_s}));
    xticklabels(ch_1{i_s});
    ylim([0 .6])
    title(['Score: ', num2str(acc_1(i_s))]);
end
suptitle(['Electrode Importance: Type 1 (Acc: ', num2str(mean(acc_1)), ')']);
set(h3, 'Position', [1 70 1335 381]);