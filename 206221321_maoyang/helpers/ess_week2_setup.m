function ess_week2_setup(root)
% 优先沿用已配置的课程工具箱；必要时加载本机已有的课程依赖。
addpath(fullfile(root,'data'),fullfile(root,'helpers'));
if exist('runpf','file')==2 && exist('sdpvar','file')==2,return;end
home=getenv('HOME');
locations={fullfile(root,'dependencies'),fullfile(fileparts(root),'dependencies'),...
    fullfile(home,'Documents','Codex','MATLAB_Toolboxes'),...
    fullfile(home,'Documents','Codex','2026-10-30','meta-lab',...
        'outputs','ESS_Day3_Mac','dependencies')};
for k=1:numel(locations)
    if isfolder(locations{k}),addpath(genpath(locations{k}));end
    if exist('runpf','file')==2 && exist('sdpvar','file')==2,break;end
end
assert(exist('runpf','file')==2 && exist('sdpvar','file')==2,...
    '请将课程使用的 MATPOWER 和 YALMIP 加入 MATLAB 路径。');
end
