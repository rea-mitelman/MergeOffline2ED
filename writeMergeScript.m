function filename = writeMergeScript(dateStr, path_name)

if nargin == 1,
    path_name='d:\hugodata\';
end
% filename=[path_name 'Vega' dateStr '.txt'];
filename=[ 'Hugo' dateStr '.txt'];
fid=fopen(filename,'wt');
fprintf(fid,'Set 1:');
f2load = [path_name 'h' dateStr '\info\h' dateStr '_param.mat'];
if ~exist(f2load,'file'),
    filename = [];
    disp([f2load ' --> no param file']);
    return;
end

load([path_name 'h' dateStr '\info\h' dateStr '_param.mat']);
for i=1:length(SESSparam.SubSess), 
    line=sprintf('\nE%s h%02d%02d %d..%d ',dateStr,DDFparam.ID,i, SESSparam.SubSess(i).Files(1),SESSparam.SubSess(i).Files(2));
%     if isfield(SESSparam.SubSess(i).CT,'Stim') && SESSparam.SubSess(i).CT.Stim, % searching for stimulation files currently this option is disbled!
%         line=sprintf('%s%d',line,SESSparam.SubSess(i).CT.StimAmp);
%     else
%         line=sprintf('%s%d',line,0);
%     end
    fprintf(fid,line);
end
fclose(fid);