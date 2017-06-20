% read_data.m
% 05.29.2014 Chaofeng Wang, Clemson University 

%Description: This function reads locations of data points; reads CPT and caltulate LPIs.  
%Inputs:  CPT data files
%Outputs: INITIAL  (storing locations and LPIs)     

%INITIAL: a matrix stores LPI and locations
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

function [] = cook_Pars_for_hazardCurves()

INITIAL=[];


mydir=fullfile('inputs','CPT');
%tempSUM=dir(fullfile('inputs','CPT','*.txt'));
%save('tempSUM.mat','tempSUM')
load('tempSUM.mat');

num_tempSUM=length(tempSUM);
   
i=1;
filename=fullfile(mydir,tempSUM(i).name);


fid=fopen(filename);
for i=1:50
s=fgetl(fid);
if isempty(strfind(s,'UTM-X'))~=1
    x_line=i;  
end
if isempty(strfind(s,'UTM-Y'))~=1
    y_line=i;
end 
if isempty(strfind(s,'Depth'))~=1
    data_line=i+1;
end 
if isempty(strfind(s,'Water'))~=1
    water_line=i;
end 
end
    


LOC=[];
water=[];
tempnametxt=[];
for j=1:num_tempSUM
    
    filename=fullfile(mydir,tempSUM(j).name);
    
    

     C = textread(filename, '%s','delimiter', '\n');
     UTM_X_line_str=C{x_line};
     bbx = isstrprop(UTM_X_line_str,'digit');
     UTM_X_str = UTM_X_line_str(find(bbx,1,'first'):length(bbx));
     UTM_X = str2double(UTM_X_str);
%      UTM_X_str = UTM_X_line_str(isstrprop(UTM_X_line_str,'digit'));
%      UTM_X = str2double(UTM_X_str);
     
     UTM_Y_line_str=C{y_line};
     bby = isstrprop(UTM_Y_line_str,'digit');
     UTM_Y_str = UTM_Y_line_str(find(bby,1,'first'):length(bby));
     UTM_Y = str2double(UTM_Y_str);
%      UTM_Y_str = UTM_Y_line_str(isstrprop(UTM_Y_line_str,'digit'));
%      UTM_Y = str2double(UTM_Y_str);

     water_line_str=C{water_line};
     
     bb = isstrprop(water_line_str,'digit');
     water_str = water_line_str(find(bb,1,'first'):length(bb));
     water_temp = str2double(water_str);
     
     if isnan(water_temp)
         water_temp = 0;
     end
     
    LOC=[LOC;[UTM_X,UTM_Y]];
    water=[water;water_temp];
    
    tempnametxt=[tempnametxt;tempSUM(j).name];
    
end
% some sounding points don't have water table, assume average
ind = abs(water-0)<0.00001;
ind2 = abs(water-0)>=0.00001;
avg_water = sum(water)/(length(water)-sum(abs(water-0)<0.00001));
% water(ind,1) = avg_water*ones(sum(abs(water-0)<0.00001),1);
% -----extrapolater water table for those souding points where water table
% is not obtained----start------------
% water(ind,1) = -1*ones(sum(abs(water-0)<0.00001),1);
watertemp = water;
watertemp(ind,:) = [];
x1 = LOC(:,1);
y1 = LOC(:,2);
x1(ind,:) = [];
y1(ind,:) = [];
% Create a scatteredInterpolant for each sampling of water(x,y).
F1 = scatteredInterpolant(x1(:),y1(:),watertemp(:));
[xq,yq] = ndgrid((min(x1)):100:(max(x1)),(min(y1)):500:(max(y1)));
water(ind2,1) = watertemp;
water(ind,1) = F1(LOC(ind,1),LOC(ind,2));
% figure
% vq1 = F1(xq,yq);
% surf(xq,yq,-vq1)
% title('water table')
% -----extrapolater water table for those souding points where water table
% is not obtained----end------------



count=1;
nametxt=[];
for j=1:length(LOC(:,1))
%     for i=1:length(ELEMENTS(:,1))
%         index=ELEMENTS(i,[2 3 4 5]);
%         x=NODES(index,2);
%         y=NODES(index,3);
%         if inpolygon(LOC(j,1),LOC(j,2),x,y)==1
%         row=i;
%         elem_index=ELEMENTS(i,1);
%         INITIAL=[INITIAL;elem_index,LOC(j,1),LOC(j,2)];
%         nametxt=[nametxt;tempSUM(j).name];
%         count=count+1;
%         break
%         end
%     end
INITIAL=[INITIAL;j,LOC(j,1),LOC(j,2)];
nametxt=[nametxt;tempSUM(j).name];
end



% ----- find vs30 ----start------------
x2 = INITIAL(:,2);
y2 = INITIAL(:,3);
zone(1:length(x2),1) = '1';
zone(1:length(x2),2) = '0';
zone(1:length(x2),3) = ' ';
zone(1:length(x2),4) = 'S';
[lat,lon]=utm2deg(x2,y2,zone);
vs30 = findVs30(lat,lon);
vs30filename=fullfile('outputs','vs30.txt');
vs30filenamefid = fopen(vs30filename, 'wt');
% fprintf(fid, '%s %f   \n', name',LPI');
for i=1:length(vs30)
    fprintf(vs30filenamefid, '%d,\n', vs30(i,1));
end
fclose(fid);
% ----- find vs30 ----end------------

% figure
% plot(LOC(:,1),LOC(:,2),'ro')
% for i=1:211
%     hold on
%     text(LOC(i,1),LOC(i,2),num2str(i));
% end
% axis equal



%------   specify soil type !start ---------
NEHRPC =[21 22 23 24 32 153 182 ...
    47 44 45 50 58 48 62 57 56 61 ...
    78 76 77 53 54 79 80 55 193 192 178 101 ...
    194 195 163 196 174 175 176 161 ...
    99 191 177 190 100 170 146 147 180 199 ...
    186 106 187 197 198 181 105 ...
    200 95 201 203 202 92 ...
    164 110 109 97];  %green

NEHRPE = [[122:130 ],...
    [165:167 148 149 150 151 152 1 2 5 6 7 8 9:20 25 26 27 28 29 30 31 33:43 64:67 143 144 145],...
    [133 135  136 137 138  139 140 141 142    ],...
    [72 86:90  91 98 115 116 104 63 85] ]; %pink
NEHRPD =setdiff(1:211,[NEHRPC,NEHRPE]); %yellow
% figure 
% plot(LOC(NEHRPE,1),LOC(NEHRPE,2),'ro')
% hold on
% plot(LOC(NEHRPC,1),LOC(NEHRPC,2),'r*')
% hold on
% plot(LOC(NEHRPD,1),LOC(NEHRPD,2),'k>')
% axis equal
%------   specify soil type !end ---------


%----------------get settlement
% mypool = parpool(4);
% S = zeros(1,length(nametxt));
fidPar = fopen('../pars.txt', 'wt');
fidHazardPar = fopen('../HazardPar.txt', 'wt');

for i=1:length(LOC(:,1))
    nametxt(i,:);
    hazardCurve = fullfile('inputs','hazardCurve',[nametxt(i,1:6),'.csv']);
    mydir = fullfile('inputs','usgs');
    prefixName = nametxt(i,:);
    prefixName = prefixName(1,1:6);
    for j = 1:6
        switch j
            case 1,
             percent = '01';
             year = '50';
            case 2,
              percent = '02';
             year = '50';
            case 3,
                percent = '05';
             year = '50';
            case 4,
                percent = '10';
             year = '50';
            case 5,
                percent = '20';
             year = '50';
            case 6,
                percent = '50';
             year = '75';
        end
        filename = fullfile(mydir,[prefixName,'_',percent,'_',year,'.txt']);
        pga(i,j) = parseFile(filename);
        i
        %mysite-cpt-2 37.788889 -122.433038 10 50 760 1 1 1
        fprintf(fidPar, '%s %8.6f %9.6f %i %i 760 1 1 1 \n', ...
            [prefixName,'_',percent,'_',year],lat(i),lon(i),str2num(percent),str2num(year));
        


%         if ~exist(filename,'file')
%             disp(filename); 
%         end
    end
    fprintf(fidHazardPar,'http://geohazards.usgs.gov/hazardtool/curves.php?format=2&lat=%8.6f&lon=%9.6f&site=760&period=0p00 %s\n',lat(i),lon(i),prefixName);
    
%     PGAlvels = pga(i,:);
%     ConditionalMw(nametxt(i,1:6));% conditional Mw, Fig.3 in Juang 2008
%     siteName = nametxt(i,1:6);
%     [Temp_Mw,Amax,p_Amax_Mw] = ProbabilityofMwPGA(siteName,hazardCurve,PGAlvels); % p_Amax_Mw = P(Mw,Amax)
%     [Grid_Mw,Grid_amax]=meshgrid(Temp_Mw,Amax);
%     
%     filename=fullfile('inputs','CPT',nametxt(i,:));
%     [mm,nn] = size(p_Amax_Mw);
%     prob = zeros(mm,nn);
%     
%     readCPTData
% 
%     mu_a = 0;
%     settlement = 0;
%     settlement_matrix = zeros(mm,nn);
%     for m = 1:mm
%         for n = 1:nn
%             % calculate settlement given (Mw,Amax)
%            [Stemp,mu_a_temp,settlement_temp] = Settlement(filename,Grid_amax(m,n),water(i),Grid_Mw(m,n),s_limit,qc,fs,z);%water(j) is water talbe.
%            settlement_matrix(m,n) = mu_a_temp;
%            mu_a = mu_a + mu_a_temp*p_Amax_Mw(m,n);
%            settlement = settlement + settlement_temp*p_Amax_Mw(m,n);
% %            S(i) = S(i) + p_Amax_Mw(m,n)*Stemp;
%            prob(m,n) = p_Amax_Mw(m,n)*Stemp;
%         end
%     end
% 
%     data.p = sum(sum(prob));
%     data.s = settlement;
%     data.mu = mu_a;
%     save(['outputs/settlement/',num2str(number),'.mat'],'data');
%     save(['outputs/settlement/settlement_matrix',num2str(number),'.mat'],'settlement_matrix');

    
end
fclose(fidPar);
fclose(fidHazardPar);
% delete(mypool);





