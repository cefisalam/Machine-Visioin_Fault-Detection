function varargout = SoftBottle(varargin)
% SOFTBOTTLE MATLAB code for SoftBottle.fig
%      SOFTBOTTLE, by itself, creates a new SOFTBOTTLE or raises the existing
%      singleton*.
%
%      H = SOFTBOTTLE returns the handle to a new SOFTBOTTLE or the handle to
%      the existing singleton*.
%
%      SOFTBOTTLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOFTBOTTLE.M with the given input arguments.
%
%      SOFTBOTTLE('Property','Value',...) creates a new SOFTBOTTLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SoftBottle_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SoftBottle_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SoftBottle

% Last Modified by GUIDE v2.5 31-Dec-2018 18:13:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SoftBottle_OpeningFcn, ...
    'gui_OutputFcn',  @SoftBottle_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before SoftBottle is made visible.
function SoftBottle_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SoftBottle (see VARARGIN)

% Choose default command line output for SoftBottle
handles.output = hObject;

%to set axes handles not to show ticks on axes
axes(handles.InputAxes);
set(gca,'XtickLabel',[],'YtickLabel',[]);
set(handles.BottleFoundCheck,'visible','off');
set(handles.BottleMissingCheck,'visible','off');
set(handles.NormalBottleCheck,'visible','off');
set(handles.DeformedBottleCheck,'visible','off');
set(handles.CapFoundCheck,'visible','off');
set(handles.CapMissingCheck,'visible','off');
set(handles.PerfectLabellingCheck,'visible','off');
set(handles.LabelMissingCheck,'visible','off');
set(handles.LabelNotPrintedCheck,'visible','off');
set(handles.LabelNotStraightCheck,'visible','off');
set(handles.CorrectFillingCheck,'visible','off');
set(handles.OverfillingCheck,'visible','off');
set(handles.UnderfillingCheck,'visible','off');
set(handles.NADeformationText,'visible','off');
set(handles.NACapText,'visible','off');
set(handles.NAFillingText,'visible','off');
set(handles.NALabelText,'visible','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SoftBottle wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SoftBottle_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadImageButton.
function LoadImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Function to Get Image
[filename, pathname] = uigetfile({'*.jpg;*.tif;*.bmp;*.jpeg;*.png;*.gif','All Image Files';'*.*','All Files'}, 'Select an Image');
fileName = fullfile(pathname, filename);

% Read Image
Img = imread(fileName);

% Display Image
axes(handles.InputAxes);
imshow(Img);

handles.Img = Img;
guidata(hObject, handles)


% --- Executes on button press in CheckButton.
function CheckButton_Callback(hObject, eventdata, handles)
% hObject    handle to CheckButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Img = handles.Img;

% Check for Bottle
I = imcrop(Img,[115 0 110 352]); % Crop the region for Inspection

Find_Bottle = FindArea(I,3000,'N'); % Find the Area

if (Find_Bottle<28500) % Extract Features
    set(handles.BottleFoundCheck,'visible','on');
    
    % Check for Deformation
    Id = imcrop(Img,[111, 142, 137, 13]);
    Id = im2bw(Id);
    
    Area1 = 0;
    Area2 = 0;
    
    A = regionprops (Id, 'Area');
    for i = 1:length(A)
        if Area1 < A(i).Area
            Area1 = A(i).Area;
        end
    end
    Rx = imcomplement(Id);
    B = regionprops (Rx, 'Area');
    for i = 1:length(B)
        if Area2 < B(i).Area
            Area2 = B(i).Area;
        end
    end
    
    Area = max(Area1, Area2);
    if Area > 1510
        set(handles.NormalBottleCheck,'visible','on');
        
        % Cap Detection
        I2 = imcrop(Img,[115 0 110 60]);
        Bottle_Cap = FindArea(I2,500,'Y');
        if (Bottle_Cap>2000)
            set(handles.CapFoundCheck,'visible','on');
        else
            set(handles.CapMissingCheck,'visible','on');
        end
        
        % Filling Check
        I1 = imcrop(Img,[110 60 130 120]);
        Liquid_Level = FindArea(I1, 3000,'Y');
        if (Liquid_Level<4700)
            set(handles.UnderfillingCheck,'visible','on');
        elseif (Liquid_Level>5900)
            set(handles.OverfillingCheck,'visible','on');
            
        else
            set(handles.CorrectFillingCheck,'visible','on');
            
        end
        
        % Label Check
        I_1 = imcrop(Img,[110 179 135 179]);
        I_2 = I_1(:,:,3);
        I_3 = imbinarize(I_2);
        F1 = bwareaopen(I_3, 100);
        Data = regionprops(F1,'Area');
        
        Label = 0;
        for i = 1:length(Data)
            Label = Label + Data(i).Area;
        end
        
        if (Label<1000)
            set(handles.LabelMissingCheck,'visible','on');
        elseif (Label>10000)
            set(handles.LabelNotPrintedCheck,'visible','on');
        else
            
            % Check for Label Not Straight
            Ix = imcrop(Img,[123, 174, 85, 17]);
            I_x = Ix(:,:,3);
            Rx = imbinarize(I_x,0.3);
            
            A = regionprops(Rx,'Area');
            Label1 = 0;
            for i = 1:length(A)
                if Label1 < A(i).Area
                    Label1 = A(i).Area;
                end
            end
            
            if (Label1 < 385)
                set(handles.LabelNotStraightCheck,'visible','on');
            else
                set(handles.PerfectLabellingCheck,'visible','on');
            end
        end
        
    else
        set(handles.DeformedBottleCheck,'visible','on');
        set(handles.NACapText,'visible','on');
        set(handles.NAFillingText,'visible','on');
        set(handles.NALabelText,'visible','on');
    end
    
else
    set(handles.BottleMissingCheck,'visible','on');
    set(handles.NADeformationText,'visible','on');
    set(handles.NACapText,'visible','on');
    set(handles.NAFillingText,'visible','on');
    set(handles.NALabelText,'visible','on');
    
end


% --- Executes on button press in ResetButton.
function ResetButton_Callback(hObject, eventdata, handles)
% hObject    handle to ResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset All Fields
cla(handles.InputAxes,'reset');
axes(handles.InputAxes);
set(gca,'XtickLabel',[],'YtickLabel',[]);
set(handles.BottleFoundCheck,'visible','off');
set(handles.BottleMissingCheck,'visible','off');
set(handles.NormalBottleCheck,'visible','off');
set(handles.DeformedBottleCheck,'visible','off');
set(handles.CapFoundCheck,'visible','off');
set(handles.CapMissingCheck,'visible','off');
set(handles.PerfectLabellingCheck,'visible','off');
set(handles.LabelMissingCheck,'visible','off');
set(handles.LabelNotPrintedCheck,'visible','off');
set(handles.LabelNotStraightCheck,'visible','off');
set(handles.CorrectFillingCheck,'visible','off');
set(handles.OverfillingCheck,'visible','off');
set(handles.UnderfillingCheck,'visible','off');
set(handles.NADeformationText,'visible','off');
set(handles.NACapText,'visible','off');
set(handles.NAFillingText,'visible','off');
set(handles.NALabelText,'visible','off');
