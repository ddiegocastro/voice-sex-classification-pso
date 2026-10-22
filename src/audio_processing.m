function [coeffM, deltaM, coeffH, deltaH, vowelM, genderM, vowelH, genderH] = audio_processing(numAudiosM, numAudiosH)
    % audio_processing
    %  - numAudiosM: number of female speakers
    %  - numAudiosH: number of male speakers
    %
    % Output:
    %  - coeffM: [numAudiosM*5  x numCoeffs]  (Mujer)
    %  - deltaM: [numAudiosM*5  x numCoeffs]
    %  - coeffH: [numAudiosH*5  x numCoeffs]  (Hombre)
    %  - deltaH: [numAudiosH*5  x numCoeffs]
    %  - vowelM, genderM: labels aligned with rows of coeffM/deltaM
    %  - vowelH, genderH: labels aligned with rows of coeffH/deltaH
    %
    % Each row = one audio (one person, one vowel).
    % Columns = MFCC coefficient 1, 2, ..., numCoeffs.

    % Folder where this function is located
    thisDir = fileparts(mfilename('fullpath'));

    % Base folders for each sex
    folderM = fullfile(thisDir, 'audios', 'Mujer');
    folderH = fullfile(thisDir, 'audios', 'Hombre');

    %% ================== MUJERES (M) ==================
    coeffA = []; deltaA = [];
    coeffE = []; deltaE = [];
    coeffI = []; deltaI = [];
    coeffO = []; deltaO = [];
    coeffU = []; deltaU = [];

    for i = 1:numAudiosM

        % --- A ---
        fileA = fullfile(folderM, sprintf('V%03d_M_A.mp3', i));
        [coeffVec, deltaVec] = MFCC_coeff(fileA);
        coeffA = [coeffA; coeffVec.'];   % 1 x numCoeffs
        deltaA = [deltaA; deltaVec.'];

        % --- E ---
        fileE = fullfile(folderM, sprintf('V%03d_M_E.mp3', i));
        [coeffVec, deltaVec] = MFCC_coeff(fileE);
        coeffE = [coeffE; coeffVec.'];
        deltaE = [deltaE; deltaVec.'];

        % --- I ---
        fileI = fullfile(folderM, sprintf('V%03d_M_I.mp3', i));
        [coeffVec, deltaVec] = MFCC_coeff(fileI);
        coeffI = [coeffI; coeffVec.'];
        deltaI = [deltaI; deltaVec.'];

        % --- O ---
        fileO = fullfile(folderM, sprintf('V%03d_M_O.mp3', i));
        [coeffVec, deltaVec] = MFCC_coeff(fileO);
        coeffO = [coeffO; coeffVec.'];
        deltaO = [deltaO; deltaVec.'];

        % --- U ---
        fileU = fullfile(folderM, sprintf('V%03d_M_U.mp3', i));
        [coeffVec, deltaVec] = MFCC_coeff(fileU);
        coeffU = [coeffU; coeffVec.'];
        deltaU = [deltaU; deltaVec.'];
    end

    % Stack all vowels: each row is (person, vowel)
    coeffM = [coeffA; coeffE; coeffI; coeffO; coeffU];   % [numAudiosM*5 x numCoeffs]
    deltaM = [deltaA; deltaE; deltaI; deltaO; deltaU];

    % --- Labels for M (Mujer) ---
    % Order matches the stacking above: A block, E block, I block, O block, U block
    vowelM = [ repmat("A", numAudiosM, 1);
               repmat("E", numAudiosM, 1);
               repmat("I", numAudiosM, 1);
               repmat("O", numAudiosM, 1);
               repmat("U", numAudiosM, 1) ];

    genderM = repmat("M", size(coeffM, 1), 1);   % or "Mujer" if you prefer


    %% ================== HOMBRES (H) ==================
    coeffA = []; deltaA = [];
    coeffE = []; deltaE = [];
    coeffI = []; deltaI = [];
    coeffO = []; deltaO = [];
    coeffU = []; deltaU = [];

    for i = 1:numAudiosH

        % --- A ---
        fileA = fullfile(folderH, sprintf('V%03d_H_A.mp3', i));
        [coeffVec, deltaVec] = MFCC_coeff(fileA);
        coeffA = [coeffA; coeffVec.'];
        deltaA = [deltaA; deltaVec.'];

        % --- E ---
        fileE = fullfile(folderH, sprintf('V%03d_H_E.mp3', i));
        [coeffVec, deltaVec] = MFCC_coeff(fileE);
        coeffE = [coeffE; coeffVec.'];
        deltaE = [deltaE; deltaVec.'];

        % --- I ---
        fileI = fullfile(folderH, sprintf('V%03d_H_I.mp3', i));
        [coeffVec, deltaVec] = MFCC_coeff(fileI);
        coeffI = [coeffI; coeffVec.'];
        deltaI = [deltaI; deltaVec.'];

        % --- O ---
        fileO = fullfile(folderH, sprintf('V%03d_H_O.mp3', i));
        [coeffVec, deltaVec] = MFCC_coeff(fileO);
        coeffO = [coeffO; coeffVec.'];
        deltaO = [deltaO; deltaVec.'];

        % --- U ---
        fileU = fullfile(folderH, sprintf('V%03d_H_U.mp3', i));
        [coeffVec, deltaVec] = MFCC_coeff(fileU);
        coeffU = [coeffU; coeffVec.'];
        deltaU = [deltaU; deltaVec.'];
    end

    coeffH = [coeffA; coeffE; coeffI; coeffO; coeffU];
    deltaH = [deltaA; deltaE; deltaI; deltaO; deltaU];

    % --- Labels for H (Hombre) ---
    vowelH = [ repmat("A", numAudiosH, 1);
               repmat("E", numAudiosH, 1);
               repmat("I", numAudiosH, 1);
               repmat("O", numAudiosH, 1);
               repmat("U", numAudiosH, 1) ];

    genderH = repmat("H", size(coeffH, 1), 1);   % or "Hombre"

end
