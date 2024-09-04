%% PROJECT CONFIG

[a,b] = fileparts(pwd) ; 
PROJ_DIR = a ; % put base path to project here
cd(PROJ_DIR)
clear a b

%% add to the path

projPathDirs = {
    'src'
    'data'
    'bin'
} ;

for idx=1:length(projPathDirs)
    addpath(genpath(strcat(PROJ_DIR,'/',projPathDirs{idx})))
end

clear projPathDirs

%% setup global vars

OUTSTR = 'sch400' ;

%% make output directory vars

DATADIR = strcat(PROJ_DIR , '/data/') ;
DD.INTERM = strcat(DATADIR, '/interim/' ) ;
DD.PROC = strcat(DATADIR, '/processed/' ) ;
DD.RAW = strcat(DATADIR, '/raw/' ) ;

%% other opts

finfo.TR = 0.72 ; 

finfo.nnodes = 400 ; 
finfo.ntp = 1200 ; 
finfo.nnodes_wsubc = 455 ; 

%% handy inline functions

tv = @(mat_) triuvec(mat_,1) ; 
ztv = @(mat_) zscore(triuvec(mat_,1)) ; 

% oneliner to plot
cortexplot = @(x_) parc_plot(surfss,annotm,'schaefer400-yeo17', x_(:),...
        'cmap',parula(100),...
        'viewcMap',0,'newFig',0,'viewStr','all') ;


%% load some viz stuff

parcpath = '~/joshstuff/git_pull/parc_plotter/' ; 
addpath(genpath(parcpath))

surf = load([parcpath '/data/fsaverage/mat/' 'fsaverage_inflated.mat']) ;
surfss = surf.surfStruct ;

annots = load([parcpath '/data/fsaverage/mat/' 'fsaverage_annots.mat']) ;
annotm = annots.allAnnots ;

%% just put the subject list here

sublist.all = cellstr(string(load([ DD.INTERM 'sub_list.txt']))) ; 
sublist.subset1 = cellstr(string(load([ DD.INTERM 'sub_list_subset1.txt']))) ; 
sublist.subset2 = cellstr(string(load([ DD.INTERM 'sub_list_subset2.txt']))) ; 

%% load data and basic

imglob = 'REST1_RL' ;
datStr = load_hcp_alldata(...
    [ DD.INTERM '/hcp352_nusregts_FIX2phys_schaefer400/' ],...
    'schaefer400-yeo17',...
    sublist.all, ...
    ['*' imglob '*']) ; 
cainfo = load('~/joshstuff/matlabfaskowit/data/nodes_2_canon.mat') ;

NSUBS = length(datStr) ; 

% really quick it would be nice to have a meanfc
meanfc = zeros(finfo.nnodes) ; 
for idx = 1:NSUBS
    meanfc = meanfc + corr(datStr(idx).ts(:,finfo.nnodes)) ; 
end
meanfc = meanfc ./ NSUBS ;  
meanfc = (meanfc + meanfc') ./ 2 ; 

%% parcellation setup

parc.ca = [ cainfo.schaef_str.map2ca('schaefer400_17net') ; ones(55,1).*18 ] ;
parc.names = [ cainfo.schaef_str.sch17 ; 'subc+cereb' ] ;

