function varargout = gui(varargin)
    clc
    addpath('D:\Data\Data_analysis\moving_average');
    addpath('D:\Data\Data_analysis\convertTDMS');
    addpath('D:\Data\Data_analysis\polyplot');
    addpath('D:\Data\Data_analysis\menu');
    addpath('D:\Data\Data_analysis\NC_filling_evaluation');
    addpath('D:\Data\Data_analysis\errors');
    addpath('D:\Data\Data_analysis\errorbarxy');
    addpath('D:\Data\Data_analysis\calibration');

    % GUI MATLAB code for gui.fig
    %      GUI, by itself, creates a new GUI or raises the existing
    %      singleton*.
    %
    %      H = GUI returns the handle to a new GUI or the handle to
    %      the existing singleton*.
    %
    %      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in GUI.M with the given input arguments.
    %
    %      GUI('Property','Value',...) creates a new GUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before gui_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to gui_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %

    % Edit the above text to modify the response to help gui
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % cd('D:\Data\Data_analysis');
    % End initialization code - DO NOT EDIT

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, ~, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to gui (see VARARGIN)
    % Choose default command line output for gui
    handles.output = hObject;
    handles.userChoice=1;
    handles.plotcounter=0;
    handles.clear_old_flag=0;
    logo=imread('precise_logo.png');
    axes(handles.logo_axes);
    imshow(logo);
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes gui wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(~, ~, handles) 


% Get default command line output from handles structure
varargout{1} = handles.output;
h = findobj('Tag','pushbutton1');
varargout{2} = getappdata(h,'result');



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, ~, handles)

% Determine the selected data set.
      str = get(hObject,'String');
      val = get(hObject,'Value');
      % Set current data to the selected data set.
      switch str{val};
      case 'Single folder'
         handles.userChoice = 1;
      %case 'Set of folders'
        % handles.userChoice = 2;        
      case 'Single file'
         handles.userChoice = 3;
      end

      guidata(hObject,handles);
      


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in process_btn.
function process_btn_Callback(hObject, ~, handles)
    clear steam coolant facility NC distributions file BC GHFS MP timing
    userChoice=handles.userChoice;

    % based on user choice, acces and process picked files
    clear_flag=0;
    plot_flag=get(handles.plotflag_checkbox,'Value');
    st_state_flag=get(handles.st_state,'Value');
    boundary_layer_options(1)=str2double(get(handles.av_window,'String'));
    boundary_layer_options(2)=str2double(get(handles.lim_factor,'String'));
    boundary_layer_options(3)=str2double(get(handles.position_lim,'String'));
    [steam, coolant, facility, NC, distributions, file, BC, GHFS, MP,timing]=gui_main(userChoice,plot_flag,st_state_flag,boundary_layer_options,clear_flag);
    
    %transfer data to handles structure
    handles.steam=steam;
    handles.coolant=coolant;
    handles.facility=facility;
    handles.NC=NC;
    handles.file=file;
    handles.BC=BC;
    handles.GHFS=GHFS;
    handles.MP=MP;
    handles.timing=timing;
    handles.distributions=distributions;
   
    % push the data to main workspace, just in case
    assignin('base','steam',handles.steam)
    assignin('base','coolant',handles.coolant)
    assignin('base','facility',handles.facility)
    assignin('base','file',handles.file)
    assignin('base','distributions',handles.distributions)
    assignin('base','NC',handles.NC)
    assignin('base','BC',handles.BC)
    assignin('base','GHFS',handles.GHFS)
    assignin('base','MP',handles.MP)
    assignin('base','timing',handles.timing)

    % based on what variables are present, set possible choices to
    % popupmenus for plotting
    vars={'steam','coolant','facility','NC','BC','GHFS','MP'};

    set(handles.popupmenu_x_axis,'String',vars)
    set(handles.popupmenu_y_axis,'String',vars)

    %two lines below reset popupmenu values to first object on the list
    set(handles.popupmenu_x_axis,'Value',1);
    set(handles.popupmenu_y_axis,'Value',1);
    set(handles.popupmenu_x_axis_var,'Value',1);
    set(handles.popupmenu_y_axis_var,'Value',1);

    %update variables popupmenus
    command1=['set(handles.popupmenu_x_axis_var,''String'',fieldnames(handles.',vars{1},'))'];
    command2=['set(handles.popupmenu_y_axis_var,''String'',fieldnames(handles.',vars{1},'))'];
    eval(command1)
    eval(command2)
    guidata(hObject, handles)
    
    % --- Executes on button press in reprocess_btn.
function reprocess_btn_Callback(hObject, eventdata, handles)

%essentially the same as process, but with different flag
    clear steam coolant facility NC distributions file BC GHFS MP timing
    userChoice=handles.userChoice;

    % based on user choice, access and process picked files
    clear_flag=1;
    plot_flag=get(handles.plotflag_checkbox,'Value');
    st_state_flag=get(handles.st_state,'Value');
    
    % and also get values for estimating boundary layer
    boundary_layer_options(1)=str2double(get(handles.av_window,'String'));
    boundary_layer_options(2)=str2double(get(handles.lim_factor,'String'));
    boundary_layer_options(3)=str2double(get(handles.position_lim,'String'));
    
    [steam, coolant, facility, NC, distributions, file, BC, GHFS, MP,timing]=gui_main(userChoice,plot_flag,st_state_flag,boundary_layer_options,clear_flag);
    
    %transfer data to handles structure
    handles.steam=steam;
    handles.coolant=coolant;
    handles.facility=facility;
    handles.NC=NC;
    handles.file=file;
    handles.BC=BC;
    handles.GHFS=GHFS;
    handles.MP=MP;
    handles.timing=timing;
    handles.distributions=distributions;
   
    % push the data to main workspace, just in case
    assignin('base','steam',handles.steam)
    assignin('base','coolant',handles.coolant)
    assignin('base','facility',handles.facility)
    assignin('base','file',handles.file)
    assignin('base','distributions',handles.distributions)
    assignin('base','NC',handles.NC)
    assignin('base','BC',handles.BC)
    assignin('base','GHFS',handles.GHFS)
    assignin('base','MP',handles.MP)
    assignin('base','timing',handles.timing)

    % based on what variables are present, set possible choices to
    % popupmenus for plotting
    vars={'steam','coolant','facility','NC','BC','GHFS','MP'};

    set(handles.popupmenu_x_axis,'String',vars)
    set(handles.popupmenu_y_axis,'String',vars)

    %two lines below reset popupmenu values to first object on the list
    set(handles.popupmenu_x_axis,'Value',1);
    set(handles.popupmenu_y_axis,'Value',1);
    set(handles.popupmenu_x_axis_var,'Value',1);
    set(handles.popupmenu_y_axis_var,'Value',1);

    %update variables popupmenus
    command1=['set(handles.popupmenu_x_axis_var,''String'',fieldnames(handles.',vars{1},'))'];
    command2=['set(handles.popupmenu_y_axis_var,''String'',fieldnames(handles.',vars{1},'))'];
    eval(command1)
    eval(command2)
    guidata(hObject, handles)

function pushbutton2_Callback(hObject, eventdata, handles)
   
    % get choice of x/y axis phase to be plotted
    list_x=get(handles.popupmenu_x_axis,'String');
    list_y=get(handles.popupmenu_y_axis,'String');
    val_x=get(handles.popupmenu_x_axis,'Value');
    val_y=get(handles.popupmenu_y_axis,'Value');
    x_param=list_x{val_x};
    y_param=list_y{val_y};        
    
    % get choice of what parameter of each phase is to be plotted
    list_x_var=get(handles.popupmenu_x_axis_var,'String');
    list_y_var=get(handles.popupmenu_y_axis_var,'String');
    val_x_var=get(handles.popupmenu_x_axis_var,'Value');
    val_y_var=get(handles.popupmenu_y_axis_var,'Value');
    x_param_var=list_x_var{val_x_var};
    y_param_var=list_y_var{val_y_var};

    %extract data values and error values
    for cntr=1:length(eval(['handles.',x_param]))
        x_dat(cntr)=eval(['[handles.',x_param,'(',num2str(cntr),').',x_param_var,'.value];']);
        y_dat(cntr)=eval(['[handles.',y_param,'(',num2str(cntr),').',y_param_var,'.value];']);
        x_err(cntr)=eval(['[handles.',x_param,'(',num2str(cntr),').',x_param_var,'.error];']);
        y_err(cntr)=eval(['[handles.',y_param,'(',num2str(cntr),').',y_param_var,'.error];']);
    end

    %get units for the plot
    x_unit=eval(['[handles.',x_param,'(',num2str(1),').',x_param_var,'.unit];']);
    y_unit=eval(['[handles.',y_param,'(',num2str(1),').',y_param_var,'.unit];']);
    
    hold_flag=get(handles.checkbox_hold_plot, 'Value');
 
    %point to plotting axes and clear them
    axes(handles.axes1);
        
    if  hold_flag==0
        hold off
        handles.plotcounter=1;
        cla
    else
        hold on
        handles.plotcounter=handles.plotcounter+1;
    end
    
    %line styling
    colorstring = 'kbgrmcy';  
    
    line_style_all=get(handles.line_style, 'String');
    line_style_no=get(handles.line_style, 'Value');
    line_style=line_style_all{line_style_no};
    
    line_marker_all=get(handles.line_marker, 'String');
    line_marker_no=get(handles.line_marker, 'Value');
    line_marker=line_marker_all{line_marker_no};
    
    line_color_all=get(handles.line_color, 'String');
    line_color_no=get(handles.line_color, 'Value');
    line_color=line_color_all{line_color_no};
    
    % arrange user defined styling parameters
    if strcmp(line_color,'auto')
        line_color=colorstring(handles.plotcounter);
    end
    
    if strcmp(line_marker,'none')
        line_marker='';
    end
    
    if strcmp(line_style,'none')
        line_style='';
    end
    
    %combine input into line specification string
    line_spec=[line_style,line_color,line_marker];
    
    %check if user wants errorbars
    xerr_flag=get(handles.xerr_checkbox, 'Value');
    yerr_flag=get(handles.yerr_checkbox, 'Value');
    if ~xerr_flag
        x_err=[];
    end
    if ~yerr_flag
        y_err=[];
    end
       
    %plot data according to user preferences
%     errorbarxy(x_dat, y_dat, x_err, y_err,{'bo', 'k', 'k'})
    errorbarxy(x_dat, y_dat, x_err, y_err,{line_spec, 'k', 'k'})

    hold on
     if ~hold_flag
       hold off
     end
    
    %add labeling
    
%     xlabel([x_param,' ',x_param_var,' [',x_unit,']'], 'interpreter', 'none','fontsize',20)
%     ylabel([y_param,' ',y_param_var,' [',y_unit,']'], 'interpreter', 'none','fontsize',20)
    xlabel([x_param,' ',x_param_var,' [',x_unit,']'], 'interpreter', 'none')
    ylabel([y_param,' ',y_param_var,' [',y_unit,']'], 'interpreter', 'none')
    
    %in case fit is desired, add it to the plot   
    fit_flag=get(handles.checkbox1, 'Value');
    label_flag=get(handles.checkbox_point_labels, 'Value');
    if fit_flag
        order=str2double(get(handles.edit1,'String'));
        if order==0
            order=1;
            set(handles.edit1,'String',num2str(order));
        end
        hold on
        polyplot(x_dat,y_dat,order,'r','error','b--','linewidth',.3)
        hold off
    end
    
 %-------------------------------------------------------------   
    if label_flag == 1
        for cntr=1:length(eval('handles.file'))
            str_label=[handles.file(cntr).name,' ',y_param_var];
            %str_label=handles.file(cntr).name;
            text(x_dat(cntr),y_dat(cntr),str_label);
            
        end
    
    end
    guidata(hObject, handles)
 %---------------------------------------------------------------

% --- Executes on selection change in popupmenu_x_axis_var.
function popupmenu_x_axis_var_Callback(~, ~, ~)



% --- Executes during object creation, after setting all properties.
function popupmenu_x_axis_var_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_y_axis_var.
function popupmenu_y_axis_var_Callback(~, ~, ~)



% --- Executes during object creation, after setting all properties.
function popupmenu_y_axis_var_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(~, ~, handles)



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_x_axis.
function popupmenu_x_axis_Callback(hObject, eventdata, handles)

    vars_list=get(handles.popupmenu_x_axis,'String');
    vars_val=get(handles.popupmenu_x_axis,'Value');
    vars=vars_list{vars_val};
       
    %the next line is to set the second popupmenu to common value, otherwise it breaks
    set(handles.popupmenu_x_axis_var,'Value',1);
    command=['set(handles.popupmenu_x_axis_var,''String'',fieldnames(handles.',vars,'))'];
    eval(command)
    
  


% --- Executes during object creation, after setting all properties.
function popupmenu_x_axis_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_y_axis.
function popupmenu_y_axis_Callback(hObject, eventdata, handles)

    vars_list=get(handles.popupmenu_y_axis,'String');
    vars_val=get(handles.popupmenu_y_axis,'Value');
    vars=vars_list{vars_val};  
    
    %the next line is to set the second popupmenu to common value, otherwise it breaks
    set(handles.popupmenu_y_axis_var,'Value',1);
    command=['set(handles.popupmenu_y_axis_var,''String'',fieldnames(handles.',vars,'))'];
    eval(command)



% --- Executes during object creation, after setting all properties.
function popupmenu_y_axis_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_pushbutton.
function save_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure2=figure;
copyobj(handles.axes1,figure2);
set(figure2,'units','centimeters','Position',[1 1 29 21])
set(gca,'units','normalized','position',[0.1 0.1 0.8 0.8])
set(gca,'fontsize', 20)
set(figure2,'Visible', 'on');
% gcf
% figure2
set(figure2,'PaperType','A4')
set(figure2,'paperunits','normalized')
set(figure2,'paperorientation','landscape')
set(figure2,'PaperPositionMode','manual')
set(figure2,'PaperPosition',[0.1 0.1 0.9 0.9])
figure_name = uiputfile('figure.emf','Save plot as .emf');
% savefig(figure2,figure_name)
% set(figure2,'paperunits','inches','papersize',[20,30],'paperposition',[0,0,20,30])
print(figure2,'-r0',figure_name,'-dmeta')


function edit1_Callback(hObject, eventdata, handles)

function xmin_edit_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function xmin_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xmax_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function xmax_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ymin_edit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ymin_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ymax_edit_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function ymax_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rescale_pushbutton.
function rescale_pushbutton_Callback(hObject, eventdata, handles)
        xmin=str2double(get(handles.xmin_edit,'String'));
        xmax=str2double(get(handles.xmax_edit,'String'));
        ymin=str2double(get(handles.ymin_edit,'String'));
        ymax=str2double(get(handles.ymax_edit,'String'));
        set(handles.axes1,'xlim',[xmin xmax])
        set(handles.axes1,'ylim',[ymin ymax])


% --- Executes on button press in fitaxes_pushbutton.
function fitaxes_pushbutton_Callback(hObject, eventdata, handles)
        axes(handles.axes1);
        axis auto
        x=xlim;
        xmin=num2str(x(1));
        xmax=num2str(x(2));
        y=ylim;
        ymin=num2str(y(1));
        ymax=num2str(y(2));
        set(handles.xmin_edit,'String',xmin)
        set(handles.xmax_edit,'String',xmax)
        set(handles.ymin_edit,'String',ymin)
        set(handles.ymax_edit,'String',ymax)
%         axis(handles.axes1,'mode','auto')


% --- Executes on button press in plotflag_checkbox.
function plotflag_checkbox_Callback(hObject, eventdata, handles)

function uipanel5_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in xerr_checkbox.
function xerr_checkbox_Callback(hObject, eventdata, handles)

% --- Executes on button press in yerr_checkbox.
function yerr_checkbox_Callback(hObject, eventdata, handles)


% --- Executes on button press in xmaj_radiobutton.
function xmaj_radiobutton_Callback(hObject, eventdata, handles)
    ax=handles.axes1;
    if (get(hObject,'Value') == get(hObject,'Max'))
        set(ax,'Xgrid','on')
        set(ax,'GridLineStyle', '-')
%         set(ax,'Xcolor',[0.5 0.5 0.5])
    else
        set(ax,'Xgrid','off')
    end


% --- Executes on button press in ymaj_radiobutton.
function ymaj_radiobutton_Callback(hObject, eventdata, handles)
    ax=handles.axes1;
    if (get(hObject,'Value') == get(hObject,'Max'))
        set(ax,'Ygrid','on')
        set(ax,'GridLineStyle', '-')
%         set(ax,'Ycolor',[0.5 0.5 0.5])
    else
        set(ax,'Ygrid','off')
    end

function a_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function a_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function b_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function b_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in plotrfln_pushbutton.
function plotrfln_pushbutton_Callback(hObject, eventdata, handles)
    try    
        delete(handles.ref)
    catch
    end
    axes(handles.axes1);
    a=str2double(get(handles.a_edit,'String'));
    b=str2double(get(handles.b_edit,'String'));
    handles.ref=refline(a,b);
    set(handles.ref,'Color',[0.5 0.5 0.5])
    set(handles.ref,'LineStyle','-.')
    guidata(hObject,handles); 
    


% --- Executes on button press in clearrfln_pushbutton.
function clearrfln_pushbutton_Callback(hObject, eventdata, handles)
    try
    delete(handles.ref)
    guidata(hObject,handles); 
    catch
    end


% --- Executes on button press in xmingrid_radiobutton.
function xmingrid_radiobutton_Callback(hObject, eventdata, handles)
    ax=handles.axes1;
    if (get(hObject,'Value') == get(hObject,'Max'))
        set(ax,'XMinorGrid','on')
        set(ax,'MinorGridLineStyle', ':')
    else
        set(ax,'XMinorGrid','off')
    end


% --- Executes on button press in ymingrid_radiobutton.
function ymingrid_radiobutton_Callback(hObject, eventdata, handles)
    ax=handles.axes1;
    if (get(hObject,'Value') == get(hObject,'Max'))
        set(ax,'YMinorGrid','on')
        set(ax,'MinorGridLineStyle', ':')
    else
        set(ax,'YMinorGrid','off')
    end


% --- Executes on button press in time_pushbutton.
function time_pushbutton_Callback(hObject, eventdata, handles)

    %code below extracts elements from the main struct array that have the
    %field "vars" storing time dependant experimental data
    vars={'steam','coolant','facility','GHFS','MP'};
    for k=1:numel(vars)
    field_names=fields(handles.(vars{k}));
        for i=1:numel(field_names)
            for j=1:numel(handles.(vars{k}))
                try
                time_var.(vars{k})(j).(field_names{i})=handles.(vars{k})(j).(field_names{i}).var;
                catch
                end        
            end
        end
    end

    for l=1:numel(handles.file)
        file_name{l}=[handles.file(l).name];
    end
    assignin('base','time_var',time_var);
    gui_timedependant(time_var,file_name,handles.timing);


% --- Executes on button press in distr_pushbutton.
function distr_pushbutton_Callback(hObject, eventdata, handles)

    for l=1:numel(handles.file)
        file_name{l}=[handles.file(l).name];
    end
    gui_distributions(handles.distributions,file_name);


% --- Executes on button press in checkbox_point_labels.
function checkbox_point_labels_Callback(hObject, eventdata, handles)

% --- Executes on button press in checkbox_hold_plot.
function checkbox_hold_plot_Callback(hObject, eventdata, handles)

% --- Executes on button press in st_state.
function st_state_Callback(hObject, eventdata, handles)

function av_window_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function av_window_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lim_factor_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function lim_factor_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in line_color.
function line_color_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function line_color_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in line_marker.
function line_marker_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function line_marker_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in line_style.
function line_style_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function line_style_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function position_lim_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function position_lim_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
    axes(handles.axes1);
    cla