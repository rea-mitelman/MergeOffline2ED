function merge_all(   )
%Merges all offline sorted (alpha-sort) data.
% datadir = 'g:\hugo\hugodata\';
datadir = 'G:\users\ream\Prut\Ctx-Thal\data\HugoData-CtxThl\';

indir = dir([ datadir 'h*']);
for i=1:length(indir),
    
    curdir = [datadir char(indir(i).name)];
    sessname = char(indir(i).name(2:end));
    if ~isdir( [curdir '\MergedEdFiles']),
        disp(['Merging off to on for --> ' curdir]);
        fname = writeMergeScript(sessname, datadir);
        if ~isempty(fname),
            merge_off2on( fname, datadir);
        end
    end
end

        

