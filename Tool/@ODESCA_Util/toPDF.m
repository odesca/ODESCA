% Copyright 2017 Tim Grunert, Christian Schade, Lars Brandes, Sven Fielsch,
% Claudia Michalik, Matthias Stursberg
%
% This file is part of ODESCA.
% 
% ODESCA is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published 
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% ODESCA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with ODESCA.  If not, see <http://www.gnu.org/licenses/>.

function toPDF(obj, numDigits, useShortParameter)
% Creates a .pdf which documents a ODESCA_Object class in latex style
%
% SYNTAX
%
% INPUT ARGUMENTS
%   obj:    Instance of the object where the methode was
%           called. This parameter is given automatically.
%
% OPTIONAL INPUT ARGUMENTS
%   numDigits: number of digits used to show the numeric parts of the
%              equations
%              The default number of digits shown is 5.
%   useShortParameter: boolean to determine if the parameters should be
%                      shown in short form. If true, all parameters are
%                      shown with symbolicvariables p1, p2, etc. 
%                      This decreases the length of the equations.
%                      The default option is false.
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This function creates a .pdf file where the object the function was
%   called with is shown in latex style.
%
% NOTE
%   - This function creates a folder called 'Latex_Doc' in the current
%     folder where 
%   - For this function the command 'pdflatex' which is part of MiKTeX 
%     (Version 2.9 used)
%
% SEE ALSO
%
% EXAMPLE
%

%% Check the input arguments
% Check the first input argument is a subclass of ODESCA_Object
if( ~isa(obj,'ODESCA_Object') )
    error('ODESCA_Util:objectToLatexPDF:wrongClassAsArgument','The input argument ''obj'' has to be a subclass of ODESCA_Object.');
end

% Set the default number of digits
if(nargin < 2)
    numDigits = 5;
end

% Set the default behavior for parameters
if(nargin < 3)
    useShortParameter = false;
end

%% Create everything needed
% Create folder to save files
targetFolder = 'Latex_Doc';
if(~isdir(targetFolder))
    mkdir(targetFolder);
end
% Set number of digits to be shown
oldDigits = digits(numDigits);

f = vpa(obj.f);

if(useShortParameter)
% Replace the parameters with shorter symbolic parameters
longParam = obj.p;
shortParam = sym('p',[numel(longParam),1]);
f = subs(f,longParam,shortParam);
end

% Create a list of all symbolic variables
before = symvar(f);
symNum = numel(before);

before_str = cell(symNum,1);
for i = 1:symNum
    before_str{i} = char(before(i));
end

% create a list to replace the symbolic variables for the case their names
% contain an underscore
after_str = cell(symNum,1);
for i = 1:symNum
    temp = ['REPLACE',num2str(i),'VAR'];
    after_str{i} = temp;
end

% Replace the symbolic variables with their placeholders
f = subs(f,before_str,after_str);

% Create an array to store every equation
f_latex_str = cell(numel(f),1);

% Convert the expression to latex string
for i = 1:numel(f)
    f_latex_str{i} = latex(f(i));
end


% Replace the placeholders with the variable names and mask backslashes
for i = 1:numel(before)
    % Its possible to convert the variables with sorrunding statements
    f_latex_str = strrep(f_latex_str,after_str{i},before_str{i});
end
f_latex_str = strrep(f_latex_str,'_','\_');
f_latex_str = strrep(f_latex_str,'\,','\cdot');

for i = 1:numel(f)
    f_latex_str{i} = ['\mathrm{\dot{x}_{',num2str(i),'}} = ', f_latex_str{i}];
end

% Create a description of the states and inputs
states_str = cell(numel(f),1);
for i = 1:numel(f);
    name = strrep(obj.stateNames{i},'_','\_');
    states_str{i} = ['\mathrm{x_{',num2str(i),'}} = \mathrm{''',name,'''}'];
end

input_str = cell(numel(obj.u),1);
for i = 1:numel(obj.u);
    name = strrep(obj.inputNames{i},'_','\_');
    input_str{i} = ['\mathrm{u',num2str(i),'} = \mathrm{''',name,'''}'];
end

if(useShortParameter)
param_str = cell(numel(longParam),1);
for i = 1:numel(longParam)
    name = strrep(char(longParam(i)),'_','\_');
    param_str{i} = ['\mathrm{',char(shortParam(i)),'} = \mathrm{''',name,'''}'];
end
end

%% Write a latex file
% Open file and create header
fileID = fopen([targetFolder,'\MatlabToLatex.tex'],'w');
fprintf(fileID, ['\\documentclass{article}\n', ...
    '\\begin{document}\n',...
    ]);

% Add equations
for i = 1:numel(f)
    fprintf(fileID, '\\[');
    fprintf(fileID, strrep(f_latex_str{i},'\','\\'));
    fprintf(fileID, '\\]\n');
end

% Add description of the states and inputs
fprintf(fileID,'\n\\textbf{where}\n\n');

for i = 1:numel(f)
    fprintf(fileID,'\\[');
    fprintf(fileID, strrep(states_str{i},'\','\\'));
    fprintf(fileID,'\\]\n');
end

if(useShortParameter)
    fprintf(fileID,'\n\\textbf{,}\n\n');
else
    fprintf(fileID,'\n\\textbf{and}\n\n');
end

for i = 1:numel(obj.u)
    fprintf(fileID,'\\[');
    fprintf(fileID, strrep(input_str{i},'\','\\'));
    fprintf(fileID,'\\]\n');
end

if(useShortParameter)
fprintf(fileID,'\n\\textbf{and}\n\n');

for i = 1:numel(longParam)
    fprintf(fileID,'\\[');
    fprintf(fileID, strrep(param_str{i},'\','\\'));
    fprintf(fileID,'\\]\n');
end
end

% Add end of file
fprintf(fileID, '\\end{document}');
fclose(fileID);

%% Create pdf from text file and open it, if the file is not already open
cd(targetFolder)
fileID = fopen('MatlabToLatex.pdf','a');
if(fileID == -1)
    warning('ODESCA_Util:objectToLatexPDF:MatlabToLatexAlreadyOpen','The pdf file could not be created because a file with the same name is already open or has no write access.');
else
    fclose(fileID);
    !pdflatex MatlabToLatex.tex
    open('MatlabToLatex.pdf');
end
cd ..

% Reset the number of shown digit to the old value
digits(oldDigits);

end