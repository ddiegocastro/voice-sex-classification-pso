function [coeffs,delta] = MFCC_coeff(Ain)
    % Objective -> Obtain the Mel Frecuency Cepstral Coefficients of an audio  
    % Input variables:
    % - Ain: The audio signal (must be the name string)
    % Output variables:
    % - coeff: The Cepstral coefficients of the signal.
    % - delta: The change between each coefficient.
    
    % Reading of the file, as a matrix
    [y, Fs] = audioread(Ain);
    
    % y --> Audio signal in stereo
    % Fs --> sampling rate (Hz)
    
    % Duration, in seconds, of the audio
    totDuration = length(y)/Fs;

    % Aplicación del filtro pasa banda para eliminar el ruido eléctrico
    fmin=80; %(Hz)
    fmax=5000; %(Hz)
    
    [bn,an]=butter(4,[fmin fmax]/(Fs/2),"bandpass");

    audio_filt=filtfilt(bn,an,y);

    % Convert audio to mono
    audioMono = mean(audio_filt,2);

    % Only use the 2 - 3 secs, window to ensure the vocal is being said
    % Para los audios que no son de castro (que duren mas de 2 segundos)
    if totDuration > 2
        % Start time for trimming (1 sec)
        t1 = 1*Fs;
        
        % Finish time for trimming (2 sec)
        t2 = 2*Fs;

        % Selecting the wanted window
        audioTrimmed = audioMono(t1:t2);
    else
        % Start time for trimming (0.5 sec)
        t1 = 0.5*Fs;

        % Finish time for trimming (1.5 sec)
        t2 = 1.5*Fs;

        % Selecting the wanted window
        audioTrimmed = audioMono(t1:t2);
    end
    
    % Hamming --> Divide the signal into small components
    win = hamming(round(0.020*Fs),"periodic");
    
    % Has to be less than the window length, if not, an error arises.
    % Overlap --> How much the frames overlaps each other.
    % In this case, is by 10 ms.
    overlap = round(0.010*Fs);
    
    [coeffsMatrix,deltaMatrix] = mfcc(audioTrimmed,Fs,Window=win, OverlapLength=overlap);
    

    % coeffsMatrix:  [numFrames x numCoeffs]
    % deltaMatrix:   [numFrames x numCoeffs]

    % Average over frames (rows) → one value per coefficient
    coeffs = mean(coeffsMatrix, 1).';  % column vector (numCoeffs x 1)
    delta  = mean(deltaMatrix,  1).';  % column vector (numCoeffs x 1)

    % Convert the matrix into column vectors
    % coeffs = reshape(coeffsMatrix,[],1);
    % delta = reshape(deltaMatrix, [], 1);

end