% produces mtex.snippet with simple latex table text from table input M,
% using the template file "table" (as default)
% 
% Wim van Ekeren, 2022
function T = table(M, varargin)

    prop = varargin(1:2:end);
    vals = varargin(2:2:end);
    
    column_alignment = 'l';
    format = '%g';
    template = 'table';
    
    n_header_col = [];
    n_header_row = [];
    
    outerbox_hline = '';
    outerbox_vline = '';
    
    args_table = {};
    
    for ii=1:numel(prop)
        switch lower(prop{ii})
            case 'header'
                n_header_row = vals{ii};
            case 'columnheader'
                n_header_col = vals{ii};
            case 'columnalignment'
                column_alignment = vals{ii};
            case 'format'
                format = vals{ii};
            case 'outerbox'
                switch lower(vals{ii})
                    case 'v'
                        outerbox_hline = '';
                        outerbox_vline = '|';
                    case 'h'
                        outerbox_hline = ['\hline',newline];
                        outerbox_vline = '';                        
                    case 'all'
                        outerbox_hline = ['\hline',newline];
                        outerbox_vline = '|';                        
                    otherwise
                        outerbox_hline = '';
                        outerbox_vline = '';
                end
            case 'template'
                template = vals{ii};
            otherwise
                args_table{end+1} = prop{ii};
                args_table{end+1} = vals{ii};
        end
    end

    if isempty(M)
        error('Cannot create latex table for empty arrays');
    end
    
    if isa(M,'table')
        header = M.Properties.VariableNames;
        m_data = table2cell(M);
        M = [header;m_data]; 
        if isempty(n_header_row)
            n_header_row=1;
        end
    end
    
    if isempty(n_header_row)
        n_header_row = 0;
    end
    if isempty(n_header_col)
        n_header_col = 0;
    end     
    n_data_col   = size(M,2)-n_header_col;
    
    % outerbox line
    s = outerbox_hline;
    
    % header row
    if n_header_col>0
        column = [outerbox_vline,repmat(column_alignment,1,n_header_col), '|', repmat(column_alignment,1,n_data_col),outerbox_vline];
        s = [s,mtex.array(M(1:n_header_row,:))];
    else
        column = [outerbox_vline,repmat(column_alignment,1,n_data_col),outerbox_vline];
        s = [s,mtex.array(M(1:n_header_row,:))];
    end
    if n_header_row>0
        s = [s,'\hline',newline];
    end    
    
    % the rest of the array
    s = [s,mtex.array(M(n_header_row+1:end,:),format)];
    
    % outerbox line
    s = [s,outerbox_hline];
    
    % make snippet
    T = mtex.snippet(template,...
        'Columns',column,...
        'Array',s,...
        args_table{:});