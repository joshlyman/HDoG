function Figure_DrawPoints(imo)
    warning off;clc;    
   
    lx=0;ly=0;lz=0;
    p.x=0;p.y=0;p.z=0;
    axialxhair.lx=NaN;
    axialxhair.ly=NaN;
    p.x=0;p.y=0;p.z=0;
    axialxhair.lx=NaN;
    axialxhair.ly=NaN;
    sagxhair.lx=NaN;
    sagxhair.ly=NaN;
    corxhair.lx=NaN;
    corxhair.ly=NaN;
    hA=NaN;
    Mask=NaN;
    SOptions.dRadius = 120;
    SOptions.dCaptureRadius = 4;
    ShowMask=0;
    Figure_DrawPoints_hLine1 = NaN;
    DrawMode=0;
    % -------------------------------------------------------------------------
    dF = NaN;
    iPX =NaN;
    iPY=NaN;
    
    PointGroup  = []; 
    
    dXData      = [];                        % The x-coordinates of the path
    dYData      = [];                        % The y-coordinates of the path
    iAnchorList = zeros(200, 1);             % A list of the anchor point indices in dXData and dYData for undo operations
    iAnchorInd  = 0;                         % The index of the list
    lRegularEnd = false;                     % Indicates whether path was successfully drawn or the UI was aborted.
    lControl    = false;                     % Indicates whether the control key is pressed
  
    % -------------------------------------------------------------------------
    % Initialize the global variables

   
    if isempty(get(findobj('Tag','Figure_DrawPoints')))
    Figure_DrawPoints = figure('Visible','on','Position',[0,0,900,530],'MenuBar','none','Resize','off','Pointer','crosshair','Name','Quantitative Glomeruli Assessment Toolkit (qGAT)', 'NumberTitle','off','Tag','Figure_DrawPoints');
    
 
    movegui(Figure_DrawPoints,'center');
    parentColor = get(Figure_DrawPoints, 'color');
    Figure_DrawPoints_Axial=axes('Position',[0.01 0.18 0.5 0.8],'DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual','XTick',[],'YTick',[],'Box','on','Tag','Figure_DrawPoints_Axial');
    
    Figure_DrawPoints_Coronal = axes('Position',[0.5 0.18 0.5 0.8],'DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual','XTick',[],'YTick',[],'Box','on','Visible','off','Tag','Figure_DrawPoints_Coronal');
    Figure_DrawPoints_Sagittal = axes('Position',[0.5 0.18 0.5 0.8],'DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual','XTick',[],'YTick',[],'Box','on','Tag','Figure_DrawPoints_Sagittal');
   
   
    Figure_DrawPoints_Menu1=uimenu(Figure_DrawPoints,'Label','File');
    Figure_DrawPoints_SubMenu1 = uimenu(Figure_DrawPoints_Menu1,'Label','Open Analyze 75','CallBack',@CallBack_OpenImg);
    Figure_DrawPoints_SubMenu2 = uimenu(Figure_DrawPoints_Menu1,'Label','Load Points','CallBack',@CallBack_LoadPoints,'Enable','Off');
    Figure_DrawPoints_SubMenu3 = uimenu(Figure_DrawPoints_Menu1,'Label','Save Points','CallBack',@CallBack_SaveFile,'Enable','Off');
   
    Figure_DrawPoints_SubMenuRst=uimenu(Figure_DrawPoints_Menu1,'Label','Clear All','CallBack',@CallBack_ClearAll,'Enable','on');
    set(Figure_DrawPoints_SubMenuRst,'Separator','on');
     
    Figure_DrawPoints_Menu2 = uimenu(Figure_DrawPoints,'Label','Mask');
    Figure_DrawPoints_SubMenu4 = uimenu(Figure_DrawPoints_Menu2,'Label','Generate','CallBack',@CallBack_MaskRun,'Enable','Off');
    Figure_DrawPoints_SubMenu5 = uimenu(Figure_DrawPoints_Menu2,'Label','Off','CallBack',@CallBack_MaskOff,'Enable','Off');
    set(Figure_DrawPoints_SubMenu5,'Separator','on');
    Figure_DrawPoints_SubMenu6 = uimenu(Figure_DrawPoints_Menu2,'Label','On','CallBack',@CallBack_MaskOn,'Checked','On','Enable','Off');
    
    uicontrol('Style','Text','Position',[22 42 325 20],'HorizontalAlignment','left','FontSize',10, ...
    'String','A ','Tag','Figure_DrawPoints_VoxelPos','backgroundcolor', parentColor);
    
    
    uicontrol('Style','PushButton','Position',[22 10 60 30],'String','Open','backgroundcolor', parentColor,'CallBack',@CallBack_OpenImg);
    uicontrol('Style','Edit','Position',[90 10 280 30],'String',' ','backgroundcolor', parentColor,'Tag','Figure_DrawPoints_FileLocation');
     uicontrol('Style','PushButton','Position',[375 10 70 30],'String','Load Points','backgroundcolor', parentColor,'CallBack',@CallBack_LoadPoints,'Enable','Off','Tag','Figure_DrawPoints_LoadPoints');
     uicontrol('Style','PushButton','Position',[465 10 50 30],'String','Save','backgroundcolor', parentColor,'CallBack',@CallBack_SaveFile,'Enable','Off','Tag','Figure_DrawPoints_SaveFile');
     
    Figure_DrawPoints_RadioGrp1 = uibuttongroup('visible','on','Position',[0.6 0.016 .24 0.07],'backgroundcolor', parentColor); % Create three radio buttons in the button group.
    uicontrol('Style','radiobutton','String','Sagittal','parent',Figure_DrawPoints_RadioGrp1, 'pos',[5 1 100 30],'HandleVisibility','on','Tag','Figure_DrawPoints_Radio0','backgroundcolor', parentColor );
    uicontrol('Style','radiobutton','String','Coronal','parent',Figure_DrawPoints_RadioGrp1, 'pos',[104 1 100 30],'HandleVisibility','on','Tag','Figure_DrawPoints_Radio1','backgroundcolor', parentColor );
    set(Figure_DrawPoints_RadioGrp1,'SelectionChangeFcn',@CallBack_SelectionChange);
    set(Figure_DrawPoints_RadioGrp1,'SelectedObject',findobj('Tag','Figure_DrawPoints_Radio0'));  % No selection
    
    uicontrol('Style','PushButton','Position',[770 10 50 30],'String','Draw','CallBack',@CallBack_DrawContour,'Tag','Figure_DrawPoints_DrawContour','backgroundcolor', parentColor,'Enable','Off');
    uicontrol('Style','PushButton','Position',[840 10 50 30],'String','Delete','CallBack',@CallBack_DeleteContour,'Tag','Figure_DrawPoints_DeleteContour','backgroundcolor', parentColor,'Enable','Off');
    
       else
        Figure_DrawPoints = findobj('Tag','Figure_DrawPoints');
        figure(Figure_DrawPoints);
    end
    
     if isnan(imo)
        clear all;
        imo=NaN;
    else
        ReadImg;
    end
    
    function DrawPoints(src,varargin)
        ViewC=get(src,'Tag');
        switch ViewC
            case 'axiview'
                D=get(Figure_DrawPoints_Axial,'CurrentPoint');
                p.x=uint16(round(D(1,1)));
                p.y=uint16(round(D(1,2)));
                
            case 'sagview'
                D=get(Figure_DrawPoints_Sagittal,'CurrentPoint');
                p.x=uint16(round(D(1,1)));
                p.z=uint16(round(D(1,2)));
                
            case 'corview'
                D=get(Figure_DrawPoints_Coronal,'CurrentPoint');
                p.y=uint16(round(D(1,1)));
                p.z=uint16(round(D(1,2)));
                
        end
        Func_Display3d(p.x,p.y,p.z);
        Func_DrawXhair;     
    end
    

    function CallBack_SaveFile(object, eventdata)
        [FileName,PathName] = uiputfile('*.mat','Save Points','boundary.mat');
        if FileName~=0 & ~isnan(FileName)
            pathfile=strcat(PathName,FileName);
            save(pathfile,'PointGroup','Mask');
        end
    end

    function CallBack_ClearAll(object, eventdata)
        clc;clear all;
        imo=NaN;
        lx=0;ly=0;lz=0;
        p.x=0;p.y=0;p.z=0;
        axialxhair.lx=NaN;
        axialxhair.ly=NaN;
        p.x=0;p.y=0;p.z=0;
        axialxhair.lx=NaN;
        axialxhair.ly=NaN;
        sagxhair.lx=NaN;
        sagxhair.ly=NaN;
        corxhair.lx=NaN;
        corxhair.ly=NaN;
        hA=NaN;
        Mask=NaN;
        SOptions.dRadius = 50;
        SOptions.dCaptureRadius = 4;
        ShowMask=0;
        Figure_DrawPoints_hLine1 = NaN;
        
        % -------------------------------------------------------------------------
        dF = NaN;
        iPX =NaN;
        iPY=NaN;

        PointGroup  = []; 

        dXData      = [];                        % The x-coordinates of the path
        dYData      = [];                        % The y-coordinates of the path
        iAnchorList = zeros(200, 1);             % A list of the anchor point indices in dXData and dYData for undo operations
        iAnchorInd  = 0;                         % The index of the list
        lRegularEnd = false;                     % Indicates whether path was successfully drawn or the UI was aborted.
        lControl    = false;                     % Indicates whether the control key is pressed
        cla(Figure_DrawPoints_Axial);
        cla(Figure_DrawPoints_Sagittal);
        cla(Figure_DrawPoints_Coronal);
        
        set(Figure_DrawPoints_SubMenu2,'Enable','Off');
        set(Figure_DrawPoints_SubMenu3,'Enable','Off');
        set(Figure_DrawPoints_SubMenu4,'Enable','Off');
        set(Figure_DrawPoints_SubMenu5,'Enable','Off');
        set(Figure_DrawPoints_SubMenu6,'Enable','Off');
        set(findobj('Tag','Figure_DrawPoints_DeleteContour'),'Enable','Off');
        set(findobj('Tag','Figure_DrawPoints_DrawContour'),'Enable','Off');
        set(findobj('Tag','Figure_DrawPoints_LoadPoints'),'Enable','Off');
        set(findobj('Tag','Figure_DrawPoints_SaveFile'),'Enable','Off');
    end    

    function CallBack_LoadPoints(object, eventdata)
        [filename,pathname]=uigetfile('*.mat'); 
       % filename=which(filename);
       if ~(filename==0) & ~isnan(filename)
        filename=strcat(pathname,filename);
        tmp=load(filename);
        PointGroup=tmp.PointGroup;
        if ~isfield(tmp,'Mask') || isempty(tmp.Mask) 
            ShowMask=0;
        else
            ShowMask=1;
            Mask=tmp.Mask;
            CallBack_MaskOn;
        end
        set(Figure_DrawPoints_SubMenu4,'Enable','On');
        Func_Display3d(p.x,p.y,p.z);
        Func_DrawXhair;
       end
    end
    function CallBack_MaskOff(object,eventdata)
        set(Figure_DrawPoints_SubMenu5,'Enable','On');
        set(Figure_DrawPoints_SubMenu6,'Enable','On');
        set(Figure_DrawPoints_SubMenu5,'Checked','On');
        set(Figure_DrawPoints_SubMenu6,'Checked','Off');
        ShowMask=0;
        
        Func_Display3d(p.x,p.y,p.z);
        Func_DrawXhair; 
        set(findobj('Tag','Figure_DrawPoints_DeleteContour'),'Enable','On');
        set(findobj('Tag','Figure_DrawPoints_DrawContour'),'Enable','On');
    end
    function CallBack_MaskOn(object,eventdata)
        set(Figure_DrawPoints_SubMenu5,'Enable','On');
        set(Figure_DrawPoints_SubMenu6,'Enable','On');
        set(Figure_DrawPoints_SubMenu6,'Checked','On');
        set(Figure_DrawPoints_SubMenu5,'Checked','Off');
        ShowMask=1;
        DrawMode=0;
        Func_Display3d(p.x,p.y,p.z);
        Func_DrawXhair; 
        set(findobj('Tag','Figure_DrawPoints_DeleteContour'),'Enable','Off');
        set(findobj('Tag','Figure_DrawPoints_DrawContour'),'Enable','Off');
        
    end
    function CallBack_MaskRun(object, eventdata)
        UAxial=unique(PointGroup(:,3));
        disp(num2str(length(UAxial)));
        Mask=zeros(lx,ly,lz);
        DrawMode=0;
        if ~isempty(UAxial)
            for i=1:length(UAxial)
                 UX=[double(PointGroup(find(PointGroup(:,3)==UAxial(i)),1)),...
                 double(PointGroup(find(PointGroup(:,3)==UAxial(i)),2))];
                 UX=unique(UX,'rows');
                 if length(UX(:,1))>=2
                     corY=UX(:,2);
                     corX=UX(:,1);
                     theta = atan2(corY-mean(corY), corX-mean(corX));
                     [thsort, idx] = sort(theta);
                     samp=max(max(corX)-min(corX),max(corY)-min(corY));
                     samp=max(samp,length(corX));
                     %XXf=min(corX):(min(corX)+samp);
                     YYf=interppolygon([corX(idx),corY(idx)],100,'pchip');
                     BW = poly2mask(YYf(:,1), YYf(:,2), lx, ly);
                     Mask(:,:,UAxial(i))=BW';
                 end
            end
        end
        set(Figure_DrawPoints_SubMenu5,'Enable','On');
        set(Figure_DrawPoints_SubMenu6,'Enable','On');
        CallBack_MaskOn;
        
    end
    function Func_DrawXhair()
        axialxhair=Func_DrawXhairFcn(Figure_DrawPoints_Axial,axialxhair,[p.x p.y]);
         switch get(get(Figure_DrawPoints_RadioGrp1,'SelectedObject'),'Tag')
             case 'Figure_DrawPoints_Radio0'
        sagxhair= Func_DrawXhairFcn(Figure_DrawPoints_Sagittal,[],[p.x p.z]);
             case 'Figure_DrawPoints_Radio1'
        corxhair=Func_DrawXhairFcn(Figure_DrawPoints_Coronal,[],[p.y p.z]);
         end
           assignin('base','Point',PointGroup);
    end
    

    function CallBack_SelectionChange(object, eventdata)
        switch get(get(Figure_DrawPoints_RadioGrp1,'SelectedObject'),'Tag')
             case 'Figure_DrawPoints_Radio0'
                  cla(Figure_DrawPoints_Coronal,'reset');
                  set(Figure_DrawPoints_Coronal,'Visible','off');
                  set(Figure_DrawPoints_Sagittal,'Visible','on');
                  
            case 'Figure_DrawPoints_Radio1'
                  cla(Figure_DrawPoints_Sagittal,'reset');
                  set(Figure_DrawPoints_Sagittal,'Visible','off');
                  set(Figure_DrawPoints_Coronal,'Visible','on');
                          
        end
        Func_Display3d(p.x,p.y,p.z);
        
    end
    
    function CallBack_DeleteContour(object, eventdata)
        switch get(get(Figure_DrawPoints_RadioGrp1,'SelectedObject'),'Tag')
            case 'Figure_DrawPoints_Radio0'
                 if ~isempty(PointGroup) && ~isempty(find(PointGroup(:,2)==p.y))
                     PointGroup(find(PointGroup(:,2)==p.y),:)=[];
                 end
            case 'Figure_DrawPoints_Radio1'
                 if ~isempty(PointGroup) && ~isempty(find(PointGroup(:,1)==p.x))
                     PointGroup(find(PointGroup(:,1)==p.x),:)=[];
                 end
        end
    end


    function fButtonDownFcn(hObject, eventdata) 
       
        % -----------------------------------------------------------------
        % Get mouse cursor position and return if outside the image
        [dX, dY] = fGetAxesPos;
        if ~dX, return, end
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Look for ideal end-point within the capture radius
        if (SOptions.dCaptureRadius) && ~(lControl)
           [dX, dY] = fGetIdealAnchor(dX, dY, SOptions.dCaptureRadius);
        end
        % -----------------------------------------------------------------
        
        if isempty(dXData)
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % The starting point of the path is selected
            dXData = dX;
            dYData = dY;
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        else
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % A new anchor point and the cheapest path to the last anchor
            % point is appended to the path
            [iXPath, iYPath] = fLiveWireGetPath(iPX, iPY, dX, dY);
            if isempty(iXPath)
                iXPath = dX;
                iYPath = dY;
            end
            dXData = [dXData, double(iXPath(:)')];
            dYData = [dYData, double(iYPath(:)')];
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        end

        iAnchorInd = iAnchorInd + 1;
        iAnchorList(iAnchorInd) = length(dXData); % Save the previous path length for the undo operation
        
        try
            set(Figure_DrawPoints_hLine1, 'XData', dXData, 'YData', dYData);
            drawnow expose
        catch
            clc;
            disp('Please Draw on Other Slice!');
        end
        [iPX, iPY] = func_IS_Calc(dF, dX, dY, SOptions.dRadius);
        % -----------------------------------------------------------------

        % -----------------------------------------------------------------
        % If right-click, double-click or shift-click occurred, close path
        % and return.
        if ~(strcmp(get(Figure_DrawPoints, 'SelectionType'), 'normal')) && ~(lControl)
            [iXPath, iYPath] = fLiveWireGetPath(iPX, iPY, dXData(1), dYData(1));
            if isempty(iXPath)
                iXPath = dXData(1);
                iYPath = dYData(1);
            end
            dXData = [dXData, double(iXPath(:)')];
            dYData = [dYData, double(iYPath(:)')];
            set(Figure_DrawPoints_hLine1, 'XData', dXData, 'YData', dYData);
            drawnow expose
            set(Figure_DrawPoints, 'WindowButtonMotionFcn', '', 'WindowButtonDownFcn', '', 'KeyPressFcn', '');
            switch get(get(Figure_DrawPoints_RadioGrp1,'SelectedObject'),'Tag')
             case 'Figure_DrawPoints_Radio0'
                PointGroup=[PointGroup;[dXData',repmat(p.y,length(dXData'),1), dYData']];
                
             case 'Figure_DrawPoints_Radio1'
                PointGroup=[PointGroup;[repmat(p.x,length(dXData'),1),dXData', dYData']];
            end 
            dXData = [];
            dYData = [];
            lRegularEnd = true;
            uiresume(Figure_DrawPoints);
            set(findobj('Tag','Figure_DrawPoints_DeleteContour'),'Enable','On');
            set(Figure_DrawPoints_SubMenu4,'Enable','On');
            DrawMode=0;
            Func_Display3d(p.x,p.y,p.z);
            Func_DrawXhair;
        end
        
    end
   
    function fMotionFcn(hObject, eventdata)
        
        % -----------------------------------------------------------------
        % Return if no start point has been selected yet or if the path map
        % is not yet available.
        if (isempty(dXData)) || (sum(abs(iPX(:))) == 0), return, end
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Get mouse cursor position and return if outside of the image
        [dX, dY] = fGetAxesPos;
        if ~dX, return, end
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Look for ideal end-point within the capture radius
        if (SOptions.dCaptureRadius) && ~(lControl)
           [dX, dY] = fGetIdealAnchor(dX, dY, SOptions.dCaptureRadius);
        end
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Get the cheapest path from current cursor position to the last
        % anchor point and update UI, butr do not add to the path.
        [iXPath, iYPath] = fLiveWireGetPath(iPX, iPY, dX, dY);
        if isempty(iXPath)
            iXPath = dX;
            iYPath = dY;
        end
     try
        set(Figure_DrawPoints_hLine1, 'XData', [dXData, double(iXPath(:)')], ...
                              'YData', [dYData, double(iYPath(:)')]);
        drawnow expose
     catch
         Func_Display3d(p.x,p.y,p.z);
     end
        % ----------------------------------------------------------------
    end


    function [dX, dY] = fGetAxesPos()
        dPos  = get(hA, 'CurrentPoint');
        dXLim = get(hA, 'XLim');
        dYLim = get(hA, 'YLim');
        dX = dPos(1, 1);
        dY = dPos(1, 2);
        if (dX < dXLim(1)) || (dX > dXLim(2)) || ...
           (dY < dYLim(1)) || (dY > dYLim(2))
            dX = 0;
            dY = 0;
        end
    end
  
    
    
  
    
    function fCloseGUI(hObject, eventdata) %#ok<DEFNU> <-stupid!
        delete(hObject); % Bye-bye figure
    end
    
    function CallBack_DrawContour(object, eventdata)
         DrawMode=1;
         switch get(get(Figure_DrawPoints_RadioGrp1,'SelectedObject'),'Tag')
            case 'Figure_DrawPoints_Radio0'
                  set(Figure_DrawPoints,'CurrentAxes',Figure_DrawPoints_Sagittal);
                  hI = findobj(Figure_DrawPoints_Sagittal, 'Type', 'image');
            case 'Figure_DrawPoints_Radio1'
                  set(Figure_DrawPoints,'CurrentAxes',Figure_DrawPoints_Coronal);
                  hI = findobj(Figure_DrawPoints_Coronal, 'Type', 'image');
         end
         dImg = double(get(hI, 'CData'));
         set(hI,'ButtonDownFcn','');
         hA = get(Figure_DrawPoints, 'CurrentAxes');
         
        try
        set(Figure_DrawPoints, ...
            'WindowButtonDownFcn'   , @fButtonDownFcn,...
            'KeyPressFcn'           , @fKeyPressFcn, ...
            'KeyReleaseFcn'         , @fKeyReleaseFcn, ...
            'WindowButtonMotionFcn' , @fMotionFcn, ...
            'DoubleBuffer'          , 'on'); 
        catch
        set(Figure_DrawPoints, ...
            'WindowButtonDownFcn'   , @fButtonDownFcn,...
            'KeyPressFcn'           , @fKeyPressFcn, ...
            'WindowButtonMotionFcn' , @fMotionFcn, ...
            'DoubleBuffer'          , 'on');
        end
        
        Figure_DrawPoints_hLine1 = line(...
            'Parent'    , hA, ...
            'XData'     , [], ...
            'YData'     , [], ...
            'Clipping'  , 'off', ...
            'Color'     , 'g', ...
            'LineStyle' , ':', ...
            'LineWidth' , 1.5);
            dF          = func_is_cost(dImg); % The cost function of the live-wire algorithm, see Ref [1].
            iPX         = zeros(size(dImg), 'int8'); % The path map that shows the cheapest path to the sast anchor point.
            iPY         = zeros(size(dImg), 'int8'); % The path map that shows the cheapest path to the sast anchor point.
    
    end

    function CallBack_OpenImg(object, eventdata)
        [filename,pathname]=uigetfile('*.hdr'); 
       % filename=which(filename);
       
        if (filename~=0) & (~isnan(filename))
            filename=strcat(pathname,filename);
            hdr=analyze75info(filename);
            imo=analyze75read(hdr);
            file=findobj('Tag','Figure_DrawPoints_FileLocation');
            set(file,'String',filename);
            ReadImg;
        end
    end

    function ReadImg()
            imo=imresize(imo,0.5);
            imo=double(imo);
            imo=(imo-min(imo(:)))/(max(imo(:))-min(imo(:)));
            [lx ly lz]=size(imo);

            
           
            x=uint16(round(lx/2));
            y=uint16(round(ly/2));
            z=uint16(round(lz/2));
            Mask=[];
            p.x=x;p.y=y;p.z=z;

            Func_Display3d(x,y,z);

            Func_DrawXhair;

            set(findobj('Tag','Figure_DrawPoints_LoadPoints'),'Enable','On');
            set(findobj('Tag','Figure_DrawPoints_DrawContour'),'Enable','On');
            set(findobj('Tag','Figure_DrawPoints_DeleteContour'),'Enable','On');
            set(findobj('Tag','Figure_DrawPoints_SaveFile'),'Enable','On');
            set(Figure_DrawPoints_SubMenu1,'Enable','On');
            set(Figure_DrawPoints_SubMenu2,'Enable','On');
            set(Figure_DrawPoints_SubMenu3,'Enable','On');
    end
    function Func_Display3d(x,y,z)
        dispAxial(z);
         switch get(get(Figure_DrawPoints_RadioGrp1,'SelectedObject'),'Tag')
             case 'Figure_DrawPoints_Radio0'
                dispSagittal(y);
             case 'Figure_DrawPoints_Radio1'
                 dispCoronal(x);
         end
        coord=findobj('Tag','Figure_DrawPoints_VoxelPos');
        set(coord,'String',strcat('Pos (x, y, z): (',num2str(x),', ', num2str(y),', ', num2str(z),')   -  Value: ',num2str(imo(p.x,p.y,p.z))));
        
    end

    function xhair=Func_DrawXhairFcn(h_ax,xhair,curp)
        
        set(Figure_DrawPoints,'CurrentAxes',h_ax);
        x_range = get(h_ax,'xlim');
        y_range = get(h_ax,'ylim');

%        if ~isempty(xhair)
%           set(xhair.lx, 'ydata', [curp(2) curp(2)]);
%           set(xhair.ly, 'xdata', [curp(1) curp(1)]);
%           set(h_ax, 'selected', 'on');
%           set(h_ax, 'selected', 'off');
%        else
          figure(get(h_ax,'parent'));
          axes(h_ax);
        if h_ax==Figure_DrawPoints_Axial
          xhair.lx = line('xdata', x_range, 'ydata', [curp(2) curp(2)], ...
        'zdata', [11 11], 'color', 'yellow', 'hittest', 'off');
          xhair.ly = line('xdata', [curp(1) curp(1)], 'ydata', y_range, ...
        'zdata', [11 11], 'color', 'yellow', 'hittest', 'off');
        end

       set(h_ax,'xlim',x_range);
       set(h_ax,'ylim',y_range);
  end

    function dispAxial(z) %Update Figure_DrawPoints_Axial image
        set(Figure_DrawPoints,'CurrentAxes',Figure_DrawPoints_Axial);
        im = double(squeeze(imo(1:lx,1:ly,z)));
        im=im';
        himage=imshow(im,[]); 
        if ~isempty(PointGroup) && ~isempty(find(PointGroup(:,3)==z))
            tmp=PointGroup(find(PointGroup(:,3)==z),1:2);
            hold on; h2=scatter(tmp(:,1),tmp(:,2),30,'fill');hold off;
            set(h2,'Tag','axiview','MarkerEdgeColor','none','MarkerFaceColor','g','LineWidth',0.9);
             if DrawMode==0
                set(h2,'ButtonDownFcn',@DrawPoints,'Tag','axiview');
             elseif DrawMode==1
            	
                set(h2,'ButtonDownFcn','','Tag','axiview');
              end
        end
        
         if ShowMask==1 
            
            hold on;
            it = double(squeeze(Mask(1:lx,1:ly,z)));
            it=it';
            Lrgb = label2rgb(it, 'autumn', 'k','shuffle');
            himage=imshow(Lrgb);

            set(himage, 'AlphaData', 0.4);hold off;
         end
        if DrawMode==0
            set(himage,'ButtonDownFcn',@DrawPoints,'Tag','axiview');
            
        elseif DrawMode==1
            set(himage,'ButtonDownFcn','','Tag','axiview');

        end
    end

    function dispSagittal(y) %Updata Figure_DrawPoints_Sagittal image
        set(Figure_DrawPoints,'CurrentAxes',Figure_DrawPoints_Sagittal);
        im = double(squeeze(imo(1:lx,y,1:lz)));
        im=im';
        himage=imshow(im,[]); 
        if ~isempty(PointGroup) && ~isempty(find(PointGroup(:,2)==y))
            tmp=PointGroup(find(PointGroup(:,2)==y),[1,3]);
            hold on; h2=scatter(tmp(:,1),tmp(:,2),30,'fill');hold off;
            set(h2,'Tag','sagview','MarkerEdgeColor','none','MarkerFaceColor','g','LineWidth',0.9);    
              if DrawMode==0
                set(h2,'ButtonDownFcn',@DrawPoints,'Tag','sagview');
             elseif DrawMode==1
            	
                set(h2,'ButtonDownFcn','','Tag','sagview');
              end            
        end
         if ShowMask==1 
            hold on;
            it = double(squeeze(Mask(1:lx,y,1:lz)));
            it=it';
            Lrgb = label2rgb(it, 'autumn', 'k','shuffle');
            himage=imshow(Lrgb);
            set(himage, 'AlphaData', 0.4);hold off;
         end
        
        if DrawMode==0
            set(himage,'ButtonDownFcn',@DrawPoints,'Tag','sagview');
        elseif DrawMode==1
            set(himage,'ButtonDownFcn','','Tag','sagview');
        end
    end

    function dispCoronal(x) %Update Figure_DrawPoints_Coronal image       
        set(Figure_DrawPoints,'CurrentAxes',Figure_DrawPoints_Coronal);
        im = double(squeeze(imo(x,1:ly,1:lz)));
        im=im';
        himage=imshow(im,[]); 
        if ~isempty(PointGroup) && ~isempty(find(PointGroup(:,1)==x))
             tmp=PointGroup(find(PointGroup(:,1)==x),[2,3]);
             hold on; h2=scatter(tmp(:,1),tmp(:,2),30,'fill');hold off;
             set(h2,'Tag','corview','MarkerEdgeColor','none','MarkerFaceColor','g','LineWidth',0.9);
               if DrawMode==0
                set(h2,'ButtonDownFcn',@DrawPoints,'Tag','corview');
             elseif DrawMode==1
            	
                set(h2,'ButtonDownFcn','','Tag','corview');
              end           
        end
        
         if ShowMask==1 
            hold on;
            it = double(squeeze(Mask(x,1:ly,1:lz)));
            it=it';
            Lrgb = label2rgb(it, 'autumn', 'k','shuffle');
            himage=imshow(Lrgb);
            set(himage, 'AlphaData', 0.4);hold off;
            %colormap(Figure_DrawPoints_Coronal,'hot');
         end
        
        if DrawMode==0
            set(himage,'ButtonDownFcn',@DrawPoints,'Tag','corview');
        elseif DrawMode==1
            set(himage,'ButtonDownFcn','','Tag','corview');
        end
    end

    function [dX, dY] = fGetIdealAnchor(dX, dY, dRadius)
            iX = round(dX); iY = round(dY);
            if ~(iPX(iY, iX)) && ~(iPY(iY, iX)), return, end
            iInd = double(-round(dRadius):round(dRadius));
            iXVector = round(double(iX) + iInd.*double(iPX(iY, iX)));
            iYVector = round(double(iY) + iInd.*double(iPY(iY, iX)));
            lValid = (iXVector > 0) & (iXVector <= size(dF, 2)) & ...
                     (iYVector > 0) & (iYVector <= size(dF, 1));
            iXVector = iXVector(lValid); iYVector = iYVector(lValid);
            dVal = dF((iXVector - 1).*size(dF, 1) + iYVector - 1);
            [temp, iMinInd] = min(dVal); %#ok<ASGLU> // Backward compatibility
            dX = double(iXVector(iMinInd));
            dY = double(iYVector(iMinInd));
    end

    function [iX, iY] = fLiveWireGetPath(iPX, iPY, iXS, iYS)
        %FLIVEWIREGETPATH Traces the cheapest path from (IXS, IYS)^T through the
        %pathmaps IPX, IPY back to the seed (where both, IPX and IPY are 0).
        %
        %   See also LIVEWIRE, func_is_cost, FLIVEWIREGETCOSTFCN.
        %
        %
        %   Copyright 2013 Christian Würslin, University of Tübingen and University
        %   of Stuttgart, Germany. Contact: christian.wuerslin@med.uni-tuebingen.de

        iMAXPATH = 1000;

        % -------------------------------------------------------------------------
        % Initialize the variables
        iPX  = int16(iPX);
        iPY  = int16(iPY);
        iXS = int16(iXS);
        iYS = int16(iYS);

        iX = zeros(iMAXPATH, 1, 'int16');
        iY = zeros(iMAXPATH, 1, 'int16');

        iLength = 1;
        iX(iLength) = iXS;
        iY(iLength) = iYS;
        % -------------------------------------------------------------------------

        % -------------------------------------------------------------------------
        % While not at the seed point: march back in the direction indicated by the
        % path maps iPX (x-direction) and iPY (y-direction).
        while (iPX(iYS, iXS) ~= 0) || (iPY(iYS, iXS) ~= 0) % We're not at the seed
            iXS = iXS + iPX(iYS, iXS);
            iYS = iYS + iPY(iYS, iXS);
            iLength = iLength + 1;
            iX(iLength) = iXS;
            iY(iLength) = iYS;
        end
        % -------------------------------------------------------------------------

        % -------------------------------------------------------------------------
        % revert vectors (to make it a forward path) and don't return the seed point.
        iX = iX(iLength - 1:-1:1);
        iY = iY(iLength - 1:-1:1);
        % -------------------------------------------------------------------------
    end

    function lp=func_is_cost(dImg, dWz, dWg, dWd)

    if nargin < 2,
        dWz = 0.2;
        dWg = 0.8;
        dWd = 0.2;
    end

    % -------------------------------------------------------------------------
    % Calculat the cost function

    % The gradient strength cost Fg
    dImg = double(dImg);
    [dY, dX] = gradient(dImg);
    dFg = sqrt(dX.^2 + dY.^2);
    dFg = 1 - dFg./max(dFg(:));

    % The zero-crossing cost Fz
    lFz = ~edge(dImg, 'zerocross');

    % The Sum:

    lp = dWz.*double(lFz)+ dWg.*dFg;
    end
end