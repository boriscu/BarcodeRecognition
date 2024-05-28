function varargout = Home(varargin)
% HOME MATLAB code for Home.fig
%      HOME, by itself, creates a new HOME or raises the existing
%      singleton*.
%
%      H = HOME returns the handle to a new HOME or the handle to
%      the existing singleton*.
%
%      HOME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HOME.M with the given input arguments.
%
%      HOME('Property','Value',...) creates a new HOME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Home_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Home_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Home

% Last Modified by GUIDE v2.5 20-May-2024 18:11:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Home_OpeningFcn, ...
                   'gui_OutputFcn',  @Home_OutputFcn, ...
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


% --- Executes just before Home is made visible.
function Home_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Home (see VARARGIN)

% Choose default command line output for Home
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Home wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Home_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in uploadBarcodeButton.
function uploadBarcodeButton_Callback(hObject, eventdata, handles)
% hObject    handle to uploadBarcodeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'}, 'Select an Image');
if isequal(filename,0)
   disp('User selected Cancel');
else
   filepath = fullfile(pathname, filename);
   % Display the image
   img = imread(filepath);
   axes(handles.barcodeAxes);
   imshow(img);
   handles.uploadedImage = img;
   
   % Let user crop the barcode manually
   rect = getrect(handles.barcodeAxes);
   croppedImg = imcrop(img, rect);
   
   % Display the cropped image
   axes(handles.barcodeAxes);
   imshow(croppedImg);
   handles.croppedImage = croppedImg;
   
   % Get selected preprocessing function
   contents = cellstr(get(handles.preprocessingPopup,'String'));
   selectedPreprocess = contents{get(handles.preprocessingPopup,'Value')};
   
   % Check if the plotCheckbox is selected
   showPlots = get(handles.plotCheckbox, 'Value');
   
   % Preprocess the image based on the selected function and showPlots flag
   if strcmp(selectedPreprocess, 'FFT')
       preprocessedImg = preprocessImageFFT(croppedImg, showPlots);
   elseif strcmp(selectedPreprocess, 'Hugh')
       preprocessedImg = preprocessImageHugh(croppedImg, showPlots);
   end
   
   preprocessedImg = detector(preprocessedImg,showPlots);

   axes(handles.preprocessedAxes);
   imshow(preprocessedImg);
   handles.preprocessedImage = preprocessedImg;
   
   % Barcode recognition function
   barcodeData = recognizeBarcode(preprocessedImg);
   set(handles.barcodeResultText, 'String', barcodeData);

   handles.barcodeData = barcodeData;
   guidata(hObject, handles);
end


% --- Executes on selection change in preprocessingPopup.
function preprocessingPopup_Callback(hObject, eventdata, handles)
% hObject    handle to preprocessingPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns preprocessingPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from preprocessingPopup


% --- Executes during object creation, after setting all properties.
function preprocessingPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preprocessingPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Set the options for the preprocessing functions
set(hObject, 'String', {'FFT', 'Hugh'});


% --- Executes on button press in plotCheckbox.
function plotCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to plotCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotCheckbox
