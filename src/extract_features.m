% Batch MFCC extraction for all speakers -> coefficients_Mujer.csv / coefficients_Hombre.csv.
% Plain-text export of live_scripts/*.mlx (code cells only).

clc
clear

% Count people (use only one vowel to count individuals)
numAudiosM = length(dir(fullfile('audios','Mujer','*_M_A.mp3')));
numAudiosH = length(dir(fullfile('audios','Hombre','*_H_A.mp3')));

[coeffM, deltaM, coeffH, deltaH, vowelM, genderM, vowelH, genderH] = ...
    audio_processing(numAudiosM, numAudiosH);


M = array2table(coeffM);
M.vowelM = vowelM;
M.genderM = genderM;

H = array2table(coeffH);
H.vowelH = vowelH;
H.genderH = genderH;

% Save the tables as files
writetable(M, 'coefficients_Mujer.csv');
writetable(H, 'coefficients_Hombre.csv');
