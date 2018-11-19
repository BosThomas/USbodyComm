% DEMO FIR FILTER VISUALISATION
%
%   This script provide 3 demos on how to load and visualise the different
%   FIR channels in this repository.
%
%   Created Nov 16, 2018 by Thomas Bos
%   Last edited Nov 19, 2018
%   Version 1.0
%
% Copyright (c) Thomas Bos, Wim Dehaene, Marian Verhelst
% Katholieke Universiteit Leuven, ESAT-MICAS
% Kasteelpark Arenberg 10
% 3001 Heverlee, Leuven, Belgium
%
% CHANGELOG
%----------
% Can be found at the end of the file

% Matlab memory clear
clear;
close all;

%% DEMO1: Load + Visualise a single channel
%  The first demo loads a single FIR channel via its unique experiment name
%  and provides a time- and frequency-domain representation of the channel.
%
%  In the spectrum, the approx. 130kHz is clearly seen around 1.2MHz.
%  Also, the FIR has a large DC-content, which degrade the time-domain
%  visualisation.

%   Demo Parameters
expName = 'charac_water_40';    % unique experiment name [string]
                                % here: the pure water 40mm distance case
                                % for more info, see load_FIR_channel.m doc
Nplot = 1e3;                    % number of points used for plotting

%   Load impulse response
[h,fs] = load_FIR_channel(expName);
L = length(h);                  % number of taps of FIR

%   Make visualisation
figure('name','channel visualisation');
%   1) time-domain
subplot(211);
h_dc = mean(h);                 % DC gain of impulse response
stem(0:L-1,h-h_dc);       
grid on;
xlabel('Samples'); ylabel('FIR coefficients');
title('Impulse response');
legend(expName,'Interpreter','none');
%   2) freq-domain
subplot(212);
f_sc = 1e-6;	% frequency scale of plot
[H,f] = freqz(h,1,Nplot,fs);   % returns single-sided spectrum
plot(f_sc*f,20*log10(abs(H)));
grid on;
ylim([-70 -20]);
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB]');
title('Single sided channel spectrum');


%% DEMO2: Visualise FIR variance over time
%  The second demo visualses two impulse responses which are captured 
%  approx 1 second apart. As a result, you get an insight in the experiment
%  datastructure that is used for the different experiments.
%
%  The exp.FIR1.h is an 5x2000 matrix containing 5 different measurements
%  of the 2000-taps impulse response. These measurements are separated only
%  1second in time.
%
%  It can be seen that the general spectral shape is very similar, however
%  (small) in-band variations are present.

%   Demo Parameters
expName = 'charac_water_40';    % unique experiment name [string]
                                % here: the pure water 40mm distance case
                                % for more info, see load_FIR_channel.m doc
Nplot = 1e3;                    % number of points used for plotting
     
%   Load experiment datastructure
[~,~,exp] = load_FIR_channel(expName);
%   Select two different impulse responses
h1 = exp.FIR1.h(1,:);
h2 = exp.FIR1.h(2,:);

%   Make visualisation
figure('name','time variance FIR');
%   1) time-domain
subplot(211);
stem(h1-mean(h1)); hold on;   
stem(h2-mean(h2));
xlabel('Samples'); ylabel('FIR coefficients');
title('impulse response short-time variation'); grid on;
legend(strcat(expName,'[1]'),strcat(expName,'[2]'),'Interpreter','none');
%   2) freq-domain
subplot(212);
f_sc = 1e-6;        % frequency scale
[H1,f1] = freqz(h1,1,Nplot,fs);   % single-sided spectrum
[H2,f2] = freqz(h2,1,Nplot,fs);
plot(f_sc*f1,20*log10(abs(H1))); hold on;
plot(f_sc*f2,20*log10(abs(H2)));
grid on; 
ylim([-70 -20]);
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB]');
title('Single sided channel spectrum');


%% DEMO3: Visualise multiple FIR channels
%  The third demo visualses two impulse responses from two different
%  channels. These FIR channels are to be compared on their latency, their
%  attenuation and their spectral characteristics.
%
%  It can be seen that the in-band attenuation follows an approx -6dB where
%  the distance is doubled (40mm -> 80mm).

%   Demo Parameters
expName1 = 'charac_water_40';   % unique experiment name [string]
                                % here: the pure water 40mm distance case
                                % for more info, see load_FIR_channel.m doc
expName2 = 'charac_water_80';   % the pure water 80mm distance case
Nplot = 1e3;                    % number of points used for plotting

%   Load impulse responses
[h1,fs1] = load_FIR_channel(expName1);
[h2,fs2] = load_FIR_channel(expName2);

%   Make visualisation
figure('name','multiple FIR channels');
%   1) time-domain
subplot(211);
plot(h1-mean(h1),'-o');  hold on;
plot(h2-mean(h2),'-v');
xlabel('Samples'); ylabel('FIR coefficients');
title('Multiple impulse responses'); grid on;
legend(expName1,expName2,'Interpreter','none');
%   2) freq-domain
subplot(212);
f_sc = 1e-6;        % frequency scale
[H1,f1] = freqz(h1,1,Nplot,fs);   % single-sided spectrum
[H2,f2] = freqz(h2,1,Nplot,fs);
plot(f_sc*f1,20*log10(abs(H1))); hold on;
plot(f_sc*f2,20*log10(abs(H2)));
grid on;
ylim([-70 -20]);
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB]');
title('single sided channel spectrum');
legend(expName1,expName2,'Interpreter','none');


%%  CHANGELOG
%   ---------------
%
%   v1.0, 19-11-2018    Start of script: writing 3 basic demos + providing
%                       documentation.
