

addpath('MIRtoolbox1.7.2\MIRToolbox');
addpath('MIRtoolbox1.7.2\AuditoryToolbox');
clear;
path_files=getAllFiles(pwd,'*.mp3',1);
namesfilesprim=char(getAllFiles(pwd,'*.mp3',0)); %Names
pathfiles=char(path_files); %Paths
numrows=length(path_files)*3; 
numfiles=length(path_files);

for i=1:numfiles
    for c=1:3
       namesfiles((i-1)*3+c, :) = namesfilesprim(i, :);
       pathfiles_table((i-1)*3+c, :) = pathfiles(i, :);
    end
end


% Preallocating variables
%datesfiles=char(zeros(numfiles,21));
bytesfiles=zeros(numrows,1);
umchannelsfiles=zeros(numrows,1); %NumChannels
sampleratefiles=zeros(numrows,1);   %SampleRate
totalsamplesfiles=zeros(numrows,1); %TotalSamples
durationfiles=zeros(numrows,1); %Duration
bitratefiles=zeros(numrows,1);%BitsRate
numchannelsfiles=zeros(numrows,1);

rmsfiles=zeros(numrows,1);
rmsmedianfiles=zeros(numrows,1);
lowenergyfiles=zeros(numrows,1);
ASRfiles=zeros(numrows,1);
beatspectrumfiles=zeros(numrows,1);
eventdensityfiles=zeros(numrows,1);
tempofiles=zeros(numrows,1);
pulseclarityfiles=zeros(numrows,1);
attackslopefiles=zeros(numrows,1);
attackleapfiles=zeros(numrows,1);
zerocrossfiles=zeros(numrows,1);
rolloffsfiles=zeros(numrows,1);
brightnessfiles=zeros(numrows,1);
spreadfiles=zeros(numrows,1);
skewnessfiles=zeros(numrows,1);
centroidfiles=zeros(numrows,1);
kurtosisfiles=zeros(numrows,1);
flatnessfiles=zeros(numrows,1);
entropyfiles=zeros(numrows,1);
pitchfiles=zeros(numrows,1);
inharmonicityfiles=zeros(numrows,1);
bestkeyfiles=zeros(numrows,1);
keyclarityfiles=zeros(numrows,1);
modalityfiles=zeros(numrows,1);
datesfiles = {};
%Get all the info 
for i=1:numfiles
    for c=1:3
    infofiles(i)=audioinfo(pathfiles(i,:));
    pathfiles(i, :);
    file_temp=dir(pathfiles(i,:));
    datesfiles{(i-1)*3+c}=file_temp.date;
    bytesfiles((i-1)*3+c)=file_temp.bytes;
    %Titles
    if isempty(infofiles(i).Title)==1 %Check Title is not empty
    infofiles(i).Title=char('empty');
    end
    if isempty(infofiles(i).Comment)==1 %Check Comment is not empty
    infofiles(i).Comment=char('empty');
    end
    if isempty(infofiles(i).Artist)==1 %Check Artist is not empty
    infofiles(i).Artist=char('empty');
    end
    numchannelsfiles((i-1)*3+c)=infofiles(i).NumChannels; %NumChannels
    sampleratefiles((i-1)*3+c)=infofiles(i).SampleRate;   %SampleRate
    totalsamplesfiles((i-1)*3+c)=infofiles(i).TotalSamples; %TotalSamples
    durationfiles((i-1)*3+c)=infofiles(i).Duration; %Duration
    bitratefiles((i-1)*3+c,:)=infofiles(i).BitRate; %BitsRate
    end
end

compresionMethodfiles=char(infofiles.CompressionMethod); %CompresionMethod
titlesfiles=char(infofiles.Title); %Title
commentfiles=char(infofiles.Comment); %Comments
artistsfiles=char(infofiles.Artist); %Artist
%



for i=1:numfiles

for c = 1:3
    %Use 10s of the song 
    ri = round((durationfiles((i-1)*3+c)-10)*rand(1)) ;
    file_audio=miraudio(pathfiles(i,:),'Extract',ri,ri+10);
    mirsave(file_audio, strcat('part',int2str(c),'.wav'));
    pathfiles(i,:)
    %Features Extraction Using MIRtoolbox

    %Root-Mean-Square-Energy
    file_rms=mirrms(file_audio);
    rmsfiles((i-1)*3+c)=mirgetdata(file_rms); % RMS 
    %Root-Median-Square-Energy
    file_rms_m=mirrms(file_audio,'Median');
    rmsmedianfiles((i-1)*3+c)=mirgetdata(file_rms_m); % RMS each File
    file_rmsframes=mirrms(file_audio, 'Frame');
    %rmsFramesfiles(i,:)=mirgetdata(file_rmsframes); % Matrix with the RMS of each frame

    %the low-energy rate
    file_lowenergy=mirlowenergy(file_rmsframes);
    lowenergyfiles((i-1)*3+c)=mirgetdata(file_lowenergy); %Low Energy

    %Average Silence Ratio
    file_ASR=mirlowenergy(file_rmsframes,'ASR');
    ASRfiles((i-1)*3+c)=mirgetdata(file_ASR); %ASR

    %Beat Spectrum
    [file_beatspectrum file_similaritymatrix]=mirbeatspectrum(file_audio);
    [r, cols] = size(mirgetdata(file_beatspectrum));
    if cols == 1
        beatspectrumfiles((i-1)*3+c)=mirgetdata(file_beatspectrum); %Beat Spectrum
    end
    
    %Onsets
    file_onsets= mironsets(file_audio);
    %onsetsfiles(:,i)=mirgetdata(file_onsets);  %On sets

    %Estimates the average frequency of events
    file_eventdensity=mireventdensity(file_onsets);
    eventdensityfiles((i-1)*3+c)=mirgetdata(file_eventdensity);

    %Tempo
    file_tempo=mirtempo(file_audio);
    tempofiles((i-1)*3+c)=mirgetdata(file_tempo);   %Tempo

    %Mirmetre -- struct

    %file_metroid=mirmetroid(file_audio);  %Dif size


    %Estimates the rhythmic clarity, indicating the strength of the beats
    %estimated default heuristic).
    file_pulseclarity=mirpulseclarity(file_audio);
    pulseclarityfiles((i-1)*3+c)=mirgetdata(file_pulseclarity); %rhythmic clarity


    %its average slope.
    file_attackslope=mirattackslope(file_audio,'Single');
    if ~isempty(mirgetdata(file_attackslope))
        attackslopefiles((i-1)*3+c)=mirgetdata(file_attackslope); 
    end

    %the amplitude difference between the beginning and the end of the attack phase
    file_attackleap=mirattackleap(file_onsets,'Single');
    if ~isempty(mirgetdata(file_attackleap))
        attackleapfiles((i-1)*3+c)=mirgetdata(file_attackleap); %Different size 
    end

    %Decreaseslope
    % file_decreaseslope=mirdecreaseslope(file_audio,'Single');
    % decreaseslopefiles(i)=mirgetdata(file_decreaseslope); %Dontwork

    %the number of times the signal crosses the X-axis 
    file_zerocross=mirzerocross(file_audio);
    zerocrossfiles((i-1)*3+c)=mirgetdata(file_zerocross); %Zero Cross

    %the amount of high frequency in the signal
    file_rolloff=mirrolloff(file_audio);
    rolloffsfiles((i-1)*3+c)=mirgetdata(file_rolloff);  %Roll off

    %brightness
    file_brightness=mirbrightness(file_audio);
    brightnessfiles((i-1)*3+c)=mirgetdata(file_brightness); % Brightness

    %The Spectral spread 
    file_mirspread=mirspread(file_audio);
    spreadfiles((i-1)*3+c)=mirgetdata(file_mirspread); %The Spectral spread

    %The Spectral skewness 
    file_mirskewness=mirskewness(file_audio);
    skewnessfiles((i-1)*3+c)=mirgetdata(file_mirskewness); %The Spectral skewness 

    %The Centroid
    file_centroid=mircentroid(file_audio);
    centroidfiles((i-1)*3+c)=mirgetdata(file_centroid); %The Spectral Centroid

    %The Spectral kurtosis
    file_kurtosis=mirkurtosis(file_audio);
    kurtosisfiles((i-1)*3+c)=mirgetdata(file_kurtosis); %The Spectral kurtosis

    %The Spectral flatness
    file_flatness=mirflatness(file_audio);
    flatnessfiles((i-1)*3+c)=mirgetdata(file_flatness); %The Spectral flatness

    %The Entropy of Spectrum
    file_entropy=mirentropy(file_audio);
    entropyfiles((i-1)*3+c)=mirgetdata(file_entropy); %The Entropy of Spectrum

    % %MFCC
    file_mfcc=mirmfcc(file_audio);
    mfccfiles(:,(i-1)*3+c)=mirgetdata(file_mfcc); %MFCC 12 Coef each file ; use (Frames:for segmetation)

    % Roughness 
    %file_roughness=mirroughness(file_audio); % Diff size

    %Pitch
 %   file_pitch=mirpitch(file_audio,'Autocor','Total', 1); 
    %pitchfiles((i-1)*3+c)=mirgetdata(file_pitch); %Pitch

    %inharmonicity
    file_inharmonicity=mirinharmonicity(file_audio);
    inharmonicityfiles((i-1)*3+c)=mirgetdata(file_inharmonicity); %inharmonicity

    % %estimation of tonal center positions
    [file_key file_keyclarity]=mirkey(file_audio);
    bestkeyfiles((i-1)*3+c)=mirgetdata(file_key); %estimation of tonal center positions
    keyclarityfiles((i-1)*3+c)=mirgetdata(file_keyclarity);

    %modality
    file_modality=mirmode(file_audio);
    modalityfiles((i-1)*3+c)=mirgetdata(file_modality); %modality

    %Calculates the 6-dimensional tonal centroid vector from the chromagram.
    file_tonalcentroid=mirtonalcentroid(file_audio);
    tonalcentroidfiles(:,(i-1)*3+c)=mirgetdata(file_tonalcentroid);

    %The Harmonic Change Detection Function (HCDF)
    %file_hcdf=mirhcdf(file_audio); %diff size

    %Harmonic Pitch Class Profile,
    file_chromagram=mirchromagram(file_audio);
    chromagramfiles(:,(i-1)*3+c)=mirgetdata(file_chromagram); %Harmonic Pitch Class Profile  frequencies are missing

    %A similarity matrix shows
    % file_simatrix=mirsimatrix(file_audio);
    % simatrix_temp=mirgetdata(file_simatrix);
    % simatrixfiles(i,:)=simatrix_temp(:)';  %diff size

    clear file_ASR file_beatspectrum file_lowenergy file_rms file_rmsframes file_similaritymatrix ...
        file_tempo file_kurtosis file_centroid file_mirskewness file_mirspread file_entropy file_mfcc ...
        file_inharmonicity file_pitch file_rolloff file_brightness file_key file_keyclarity ...
        file_pulseclarity file_tonalcentroid file_zerocross file_modality file_flatness file_eventdensity ...
        file_chromagram;
end
end
 %Inputs Table 
%rmsfiles=rmsfiles';
%rmsmedianfiles=rmsmedianfiles';
% lowenergyfiles=lowenergyfiles';
%ASRfiles=ASRfiles';
% beatspectrumfiles=beatspectrumfiles';
% eventdensityfiles=eventdensityfiles';
%tempofiles=tempofiles';
% pulseclarityfiles=pulseclarityfiles';
% zerocrossfiles=zerocrossfiles';
% rolloffsfiles=rolloffsfiles';
% brightnessfiles=brightnessfiles';
%spreadfiles=spreadfiles';
% centroidfiles=centroidfiles';
% kurtosisfiles=kurtosisfiles';
% flatnessfiles=flatnessfiles';
% entropyfiles=entropyfiles';
 mfccfiles=mfccfiles';
% pitchfiles=pitchfiles';
% inharmonicityfiles=inharmonicityfiles';
% bestkeyfiles=bestkeyfiles';
% keyclarityfiles=keyclarityfiles';
% modalityfiles=modalityfiles';
tonalcentroidfiles=tonalcentroidfiles';
chromagramfiles=chromagramfiles';
% attackslopefiles=attackslopefiles';
% attackleapfiles=attackleapfiles';
% decreaseslopefiles=decreaseslopefiles';
%simatrixfiles=simatrixfiles';
% onsetsfiles=onsetsfiles';

datesfiles = char(datesfiles');

%  %Create a table, using all info variables
T = table(pathfiles_table, namesfiles,datesfiles,bytesfiles,numchannelsfiles,sampleratefiles,totalsamplesfiles,...
    durationfiles,bitratefiles,rmsfiles,rmsmedianfiles,lowenergyfiles,ASRfiles,...
    beatspectrumfiles,eventdensityfiles,tempofiles,pulseclarityfiles,zerocrossfiles,rolloffsfiles,brightnessfiles,spreadfiles,...
    centroidfiles,kurtosisfiles,flatnessfiles,entropyfiles, mfccfiles,pitchfiles,inharmonicityfiles,bestkeyfiles,keyclarityfiles,...
    modalityfiles,tonalcentroidfiles,chromagramfiles,attackslopefiles,attackleapfiles...
    );
%Export to.cvs File
writetable(T,'myData.csv','Delimiter',',','QuoteStrings',true);
