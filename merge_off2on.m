function merge_off2on( infile , datadir)
%This is Yifat's version modified to deal with all files and with correct
%pathes.
if nargin == 1,
    datadir = 'd:\hugodata\';
end
fid = fopen( infile, 'r');
StimSets = ReadFile( fid );
fidout = fopen( 'outfile.log', 'w');

for i=1:length( StimSets ),
    %    setindx = sets2merge( i);
    Nint = length(StimSets(i).subsess);
    MTname = char(StimSets(i).matname);
    OMTname=['h' MTname(2:length(MTname))];
    sessname = ['h' MTname(2:end)];
    
    if ~exist([ datadir sessname '\MergedEdFiles'], 'dir')
        mkdir([ datadir sessname ], 'MergedEdFiles');
    else
        disp('MergedEdFiles directory exists');
    end
    
    for j=1:Nint,
        subname = char(StimSets(i).subsess(j).name);
        files = StimSets(i).subsess(j).files;
        indx = 1;
        for k=files(1):files(2),
            edname = [datadir sessname '\edfiles\' subname 'ee.' num2str(indx) '.mat'];
%             outname = ['d:\HugoData\HugoEdfiles\' subname 'ee.' num2str(indx) '.mat'];
            outname = [datadir sessname '\MergedEdFiles\' subname 'ee.' num2str(indx) '.mat'];
                
            indx = indx + 1;
            if k < 10,
                addext = '00';
            elseif k < 100
                addext = '0';
            else
                addext = '';
            end;
            if exist( edname, 'file')
                ed_data = load(edname);
                ed_data = RemoveOldOff( ed_data );
                out_data=ed_data;
                for elect=1:4
                    elect_str=num2str(elect);
                    offnameUn(elect).dat = [datadir OMTname '\elc_0' elect_str '\' MTname addext num2str(k) '__wvf_ndaT0' elect_str '.mat'];
                    if exist( offnameUn(elect).dat, 'file'),
                        off_data = load(offnameUn(elect).dat);
                        out_data = merge_data( out_data,off_data, elect);
                        %if StimSets(i).subsess(j).intns == 0, % no stimulation were given hence cortical activity
                    else
                        disp( [ offnameUn(elect).dat '-->> electrode #' elect_str ' offline file is missing!']);
                        fprintf( fidout, 'Set%d, subsess %d -->%s -->> electrode #%s offline file is missing.\n', i,j,offnameUn(elect).dat,elect_str);
                    end
                end
                save2file( out_data, outname );
            else
                disp('!!! Edfile file(s) do not exist!!!');
                %                  if  ~exist( edname, 'file') , 
                fprintf( fidout, 'Set%d, subsess %d --> %s -->> EDfile is missing.\n', i,j,edname);
                %                  end
                %                  if  ~exist( offname_sp, 'file') , 
                %                      fprintf( fidout, 'Set%d, subsess %d --> %s -->> offline sorting file is missing.\n', i,j,offname_sp);
                %                  end
                
            end;
        end;
    end;
end;

fclose(fidout);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function StimSets = ReadFile( fid )

indx = 0;
line = fgetl( fid );
while ischar( line ),
    line = lower( line );
    if ~isempty( findstr( line, 'set')),
        indx = indx + 1;
        in_indx =1;
    else,
        [sess, subsess, f(1), f(2), intns] = readline(line);
        if in_indx == 1,
            StimSets(indx).matname = sess;
        end;
        StimSets(indx).subsess(in_indx).name  = subsess;
        StimSets(indx).subsess(in_indx).files  = f;
        StimSets(indx).subsess(in_indx).intns  = intns;
        in_indx = in_indx + 1;
    end;
    line = fgetl( fid );
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [s1, s2, d1, d2, d3] = readline(line);

pos = min(findstr( line, ' '));
s1 = line(1:pos-1);
line = line(pos+1:length(line));

pos = min(findstr( line, ' '));
s2 = line(1:pos-1);
line = line(pos+1:length(line));

pos = min(findstr( line, '.'));
str = line(1:pos-1);
d1 = str2num( str);
pos = max(findstr( line, '.'));
line = line(pos+1:length(line));

pos = min(findstr( line, ' '));
str = line(1:pos-1);
d2 = str2num( str);
line = line(pos+1:length(line));
d3 = str2num(line);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out_data = merge_data( ed_data, off_data, CHid);

out_data = ed_data;
data = off_data.Data;
data(:,3) = data(:,3) *1000; % converting to msec
data(:,3) = cumsum( data(:,3));
data(:,3) = data(:,3)* off_data.TIME_UNITS;
sp2add = unique(data(:,2));
for i=1:length(sp2add),
    cursp = sp2add(i);
    sp = data(find(data(:,2) == cursp),3)';
    spname = ['Tspike' num2str((100*CHid)+cursp)];
    out_data = setfield( out_data, spname, sp);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save2file( outdata, outname );

% % edflds = fieldnames( outdata );
% % c2save = ['save ' outname];
% % for i=1:length(edflds),
% %     curname = char(edflds(i));
% %     cmnd = [curname '=outdata.' curname ';'];
% %     eval(cmnd);
% %     c2save = [c2save ' ' curname];
% % end;
% % eval(c2save)
save( outname ,'-struct','outdata')
disp(['Saving to file ' outname])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  edin = RemoveOldOff( edin );

fldnms = fieldnames( edin );
for i=1:length( fldnms),
    curname = char(fldnms(i));
    if ~isempty(findstr( lower(curname), 'tspike')),
        tmpstr = curname(7:length(curname));
        spid = str2num( tmpstr);
        if spid >= 100, % this is an off line spike
            edin = rmfield( edin, curname );
        end;
    end;
end;