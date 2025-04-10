clear; close all;

folder = fullfile(pwd,'reports','test');
mkdir(folder);

peaks;
saveas(gcf,fullfile(folder,'peaks.png'));
fig_ref = 'peaks'; % latex label for cross-referencing



% Figure element
myfig = mtex.snippet('figure','File','peaks.png','Label',fig_ref);
myfig.getstring
% you may add something to the figure after having it inserted in the
% report
myfig.set('Options','[b]')
myfig.set('Caption','Peak data')

T = table(rand(5,1), rand(5,1));
T.Properties.VariableNames = {'x','y'};
mytable  = mtex.table(T,'OuterBox','h','Caption','Table peak data','OutputFile',fullfile(folder,'mytabdata.tex'));

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
myreport.save
myreport.getstring

