function merge_all_Yolanda(   )
%Merges all offline sorted (alpha-sort) data.
% datadir = 'g:\hugo\hugodata\';
datadir = 'G:\users\ream\Prut\Yolanda\Data\YolandaData\';

indir = dir([ datadir 'y*']);
for i=1:length(indir),
    
    curdir = [datadir char(indir(i).name)];
    sessname = char(indir(i).name(2:end));
    if ~isdir( [curdir '\MergedEdFiles']),
        disp(['Merging off to on for --> ' curdir]);
        fname = writeMergeScript_yolanda(sessname, datadir);
        if ~isempty(fname),
            merge_off2on_yolanda( fname, datadir);
        end
    end
end



