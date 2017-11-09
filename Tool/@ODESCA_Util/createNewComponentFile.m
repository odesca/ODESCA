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

function createNewComponentFile()
% Starts a dialog to create a new custom component file from a template
%
% SYNTAX
%   ODESCA_Util.createNewComponentFile()
%
% INPUT ARGUMENTS
%
% OPTIONAL INPUT ARGUMENTS
%
% OUTPUT ARGUMENTS
%
% DESCRIPTION
%   This method starts a dialog for the creation of a new custom component
%   file. The file is create from a template.
%
% NOTE
%
% SEE ALSO
%
% EXAMPLE
%

%% Condition used in the method
% =========================================================================
% Set the default arguments for the methode
% =========================================================================


% =========================================================================
% Set the constants used in the method
% =========================================================================

% Array to store the templates available
% The first column stores the name of the option, the second the name of
% the corresponding template file
templateOptions = {'First Order',  'ODESCA_Component_Template_First_Order'}; 

% Warnings to be suppressed
%#ok<*NASGU>
%#ok<*INUSD>

%% Check of the conditions

%% Evaluation of the task
% TODO
%   - Add error tracking
%   - Add tryCatch to file creation
%   - Add more options like Description to add
%   - Add additional templates
%   - Add correct comments
%   - Add check, if selected file does already exist (to prevent
%     overwriting of a file) 

pathOfThisMethod = mfilename('fullpath');
pathStartFolderSearch = strrep(pathOfThisMethod,'Framework\@ODESCA_Util\createNewComponentFile','Components');

% Variable to store the selected folder in
selection.name = ''; % Name the new file should have
selection.file = templateOptions{1,2};  % Template file which is choosen
selection.folder = pathStartFolderSearch; % Folder to create the component in

% ###############################
% ---------- create ui ----------

d = dialog('Position',[300 300 250 245],'Name','New Component');

% ---------- static text ----------
name_label = uicontrol('Parent',d,...
    'Style','text', 'HorizontalAlignment','left',...
    'Position',[20 210 180 20],...
    'String','Name:'); 

file_label = uicontrol('Parent',d,...
    'Style','text','HorizontalAlignment','left',...
    'Position',[20 155 210 20],...
    'String','Selected type:');

folder_label = uicontrol('Parent',d,...
    'Style','text', 'HorizontalAlignment','left',...
    'Position',[20 120 180 20],...
    'String','Selected folder:');


% ---------- dynamic text ----------

name_txt = uicontrol('Parent',d,...
    'Style','edit',...
    'Position',[21 190 213 20],'BackgroundColor','w',...
    'String','','Callback',@name_txt_callback);

folder_txt = uicontrol('Parent',d,...
    'Style','text',...
    'Position',[21 70 213 45],'BackgroundColor','w',...
    'String',selection.folder);

% ---------- buttons and popups ----------

file_ppp = uicontrol('Parent',d,...
    'Style','popup',...
    'Position',[100 150 135 25],...
    'String',templateOptions(:,1),...
    'Callback',@file_ppp_callback,...
    'Enable','off'); % As long as there is no second template ready, disable the choice

folder_btn = uicontrol('Parent',d,'Style', 'pushbutton', 'String', 'Select',...
    'Position', [100 120 135 20],...
    'Callback', @folder_btn_callback );

create_btn = uicontrol('Parent',d,'Style', 'pushbutton', 'String', 'Create Component',...
    'Position', [20 20 130 40],...
    'Callback', @create_btn_callback );

cancel_btn = uicontrol('Parent',d,'Style', 'pushbutton', 'String', 'Cancel',...
    'Position', [150 20 85 40],...
    'Callback', @cancel_btn_callback);

% ---------- callback functions ----------
    function name_txt_callback(source, event) 
        % Set the selected name
        selection.name = source.String;
    end

    function file_ppp_callback(source, event)
        % Set the selected template
        index = source.Value;
        selection.file = templateOptions{index,2};
    end

    function folder_btn_callback(source, event)
        % Set the new folder path if the popup dialog was not aborted
        result = uigetdir(pathStartFolderSearch);
        if(ischar(result))
            selection.folder = result;
            set(folder_txt, 'String', selection.folder );
        end
    end

    function create_btn_callback(source,event)
        % Create the new component file if the selected name is valid
        if(isvarname(selection.name))
            createNewTemplate();
            delete(d);
        else
            warning('The selected name is not valid. Choose a valid matlab variable name.')
        end
    end

    function cancel_btn_callback(source,event)
        % Close the dialog
        delete(d);
    end

    function createNewTemplate()       
        pathOfTemplate = [strrep(pathOfThisMethod,'@ODESCA_Util\createNewComponentFile','ComponentTemplates'),'\',selection.file,'.m'];
        newFile = [selection.folder,'\',selection.name,'.m'];
        
        templateString = fileread(pathOfTemplate);
        changedTemplateString = strrep(templateString,selection.file,selection.name);
        
        fileID = fopen(newFile,'w');
        fwrite(fileID,changedTemplateString);
        fclose(fileID);
        
        open(newFile);
    end

end