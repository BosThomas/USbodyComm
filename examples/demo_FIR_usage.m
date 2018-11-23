% DEMO FIR CHANNEL USAGE
%
%   This script provides a demo on a simple passband BPSK signalthat is
%   transmitted through a selected FIR channel.
%
%   Created Nov 19, 2018 by Thomas Bos
%   Last edited Nov 19, 2018
%   Version 1.0
%
% ISC License
% Copyright (c) 2018, Thomas Bos, Wim Dehaene, Marian Verhelst
% Katholieke Universiteit Leuven, ESAT-MICAS
% Kasteelpark Arenberg 10
% 3001 Heverlee, Leuven, Belgium
%
% Permission to use, copy, modify, and/or distribute this software for any
% purpose with or without fee is hereby granted, provided that the above
% copyright notice and this permission notice appear in all copies.
%
% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
% ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
% OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
%
% CHANGELOG
%----------
% Can be found at the end of the file

% Matlab memory clear
clear;
close all;


%% DEMO
%   Demo Parameters
expName = 'charac_water_40';    % unique experiment name [string]
                                % here: the pure water 40mm distance case
                                % for more info, see load_FIR_channel.m doc
N = 10e3;           % number of transmitted bits
fs_bb = 100e3;      % baseband sampling frequency [Hz]
fc = 1.12e6;        % center frequency [Hz]
Nplot = 1e3;        % number of points used for plotting

%   Load impulse response
[h,fs_chan] = load_FIR_channel(expName);

% -- Generate BPSK passband transmit signal
% Generate random bpsk sequence
bb_tx = 2*randi([0 1],N,1)-1;
% Upsample waveform
R = round(fs_chan/fs_bb);           % upsampling factor
if abs(R-fs_chan/fs_bb) > 6*eps(fs_chan)
    error('please use integer resample ratios');
end
bb_intp_tx = interp(bb_tx,R,10,0.8);  % default interpolation function
% Mix to passband
t = (0:length(bb_intp_tx)-1)'*1/fs_chan;
pb_tx = bb_intp_tx.*cos(2*pi*fc*t);

% -- Transmit passband signal through channel
pb_rx = filter(h,1,pb_tx);
fprintf(' applied channel: %s \n',expName);

% -- Extract received waveform specs
% 1) Delay
maxlag = round(fs_chan*100e-6);     % maxlag in [samples]
[C,lags] = xcorr(pb_tx,pb_rx,maxlag);
[~,idx_Cmax] = max(abs(C));
chan_lag = lags(idx_Cmax);
chan_delay = chan_lag/fs_chan;      % delay of channel [s]
fprintf(' delay of channel: %3.4f us \n',chan_delay*1e6);
%  A small sidenote on the channel delay:
%   The channel delay will always be close to 30us, for any experiment at
%   any transmission distance. This is due to the specific FIR estimation
%   procedure carried out in these experiments. This way, a good estimate
%   on the FIR impulse response was achieved containing its main path and
%   following reflecting paths.
%
%   In case you specifically wants to use the correct main-pulse latency,
%   you should calculate the present channel delay (see code above) and
%   then insert the correct latency using a c = 1480m/s propagation speed.

% 2) Attenuation
chan_gain = rms(pb_rx)/rms(pb_tx);
fprintf(' passband gain of channel: %3.4f V/V (%2.2f dB) \n',chan_gain,20*log10(chan_gain));

% -- Visualisation
figure('name','simple BPSK transmitter');

% 1) TRx waveform plot
subplot(211);
f_sc = 1e-6;    % frequency scale
%   Limit number of points for fft-operation
L = length(pb_tx);
if L > 2^17
    L = 2^17;
    pb_rx = pb_rx(1:L);
    pb_tx = pb_tx(1:L);
end
H_TX = fft(pb_tx); A_TX = H_TX(1:L/2+1)/L; A_TX(2:end-1) = 2*A_TX(2:end-1);   % single-sided spectrum
H_RX = fft(pb_rx); A_RX = H_RX(1:L/2+1)/L; A_RX(2:end-1) = 2*A_RX(2:end-1);
f = fs_chan*(0:L/2)/L;      % corresponding frequency vector
plot(f_sc*f,20*log10(abs(A_TX))); hold on;
plot(f_sc*f,20*log10(abs(A_RX)));
grid on;
ylim([-120 -20]);
xlim([0.5 2]);
xlabel('Frequency [MHz]'); ylabel('Amplitude [dB]');
legend('tx passband','rx passband');
title('Single sided waveform spectrum');

% 2) channel plot
subplot(212);
f_sc = 1e-6;                        % frequency scale of plot
[H,f] = freqz(h,1,Nplot,fs_chan);
plot(f_sc*f,20*log10(abs(H)));
grid on;
xlim([0.5 2]);
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB]');
title('Single sided channel spectrum');
legend(expName,'Interpreter','none');
yline(20*log10(chan_gain),'--k','DisplayName','passband gain of channel');


%%  CHANGELOG
%   ---------------
%
%   v1.0, 19-11-2018    Start of script: write demo 1 + provide
%                       documentation.
