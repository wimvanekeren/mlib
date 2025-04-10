%*************************************************************************%
%
%> This class builds latex code fragments (snippets) by using template files. A
%> template contains latex code and the user can insert text at fields
%> that are marked in the template using <FieldName>, where FieldName is
%> used as identifier.
%>
%> To enable flexible use of templates, a default field "TAIL" is used to
%> insert any content at the end of the template.
%>
%> snippets may be used in a nested structure, i.e., the fields of a parent
%> snippets can be filled with child snippet objects.
%> 
%> If the property outputfilename is set, the parent snippet will insert
%> the child snippets as external file, i.e, with \input{outputfilename}. 
%>
%> @function    snippet     contstructor
%> @function    set         set the content of a field
%> @function    add         add content to the existing content of a field
%> @function    getstring   get the snippet content
%> @function    save        save the snippet (and any child content) as tex
%>                          file
%>
%> @author Wim van Ekeren

classdef snippet < handle
    properties (Access = 'public')
        name
        template
        fields
        outputfilename
        outputpath
    end 
    
    properties (Access = 'private')
        templatepath
    end     
    methods
        
        
        %> @brief Create a new snippet from template
        %>
        %>  @param name: (str) Template tex file without .tex extension. The file
        %> [name,'.tex'] must either exist on path or in /templates
        %>
        %> @param OutputFile full path to filename without the `.m`
        %extension (char vector). If no path is given, it will be saved on
        %the present working directory.
        %> @return snippet object
        function self = snippet(name, varargin)
            
            [p,~,~] = fileparts(mfilename('fullpath'));
            self.templatepath = fullfile(p,'templates'); % default templates folder
            
            self.name = name;
            if nargin==0
                self.template = '';% do nothing - empty template
            elseif isempty(name)
                self.template = '';% do nothing - empty template
            elseif exist([name,'.tex'],'file')
                self.template = fileread([name,'.tex']);
                [p,~,~] = fileparts(which([name,'.tex']));
                self.templatepath = p; % overwrite templates folder if the template .tex file was found somewhere else
            elseif exist(fullfile(self.templatepath,[name,'.tex']),'file')
                self.template = fileread(fullfile(p,'templates',[name,'.tex']));
            else
                error('mtex:snippet:NoTemplate','Template file %s not found.',[name, '.tex']);
            end
            
            self.outputfilename = '';
            self.outputpath = '';
            
            % extract fields and defaults
            [t,m]=regexp(self.template, '<(\w+)([:][^>]*)*>','tokens','match');
            
            self.fields = struct;
            for i=1:numel(t)
                value = {};
                if ~isempty(t{i}{2})
                    value = {t{i}{2}(2:end)};
                end
                self.fields.(t{i}{1}) = value;
            end
            self.fields.TAIL = {};
            
            prop = varargin(1:2:end);
            vals = varargin(2:2:end);
            for i=1:numel(prop)
                
                switch lower(prop{i})
                    case 'outputfile'
                        [p,f,e] = fileparts(vals{i});
                        if isempty(p)
                            self.outputpath = pwd;
                        else
                            self.outputpath = p;
                        end
                        if isempty(e)
                            e = '.tex';
                        end
                        self.outputfilename = strcat(f,e);
                    otherwise
                        self.set(prop{i},vals{i});
                end
            end
        end
        
        %> @brief Set content of the field of a snippet
        %>
        %> @param fieldname (str) field name identifier
        %> @param value     content as snippet or as character
        function set(self,fieldname,value)
            assert(isa(value,'mtex.snippet') || ischar(value),'value must be snippet or char');
            assert(isfield(self.fields,fieldname),sprintf('invalid field %s for template',fieldname))
            self.fields.(fieldname) = {value};
        end
        
        %> @brief Add content to a field.
        %>
        %> snippet.add(fieldname,value)
        %>      add content to field with fieldname as identifier
        %> snippet.add(value)
        %>      add content to TAIL field (the end of the template)
        %
        %> @param fieldname (str) field name identifier.
        %> @param value     content as snippet or as character        
        function add(self,varargin)
            if numel(varargin)==1
                self.fields.TAIL{end+1} = varargin{1};
            else
                component = varargin{1};
                value = varargin{2};
                if ~isfield(self.fields,component)
                    error('component %s does not exist',component);
                end
                self.fields.(component){end+1} = value;
            end
        end
        
        %> @brief Get text of the template with field contents
        %>
        %> if the argument (bool) expandfiles is provided, 
        function S = getstring(self, expandfiles)
            
            if nargin==1
                expandfiles=false;
            end
            
            % make 
            S = self.template;
            compnames = fieldnames(self.fields);
            for ic=1:numel(compnames)
                E = self.fields.(compnames{ic});
                for i=1:numel(E)
                    if ~ischar(E{i})
                        if isempty(E{i}.outputfilename) || expandfiles
                            E{i} = getstring(E{i});
                        else
                            E{i} = sprintf('\\input{%s}\n',E{i}.outputfilename);
                        end
                    end
                end
                
                comptext = [E{:}];
                if isempty(comptext)
                    comptext = '';
                end
                
                % insert content in fields
                if ~strcmp(compnames{ic},'TAIL')
%                   S = strrep(S,['<',compnames{ic},'>'],comptext); %
%                   cannot handle the more complex <Field:default value>
%                   typing
%                   S = regexprep(S, ['<',compnames{ic},'([:][^>]*)*>'],
%                   comptext); % cannot ignore escape characters in
%                   comptext

                    m = regexp(S, ['<',compnames{ic},'([:][^>]*)*>'],'match');
                    for i=1:numel(m)
                        S = strrep(S, m{i}, comptext);
                    end
                else
                    S = [S, comptext];
                end
            end
        end
        
        %> @brief save the snippet as tex file
        %>
        %> @param expandfiles (optional) any child snippets will be inserted
        %> with the full content in the parent file, regardless of whether
        %> the property outputfilename is set.
        function save(self,expandfiles)
            if nargin==1
                expandfiles=false;
            end
            
            % copy template-subfolder contents
            if ~isempty(self.name) && isdir(fullfile(self.templatepath,self.name))
                copyfile(fullfile(self.templatepath,self.name), self.outputpath);
%                 d=dir(fullfile(self.templatepath,self.name));
%                 for ii=1:numel(d)
%                     if length(d(ii).name)>3 % not '.' or '..'
%                         copyfile(fullfile(d(ii).folder,d(ii).name), self.outputpath);
%                     end
%                 end
            end 
            
            % save all sub snippet elements recursively
            compnames = fieldnames(self.fields);
            if ~expandfiles
                for i=1:numel(compnames)
                    comp = compnames{i};
                    for j=1:numel(self.fields.(comp))
                        if isa(self.fields.(comp){j},'mtex.snippet')
                            self.fields.(comp){j}.save(expandfiles);
                        end
                    end
                end
            end
            
            % save file if output filename is given
            if ~isempty(self.outputfilename)
                f = fullfile(self.outputpath,self.outputfilename);
                fid = fopen(f,'w');            
                s=self.getstring(expandfiles);
                fprintf(fid,'%s',s);
                fclose(fid);
                fprintf('Saved %s\n',fullfile(self.outputpath,self.outputfilename));
            end
        end

    end
    
end