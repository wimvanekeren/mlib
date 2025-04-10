% Consider the example that you want to create a latex report into a folder
% at "./reports/test". Lets make a super basic latex report using a couple
% of snippets provided in the ./templates/ folder. We are adding a dummy
% figure in png format, embed it in a section, which is part of a chapter.
clear; 
close all;

% folder location of latex code
folder = fullfile(pwd,'reports','test');
mkdir(folder);

% Create example figure in matlab, and save it in the output folder
peaks;
saveas(gcf,fullfile(folder,'peaks.png'));
fig_ref = 'peaks'; % latex label for cross-referencing

% Figure
% --------
% Create a Figure element, representing the latex code for a figure. It
% gets the snippet code in ./templates/figure, and with the additional
% arguments the snippet "fields" can be filled out. For example, we are
% setting the <File> field in the snippet to "peaks.png" and <Label> to the
% fig_ref variable (which is defined as 'peaks').
snippet_name = 'figure';
myfig = mtex.snippet(snippet_name,'File','peaks.png','Label',fig_ref);

% After creation, you can see what is the latex code corresponding to this
% object:
myfig.getstring

% You may add something to the figure after having it inserted in the
% report, by setting any field:
myfig.set('Options','[b]')
myfig.set('Caption','Peak data')

% Tables in +mtex
% ---------------
% Now let's add a table to the report. For this, there is a specific
% function mtex.table() to help us with all the code for the table

% create table with randum numbers (as matlab table)
T = table(rand(5,1), rand(5,1));
T.Properties.VariableNames = {'x','y'};

% create mtex table element, which is a snippet object with the table latex
% code.
mytable  = mtex.table(T,'OuterBox','h','Caption','Table peak data','OutputFile',fullfile(folder,'mytabdata.tex'));

% Chapter and final report
% --------------------------
% Analysis Chapter
peak_analysis = mtex.snippet('chapter','Title','Peak analysis');
peak_analysis.add(['The data can be seen in figure \ref{',fig_ref,'}',newline]);

peak_analysis.add(mytable);
peak_analysis.add(myfig);

% Final Report
myreport = mtex.snippet('report',...
    'OutputFile',fullfile(folder,'main.tex'),...
    'Title','Example Report with Peaks Data Analysis',...
    'Date',datestr(now),...
    'Author','Wim van Ekeren');
myreport.add('Body',peak_analysis);

% save and display
% --------------------------
myreport.save
myreport.getstring

