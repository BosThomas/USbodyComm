function [h,fs,varargout] = load_FIR_channel(expName,varargin)
%LOAD_FIR_CHANNEL Returns the FIR channel of the requested experiment.
%   INPUTS
%       expName     experiment name [string] in following format:
%                       <commConcept>_<phantom>_<distance>[_var<x>]
%                   More details on this naming convention are provided 
%                   below in the "documentation" section.
%
%   OPTIONAL INPUTS
%       'random'    returns a random impulse response, selected from all
%                   available impulse responses in the experiment.
%
%   OUTPUTS
%       h           2000-taps passband impulse response
%       fs          corresponding sample frequency [Samp/s]
%
%   EXAMPLES
%       [h,fs] = LOAD_FIR_CHANNEL('charac_water_80');   
%           Default operation of the function. Returns a single 2000-taps
%           impulse response h of the requested experiment. By default the
%           FIR1.h(1,:) impulse response is returned.
%
%       [h,fs] = LOAD_FIR_CHANNEL('charac_water_80','random');
%           Returns a random impulse response, selected from all different
%           FIR<x>.h(y,:) options.
%
%       [~,~,exp] = LOAD_FIR_CHANNEL('charac_water_80');
%           Returns the entire 'experiment datastructure' of the requested
%           experiment. Varargin input such as 'random' has no effect.
%
%   Created Nov 15, 2018 by Thomas Bos
%   Last edited Nov 19, 2018
%   Version 1.1
%
% CHANGELOG
%----------
% Can be found at the end of the file

%% LICENSING
%
% ISC license
%
% Copyright (c) 2018, Thomas Bos
% KU Leuven, ESAT-MICAS
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

%% DOCUMENTATION
%   This repository provides finite impulse response (FIR) models of
%   ultrasound in-body mimicking channels.
%   In brief, different gelatin-phantoms were characterised in a custom-made 
%   anechoic water tank. The used US transducers were omnidirectional
%   radiating and have an approx 130kHz BW response at 1.2MHz center
%   frequency. For more information regarding the setup or the measurement
%   procedure, we refer to the accompanying paper:
%       T.Bos et al. "Enabling Ultrasound In-Body Communication: FIR Channel 
%       Models and QAM Experiments", IEEE Transactions on Biomedical Circuits 
%       and Systems, 2018 (Early Access) (DOI 10.1109/TBCAS.2018.2880878)
%
%   There are 3 categories of experiments, featuring different 'in-body 
%   communication concepts':
%       * characterisation  -- characterisation of the anechoic watertank,
%                           providing the full electro-acoustic system 
%                           response without any phantom.
%       * implant2implant   -- through phantom measurement, while the phantom 
%                           is submersed in anechoic watertank (which mimics
%                           implant to implant communication)
%       * surface2surface   -- through phantom measurement, while phantom 
%                           is surrounded by air (which mimics
%                           surface to surface communication)
%
%   Each such 'communication concept' combines different 'experiments' 
%   where the 'phantom-under-test' is changed to test varying distances and
%   changing scattering materials (chicken bones).
%   
%   Each 'experiment' is represented by a unique name, with the following 
%   convention:
%
%           <commConcept>_<phantom>_<distance>[_var<x>]
%
%   For example, the implant2implant measurement of the gelatin 80mm long
%   phantom, is given by its name: "impl2impl_gelatin_80".
%   As a second example, the characterisation measurement of the 40mm long
%   water channel is: "charac_water_40".
%   Some experiments are repeated where the transducer positioning is
%   slightly changed (order of mm) to test the robustness to small
%   variations. These experiments are indicated by the optional "_var<x>"
%   ending.
%   For example, a small variation of the surface2surface measurement of
%   the gelatin 80mm long phantom: "surf2surf_gelatin_80_var1".
%   A complete list of all experiments is provided below.
%
%   Each 'experiment' contains an identical data structure:
%       FIR1    .h      2000-taps real-valued (passband) impulse response.
%                       5x repeated acquisition and estimation within 1sec 
%                       range to assess statistical behavior
%                       format: matrix [5x2000]
%               .fs     sampling rate of h (typical 5MS/s)
%                       format: scalar [Samp/sec]
%       FIR2    Identical datastructure as FIR1, where measurements are
%               captured using a new white noise transmit sequence.
%               By consequence, the FIR1 and FIR2 measurements are approx.
%               30sec separated in time.
%   The water experiments were carried out twice, without changing the
%   physical setup. These experiments have two extra FIR-datastructures, 
%   which are separated in time from the FIR1 and FIR2 measurements on an 
%   approx. 1 min scale:
%       FIR3    identical datastructure as FIR1
%       FIR4    identical datastructure as FIR1
%   Extra metadata is attached to each experiment:
%       name        the unique measurement name [string]
%       metadata    extra metadata of the experiment [struct]:
%           .commConcept    the 'communication concept' [string]
%           .phantom        the 'phantom type' [string]
%           .distance       the transmission distance [mm]
%           .var            the optional variation number (eg. 'var1') [string]
%           .varDetails     where .var is non-empty, this field gives some
%                           details about this variation
%   
%   COMPLETE LIST OF ALL FIR CHANNEL NAMES:
%       ---
%       charac_water_<d>            characterisation measurements; d = 1, 20, 40, 80 [mm]
%       ---
%       impl2impl_gelatin_<d>       implant2implant measurement; d = 20, 40 and 80 [mm]
%       impl2impl_bone_80           bone-phantom 80mm long (bone parallel to LOS; not-blocking)
%       impl2impl_bone_80_var1      variation: bone into the LOS; blocking
%       impl2impl_bone_30           bone-phantom 30mm long (which is bone_80 side-turned; bone is blocking)
%       ---
%       surf2surf_gelatin_80            surface2surface measurement 80mm long phantom
%       surf2surf_gelatin_80_var<x>     different variations; x = 1,2,3; (each a slight repositioning of Tx/Rx transducers in gel blob)
%       surf2surf_gelatin_40            surface2surface measurement 40mm long phantom
%       surf2surf_gelatin_40_var<x> 	different variations; x = 1,2; (each a slight repositioning of Tx/Rx transducers in gel blob)
%       surf2surf_gelatin_20            surface2surface measurement 20mm long phantom
%       surf2surf_gelatin_20_var1       variation; a slight repositioning of Rx transducers in gel blob
%       surf2surf_bone_80               surface2surface measurement 80mm long bone-phantom
%       surf2surf_bone_80_var<x>        different variations; x = 1,2,3; (each a slight repositioning of Tx/Rx transducers in gel blob)
%       surf2surf_bone_40               bone-phantom 40mm long (which is bone_80 side-turned to other, i.e. 40mm long, side)
%       surf2surf_bone_40_var<x>        different variations; x = 1,2; (each a slight repositioning of Tx/Rx transducers in gel blob)
%
%   NOTES
%       The .FIR2 and _var<x> are both variations on a certain channel 
%       setup, but they are not of an equal type of variation! The .FIR2
%       impulse response is measured on an identical setup, whithout any
%       physical change made, it is only approx 30s further in time.
%       This while the _var<x> measurements do represent physical
%       variations, where e.g. the transducer positioning is slightly 
%       changed.

%% FUNCTION CODE

% ---------------------------------------------------------------------- %
% INPUT VARIABLES
% ---------------------------------------------------------------------- %
% Minimum required nr of inputs
nr_required_inputs = 1;
narginchk(nr_required_inputs,inf);  % throws error if outside ranges

% Process variable input
%   default values
flag_random = false;    % deterministic output by default [boolean]

%   replace by variable input
if exist('varargin','var') && length(varargin) > 1
    for ii = 1:1:length(varargin)
        switch lower(varargin{ii})
            case 'random'
                flag_random = true;
            otherwise
                error('Varargin input ''%s'' not supported',varargin{ii});
        end
    end
end

% Check inputs
if ~ischar(expName)
    error('expName input is no character, but "%s" instead',class(expName));
end
tmp = regexp(expName,'_','split');
if length(tmp) < 3
    error('No correct experiment name format provided: "%s" (should be <commConcept>_<phantom>_<distance>[_var<x>])',expName);
end
commConcept = tmp{1};
phantom = tmp{2};   %#ok<NASGU>
distance = tmp{3};  %#ok<NASGU>

% ---------------------------------------------------------------------- %
% LOAD EXPERIMENT
% ---------------------------------------------------------------------- %
try
    exp = load(strcat('data/',commConcept,'/',expName));
catch E
    error('Experiment name "%s" does not exist. Refer to documentation for valid names',expName);
end

% ---------------------------------------------------------------------- %
% OUTPUT HANDLING
% ---------------------------------------------------------------------- %
if flag_random
    nrFIRs = 5*sum(strncmp('FIR',fieldnames(exp),3));   % total number of FIRs in experiment name
    k = randi([0 nrFIRs-1],1);                          % generate random number
    FIR_id = sprintf('FIR%d',floor(k/5)+1);
    h_id = mod(k,5)+1;
    h = exp.(FIR_id).h(h_id,:);                         % output impulse response h
    fs = exp.FIR(FIR_id).fs;
else
    h = exp.FIR1.h(1,:);                                % default output h
    fs = exp.FIR1.fs;
end

% Optional output allocation
if nargout > 2
    varargout{1} = exp;
end


end

%% CHANGELOG
%  ---------------
%
%   v1.0, 15-11-2018    Start of script: documentation, data loading,
%                       output processing.
%   v1.1, 19-11-2018    Documentation update
%                       Added try-catch around "load"
