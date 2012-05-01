function merge_files( sessid,path_name )

if nargin==1
    path_name='d:\HugoDataCtxThl\';
end

if findstr( sessid(1) ,'h'),
    sessid = sessid(2:end);
end
%writeMergeScript(sessid, 'd:\HugoData-Spinal\')
%  merge_off2on( ['Hugo' sessid '.txt'], 'd:\hugodata-spinal\')
writeMergeScript(sessid, path_name)
  merge_off2on( ['Hugo' sessid '.txt'], path_name)