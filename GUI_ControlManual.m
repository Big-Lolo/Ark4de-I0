function GUI_ControlManual()
    global robot camera robon camon %#ok<*GVMIS> 
    
    % verificar si ja està creada la finestra
    h_fig = findobj('Tag','GUI_RobotCartesia_Mandos');
    if isempty(h_fig)

        % Mostrar recordatori al crear
        disp('GUI_ControlManual:');
        disp(' Funció per controlar manualment el Braç Cartesià.');        
        disp(' Per activar/desactivar el Robot i Càmera utilitzeu GUI_RobotCartesia.');
        disp(' ');
             
        % Crear figura principal
        h_fig = figure;
        set(h_fig,'Tag','GUI_RobotCartesia_Mandos');
        set(h_fig,'MenuBar','none');
        set(h_fig,'name','Robot Cartesià: Control Manual [Robot:OFF / Càmera:OFF]');
        set(h_fig,'Position',[248 150 515 590]);  %[248 150 830 590]); %[248 150 570 590]); %[360 502 860 420]
        set(h_fig,'resize','off');
        set(h_fig,'NumberTitle','off');
        set(h_fig,'Interruptible','off');
        set(h_fig,'BusyAction','Cancel');
        set(h_fig,'CloseRequestFcn',@tancar);

  
        % Botons principals
        uicontrol('Style','pushbutton','String','Stop','Position',[340 350 160 40],'Tag','BSTOP','FontSize',18,'Callback',@Callback_BotoStop,'enable','off','BackgroundColor',[1 0 0]);    
        uicontrol('Style','pushbutton','String','Desbloqueja','Position',[340 300 160 40],'Tag','BDES','FontSize',18,'Callback',@Callback_BotoDesbloc,'enable','off'); 
        uicontrol('Style','pushbutton','String','Zero màquina','Position',[340 250 160 40],'Tag','BZM','FontSize',18,'Callback',@Callback_BotoZM,'enable','off');    
        uicontrol('Style','pushbutton','String','Llum ON','Position',[340 170 160 40],'Tag','BLLUM','FontSize',18,'BackgroundColor',[0.4 0.4 0.4],'Callback',@Callback_BotoLlum,'enable','off');
        uicontrol('Style','pushbutton','String','Pos. Guardar','Position',[340 120 160 40],'Tag','BSM','FontSize',18,'Callback',@Callback_BotoGuardar,'enable','off');

        % Botó i text de expandir opcions
        uicontrol('Style','pushbutton','String','>','Position',[480 20 20 60],'Tag','BEXP','FontSize',12,'Callback',@Callback_BotoExpandir,'enable','on');
        A{1,1} = 'Mostrar '; 
        A{1,2} = 'Potències '; 
        mls = sprintf('%s\n%s',A{1,1},A{1,2});
        uicontrol('Style','text','String',mls,'Position',[340 20 140 60],'FontSize',15,'BackgroundColor',[0.9 0.9 0.9],'tag','textExpandir', 'HorizontalAlignment','Right');    

        % Botons Stop eix
        uicontrol('Style','pushbutton','String','S','Position',[40 525 24 24],'Tag','BSX','FontSize',12,'Callback',@Callback_BotonsS,'enable','off','BackgroundColor',[1 0 0]);
        uicontrol('Style','pushbutton','String','S','Position',[100 525 24 24],'Tag','BSY','FontSize',12,'Callback',@Callback_BotonsS,'enable','off','BackgroundColor',[1 0 0]);
        uicontrol('Style','pushbutton','String','S','Position',[160 525 24 24],'Tag','BSZ','FontSize',12,'Callback',@Callback_BotonsS,'enable','off','BackgroundColor',[1 0 0]);
        uicontrol('Style','pushbutton','String','S','Position',[220 525 24 24],'Tag','BSR','FontSize',12,'Callback',@Callback_BotonsS,'enable','off','BackgroundColor',[1 0 0]);
        uicontrol('Style','pushbutton','String','S','Position',[280 525 24 24],'Tag','BSP','FontSize',12,'Callback',@Callback_BotonsS,'enable','off','BackgroundColor',[1 0 0]);
        
        % Botons Desfrena eix
        uicontrol('Style','pushbutton','String','D','Position',[40 495 24 24],'Tag','BBX','FontSize',12,'Callback',@Callback_BotonsB,'enable','off');
        uicontrol('Style','pushbutton','String','D','Position',[100 495 24 24],'Tag','BBY','FontSize',12,'Callback',@Callback_BotonsB,'enable','off');
        uicontrol('Style','pushbutton','String','D','Position',[160 495 24 24],'Tag','BBZ','FontSize',12,'Callback',@Callback_BotonsB,'enable','off');
        uicontrol('Style','pushbutton','String','D','Position',[220 495 24 24],'Tag','BBR','FontSize',12,'Callback',@Callback_BotonsB,'enable','off');
        uicontrol('Style','pushbutton','String','D','Position',[280 495 24 24],'Tag','BBP','FontSize',12,'Callback',@Callback_BotonsB,'enable','off');

        % Botons Zero Maquina eix
        uicontrol('Style','pushbutton','String','Z','Position',[40 465 24 24],'Tag','BZX','FontSize',12,'Callback',@Callback_BotonsZ,'enable','off');
        uicontrol('Style','pushbutton','String','Z','Position',[100 465 24 24],'Tag','BZY','FontSize',12,'Callback',@Callback_BotonsZ,'enable','off');
        uicontrol('Style','pushbutton','String','Z','Position',[160 465 24 24],'Tag','BZZ','FontSize',12,'Callback',@Callback_BotonsZ,'enable','off');
        uicontrol('Style','pushbutton','String','Z','Position',[220 465 24 24],'Tag','BZR','FontSize',12,'Callback',@Callback_BotonsZ,'enable','off');
        uicontrol('Style','pushbutton','String','Z','Position',[280 465 24 24],'Tag','BZP','FontSize',12,'Callback',@Callback_BotonsZ,'enable','off');

        
        % Sliders
        uicontrol('Style', 'slider','Position', [40  38 24 347],'Callback',@Callback_Sliders,'Tag','X','enable','off');
        uicontrol('Style', 'slider','Position', [100 38 24 347],'Callback',@Callback_Sliders,'Tag','Y','enable','off');
        uicontrol('Style', 'slider','Position', [160 38 24 347],'Callback',@Callback_Sliders,'Tag','Z','enable','off');
        uicontrol('Style', 'slider','Position', [220 38 24 347],'Callback',@Callback_Sliders,'Tag','R','enable','off');
        uicontrol('Style', 'slider','Position', [280 38 24 347],'Callback',@Callback_Sliders,'Tag','P','enable','off');

        % Plots per fer les barres de estat de la posicio
        ax = axes('Units','inches','position',[0.33   0.61   0.2   3.16],'Tag','AX');
        set(ax,'XLim',[0 1],'YLim',[0,1],'xTick',[], 'Color',[0.8 0.8 0.8], 'xColor',[0.8 0.8 0.8]);
        hold on;
        plot(ax,[0 1],[0.5 0.5],'b-','Tag','PlotX','LineWidth',2);
        hold off;

        ax = axes('Units','inches','position',[0.95  0.61   0.2   3.16],'Tag','AY');
        set(ax,'XLim',[0 1],'YLim',[0,1],'xTick',[], 'Color',[0.8 0.8 0.8], 'xColor',[0.8 0.8 0.8]);
        hold on;
        plot(ax,[0 1],[0.5 0.5],'b-','Tag','PlotY','LineWidth',2);
        hold off;

        ax = axes('Units','inches','position',[1.57   0.61   0.2   3.16],'Tag','AZ');
        set(ax,'XLim',[0 1],'YLim',[0,1],'xTick',[], 'Color',[0.8 0.8 0.8], 'xColor',[0.8 0.8 0.8]);
        hold on;
        plot(ax,[0 1],[0.5 0.5],'b-','Tag','PlotZ','LineWidth',2);
        hold off;

        ax = axes('Units','inches','position',[2.21  0.61   0.2   3.16],'Tag','AR');
        set(ax,'XLim',[0 1],'YLim',[0,1],'xTick',[], 'Color',[0.8 0.8 0.8], 'xColor',[0.8 0.8 0.8]);
        hold on;
        plot(ax,[0 1],[0.5 0.5],'b-','Tag','PlotR','LineWidth',2);
        hold off;

        ax = axes('Units','inches','position',[2.83  0.61   0.2   3.16],'Tag','AP');
        set(ax,'XLim',[0 1],'YLim',[0,1],'xTick',[], 'Color',[0.8 0.8 0.8], 'xColor',[0.8 0.8 0.8]);
        hold on;
        plot(ax,[0 1],[0.5 0.5],'b-','Tag','PlotP','LineWidth',2);
        hold off;


        % Etiquetes del nom del eix
        uicontrol('Style','text','String','X','Position',[40 12 24 25],'FontSize',18);
        uicontrol('Style','text','String','Y','Position',[100 12 24 25],'FontSize',18);
        uicontrol('Style','text','String','Z','Position',[160 12 24 25],'FontSize',18);
        uicontrol('Style','text','String','R','Position',[220 12 24 25],'FontSize',18);
        uicontrol('Style','text','String','P','Position',[280 12 24 25],'FontSize',18);

        % Text modificable per cada eix
        uicontrol('Style','edit','String','0','Position',[24  387 55 25],'Tag','XValor','FontSize',10,'Callback',@Callback_Edit);
        uicontrol('Style','edit','String','0','Position',[84  387 55 25],'Tag','YValor','FontSize',10,'Callback',@Callback_Edit);
        uicontrol('Style','edit','String','0','Position',[144 387 55 25],'Tag','ZValor','FontSize',10,'Callback',@Callback_Edit);
        uicontrol('Style','edit','String','0','Position',[204 387 55 25],'Tag','RValor','FontSize',10,'Callback',@Callback_Edit);
        uicontrol('Style','edit','String','0','Position',[264 387 55 25],'Tag','PValor','FontSize',10,'Callback',@Callback_Edit);

        % Text posicio atcual per cada eix
        uicontrol('Style','text','String','-','Position',[24  417 55 18],'Tag','XPos','FontSize',10,'BackgroundColor',[0.7 0.8 1]);
        uicontrol('Style','text','String','-','Position',[84  417 55 18],'Tag','YPos','FontSize',10,'BackgroundColor',[0.7 0.8 1]);
        uicontrol('Style','text','String','-','Position',[144 417 55 18],'Tag','ZPos','FontSize',10,'BackgroundColor',[0.7 0.8 1]);
        uicontrol('Style','text','String','-','Position',[204 417 55 18],'Tag','RPos','FontSize',10,'BackgroundColor',[0.7 0.8 1]);
        uicontrol('Style','text','String','-','Position',[264 417 55 18],'Tag','PPos','FontSize',10,'BackgroundColor',[0.7 0.8 1]);

        % Text Estat del eix
        uicontrol('Style','text','String','-','Position',[24  435 55 25],'Tag','XState','FontSize',12,'BackgroundColor',[0.7 0.8 1]);
        uicontrol('Style','text','String','-','Position',[84  435 55 25],'Tag','YState','FontSize',12,'BackgroundColor',[0.7 0.8 1]);
        uicontrol('Style','text','String','-','Position',[144 435 55 25],'Tag','ZState','FontSize',12,'BackgroundColor',[0.7 0.8 1]);
        uicontrol('Style','text','String','-','Position',[204 435 55 25],'Tag','RState','FontSize',12,'BackgroundColor',[0.7 0.8 1]);
        uicontrol('Style','text','String','-','Position',[264 435 55 25],'Tag','PState','FontSize',12,'BackgroundColor',[0.7 0.8 1]);

        % Sliders de potencia
        uicontrol('Style','slider','Position', [540 38 24 347],'Callback',@Callback_SlidersP,'Tag','XP','enable','off','Value',0,'Min',0,'Max',100000,'SliderStep',[1 10]/100);
        uicontrol('Style','slider','Position', [600 38 24 347],'Callback',@Callback_SlidersP,'Tag','YP','enable','off','Value',0,'Min',0,'Max',100000,'SliderStep',[1 10]/100);
        uicontrol('Style','slider','Position', [660 38 24 347],'Callback',@Callback_SlidersP,'Tag','ZP','enable','off','Value',0,'Min',0,'Max',100000,'SliderStep',[1 10]/100);
        uicontrol('Style','slider','Position', [720 38 24 347],'Callback',@Callback_SlidersP,'Tag','RP','enable','off','Value',0,'Min',0,'Max',100000,'SliderStep',[1 10]/100);
        uicontrol('Style','slider','Position', [780 38 24 347],'Callback',@Callback_SlidersP,'Tag','PP','enable','off','Value',0,'Min',0,'Max',100000,'SliderStep',[1 10]/100);

        % Etiquetes valor de potencia
        uicontrol('Style','text','String','-','Position',[524 395 55 20],'Tag','XPValor','FontSize',10,'BackgroundColor',[0.8 0.9 0.8]);
        uicontrol('Style','text','String','-','Position',[584 395 55 20],'Tag','YPValor','FontSize',10,'BackgroundColor',[0.8 0.9 0.8]);
        uicontrol('Style','text','String','-','Position',[644 395 55 20],'Tag','ZPValor','FontSize',10,'BackgroundColor',[0.8 0.9 0.8]);
        uicontrol('Style','text','String','-','Position',[704 395 55 20],'Tag','RPValor','FontSize',10,'BackgroundColor',[0.8 0.9 0.8]);
        uicontrol('Style','text','String','-','Position',[764 395 55 20],'Tag','PPValor','FontSize',10,'BackgroundColor',[0.8 0.9 0.8]);

        % Etiquetes del nom dels eixos per la potencia
        uicontrol('Style','text','String','X','Position',[540 12 24 25],'FontSize',18);
        uicontrol('Style','text','String','Y','Position',[600 12 24 25],'FontSize',18);
        uicontrol('Style','text','String','Z','Position',[660 12 24 25],'FontSize',18);
        uicontrol('Style','text','String','R','Position',[720 12 24 25],'FontSize',18);
        uicontrol('Style','text','String','P','Position',[780 12 24 25],'FontSize',18);

        % Botons de les memories
        uipanel('Title','Memoritzar Posicions','FontSize',9,'Units','Pixels','Position',[524 435 295 130]);    
        uicontrol('Style','pushbutton','String','S1','Position',[540 515 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','P1','Position',[540 485 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','S2','Position',[580 515 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','P2','Position',[580 485 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','S3','Position',[620 515 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','P3','Position',[620 485 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','S4','Position',[660 515 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','P4','Position',[660 485 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','S5','Position',[700 515 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','P5','Position',[700 485 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','S6','Position',[740 515 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','P6','Position',[740 485 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','S7','Position',[780 515 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','P7','Position',[780 485 30 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotonsMem,'enable','off');
        uicontrol('Style','pushbutton','String','Mostrar Memòries','Position',[625 450 100 24],'Tag','BM','FontSize',8,'Callback',@Callback_BotoMostrarMem,'enable','off');

        % Mostrar Imatge pel preview de la camera    
        ax = axes('Units','Pixels','position',[340 395 160 160],'Tag','AXES_CAMERA_IMG');
        image(zeros(480,640,3),'Tag','CAMERA_IMG');
        axis(ax,'image'); % ajustar-se a la imatge mostrada    
        set(ax,'xTick',[]);
        set(ax,'yTick',[]);

        % Opcions de activar/desactivar monitor
        uicontrol('Style','Checkbox','String','Monitor Robot','Tag','CBR','Value',0,'Position',[345 560 130 20],'FontSize',10,'Callback',@Callback_CheckMonitor);
        uicontrol('Style','Checkbox','String','Monitor Càmera','Tag','CBC','Value',0,'Position',[345 540 130 20],'FontSize',10,'Callback',@Callback_CheckMonitor);

        % Text Mostrar Accions
        uicontrol('Style','text','String','---------','Position',[20 557 300 23],'Tag','TextComanda','FontSize',14,'BackgroundColor',[0.9 0.9 0.6], 'FontName','Calibri');


        % Crear timers per actualitzar GUI
        trob = timerfind('Tag','TimerUpdateRobot');
        if (isempty(trob))
            timer('TimerFcn',@Callback_TimerRobot,'Period',0.2,'Tag','TimerUpdateRobot','executionMode','fixedSpacing','BusyMode','drop');
        end
        tcam = timerfind('Tag','TimerUpdateCamera');
        if (isempty(tcam))
            timer('TimerFcn',@Callback_TimerCamera,'Period',0.2,'Tag','TimerUpdateCamera','executionMode','fixedSpacing','BusyMode','drop');
        end
        tGUI = timerfind('Tag','TimerUpdateGUIMandos');
        if (isempty(tGUI))
            timer('TimerFcn',@Callback_TimerGUI,'Period',1,'Tag','TimerUpdateGUIMandos','executionMode','fixedSpacing','BusyMode','drop');            
        end

        % Inici completament desactivat
        robon = 0;
        camon = 0;
        desactivar_mandos();
        desactivar_camera();
            
        % Obtenir le instancies de control del robot i de la càmera
        if isempty(robot)
            robot = robotcart;               
        end
        if isempty(camera)
            camera = robotcam;
        end

        % Start timer general (actualització connexió Robot i Càmera)
        start(timerfind('Tag','TimerUpdateGUIMandos'));
    end           
            
    % mostrar en primer pla
    figure(h_fig);

end

%/////////////////////////////////////////////////////////////////////////
% FUNCIONS ESTAT APLICACIO
%/////////////////////////////////////////////////////////////////////////
function Callback_CheckMonitor(hobj,eventdata) %#ok<*INUSD> 
    ckbRobot = get(findobj('Tag','CBR'),'Value');
    ckbCamera = get(findobj('Tag','CBC'),'Value');
    
    if (ckbRobot)
        stop(timerfind('Tag','TimerUpdateRobot'));
        start(timerfind('Tag','TimerUpdateRobot'));

        for i='XYZRP'
            set(findobj('Tag',['Plot' i]),'Color',[0 0 1]);
        end
        
    else
        stop(timerfind('Tag','TimerUpdateRobot'));
        
        for i='XYZRP'
            set(findobj('Tag',[i 'State']),'string','-');
            set(findobj('Tag',[i 'Pos']),'String','-');
            set(findobj('Tag',['Plot' i]),'Color',[0.8 0.8 0.8]);
            set(findobj('Tag',['A' i]),'Color',[0.8 0.8 0.8]);
        end
    end
      
    if (ckbCamera)
        stop(timerfind('tag','TimerUpdateCamera'));
        start(timerfind('tag','TimerUpdateCamera'));
    else
        stop(timerfind('tag','TimerUpdateCamera'));  
    end
    
end
function activar_mandos()
    global robon
    
    % Si no esta el port de comunicacio actiu
    % no es permet activar els controls
    if (robon == 0), return; end
    
    set(findobj('Style','pushbutton','String','S'),'enable','on');
    set(findobj('Style','pushbutton','String','D'),'enable','on');
    set(findobj('Style','pushbutton','String','Z'),'enable','on');
        
    set(findobj('Tag','BSTOP'),'enable','on');
    set(findobj('Tag','BDES'),'enable','on');
    set(findobj('Tag','BZM'),'enable','on');  
    set(findobj('Tag','BLLUM'),'enable','on');
    set(findobj('Tag','BSM'),'enable','on');  
    set(findobj('Tag','BEXP'),'enable','on');
    
    set(findobj('Tag','X'),'enable','on');
    set(findobj('Tag','Y'),'enable','on');
    set(findobj('Tag','Z'),'enable','on');
    set(findobj('Tag','R'),'enable','on');
    set(findobj('Tag','P'),'enable','on');
        
    set(findobj('Tag','XValor'),'enable','on');
    set(findobj('Tag','YValor'),'enable','on');
    set(findobj('Tag','ZValor'),'enable','on');
    set(findobj('Tag','RValor'),'enable','on');
    set(findobj('Tag','PValor'),'enable','on');
    
    set(findobj('Tag','XP'),'enable','on');
    set(findobj('Tag','YP'),'enable','on');
    set(findobj('Tag','ZP'),'enable','on');
    set(findobj('Tag','RP'),'enable','on');
    set(findobj('Tag','PP'),'enable','on');
        
    set(findobj('Tag','BM'),'enable','on');
    
    set(findobj('Tag','CBR'),'enable','on');
       
    % recuperar valors dels slides
    setSlidesValues();
    
    % Arrancar timers Monitors Robot/camera si es necessari
    Callback_CheckMonitor();
end 
function desactivar_mandos()    
    % Parar timers
    stop(timerfind('tag','TimerUpdateRobot'));
    
    set(findobj('Style','pushbutton','String','S'),'enable','off');
    set(findobj('Style','pushbutton','String','D'),'enable','off');
    set(findobj('Style','pushbutton','String','Z'),'enable','off');
        
    set(findobj('Tag','BSTOP'),'enable','off');
    set(findobj('Tag','BDES'),'enable','off');
    set(findobj('Tag','BZM'),'enable','off');  
    set(findobj('Tag','BLLUM'),'enable','off');
    set(findobj('Tag','BSM'),'enable','off');  
    set(findobj('Tag','BEXP'),'enable','off');
    
    set(findobj('Tag','X'),'enable','off');
    set(findobj('Tag','Y'),'enable','off');
    set(findobj('Tag','Z'),'enable','off');
    set(findobj('Tag','R'),'enable','off');
    set(findobj('Tag','P'),'enable','off');
        
    set(findobj('Tag','XValor'),'enable','off');
    set(findobj('Tag','YValor'),'enable','off');
    set(findobj('Tag','ZValor'),'enable','off');
    set(findobj('Tag','RValor'),'enable','off');
    set(findobj('Tag','PValor'),'enable','off');
    
    set(findobj('Tag','XP'),'enable','off');
    set(findobj('Tag','YP'),'enable','off');
    set(findobj('Tag','ZP'),'enable','off');
    set(findobj('Tag','RP'),'enable','off');
    set(findobj('Tag','PP'),'enable','off');
        
    set(findobj('Tag','BM'),'enable','off');

    set(findobj('Tag','CBR'),'enable','off');
end 
function activar_camera()
    set(findobj('Tag','CBC'),'value',0);
    set(findobj('Tag','CBC'),'enable','on');

    % Posem imatge negra
    im = zeros(480,640,3);
    set(findobj('tag','CAMERA_IMG'),'CData',im);
    % ajustar escala del axis de la imatge
    h_axes = get(findobj('tag','CAMERA_IMG'),'Parent');
    axis(h_axes,'image');  
end
function desactivar_camera()
    set(findobj('Tag','CBC'),'value',0);
    set(findobj('Tag','CBC'),'enable','off');

    % Posem imatge grisa
    im = 0.5.*ones(480,640,3);
    set(findobj('tag','CAMERA_IMG'),'CData',im);
    % ajustar escala del axis de la imatge
    h_axes = get(findobj('tag','CAMERA_IMG'),'Parent');
    axis(h_axes,'image');        


    % Para el timer de captura de frames
    stop(timerfind('tag','TimerUpdateCamera'));
end
function tancar(hobj,eventdata)

    % eliminar timers
    trob = timerfind('Tag','TimerUpdateRobot');
    tcam = timerfind('Tag','TimerUpdateCamera');
    tGUI = timerfind('Tag','TimerUpdateGUIMandos');
    if (~isempty(trob))
        stop(trob);
        delete(trob);
    end
    if (~isempty(tcam))
        stop(tcam);
        delete(tcam);
    end  
    if (~isempty(tGUI))
        stop(tGUI);
        delete(tGUI);
    end  
    
    % tancar finestra
    close('force');
end
function setSlidesValues()
    global robot
    eixos = 'XYZRP';
    [ok,miss] = robot.senddata('CM');
    [ok3,miss3] = robot.senddata('CE');

    % Posar posicions dels sliders (min, max i actual)
    if(ok && ok3 && numel(miss) == 5 && numel(miss3) == 5)
        for i=1:5
            if(miss(i) ~= 0)

                val = miss3(i);
                if (val > miss(i)), val = miss(i); end
                if (val < 0), val = 0; end

                set(findobj('Tag',eixos(i)),'Value',val,'Min',0,'Max',miss(i),'SliderStep',[1/miss(i) 0.04]);
                set(findobj('Tag',[eixos(i) 'Valor']),'String',num2str(val));



                set(findobj('Tag',['A' eixos(i)]),'YLim',[0 miss(i)]);
                set(findobj('Tag',['Plot' eixos(i)]),'YData',[val val]);
                ytick = get(findobj('Tag',['A' eixos(i)]),'YTick');
                if (ytick(end) > miss(i)-10)
                    ytick(end) = miss(i);
                else
                    ytick = [ytick miss(i)];                %#ok<*AGROW> 
                end
                set(findobj('Tag',['A' eixos(i)]),'YTick',ytick);
            end
        end
    else
        disp('ERROR: Al cargar valors setSlidesValues().');
    end

    % Posar valors de les potencies (PWM)
    [ok2,miss2] = robot.senddata('CP');
    if(ok2 && numel(miss2) == 5 && numel(miss) == 5)
        for i=1:5
            if(miss(i) ~= 0)
                set(findobj('Tag',[eixos(i) 'P']),'Value', miss2(i));
                set(findobj('Tag',[eixos(i) 'PValor']),'String',[num2str(round(miss2(i)/1000)) ' %']);
            end
        end
    else
        disp('ERROR: Al cargar valors setSlidesValues().');
    end
end


%/////////////////////////////////////////////////////////////////////////
% BOTONS PRINCIPALS
%/////////////////////////////////////////////////////////////////////////
function Callback_BotoStop(hobj,eventdata)
    global robot
    [ok,miss] = robot.senddata('S'); %#ok<*ASGLU> 
    set(findobj('Tag','TextComanda'),'string','S');
end
function Callback_BotoDesbloc(hobj,eventdata)
    global robot
    [ok,miss] = robot.senddata('BR');
    set(findobj('Tag','TextComanda'),'string','BR');
end
function Callback_BotoZM(hobj,eventdata)    
    global robot
    set(hobj,'String','Espera...');
    desactivar_mandos();
    set(findobj('Tag','TextComanda'),'string','ZM');

    % Fer el zero màquina
    [ok,miss] = robot.senddatawait('ZM');

    if (ok)
        disp('ZERO MAQUINA FINALITZAT');
    else
        disp('PROBLEMA DURANT EL ZERO MAQUINA');
    end

    activar_mandos();
    set(hobj,'String','Zero màquina');
end
function Callback_BotoLlum(hobj,eventdata)
    global robot

    val = get(hobj,'String');
    if(strcmp(val,'Llum ON'))    
        set(hobj,'String','Llum OFF','BackgroundColor',[1 1 0.1]); 
        set(findobj('Tag','TextComanda'),'string',['L ', num2str(100000*0.7)]);
        [ok,miss] = robot.senddata(['L ' num2str(100000*0.7)]);
    else   
        set(hobj,'String','Llum ON','BackgroundColor',[0.4 0.4 0.4]);
        set(findobj('Tag','TextComanda'),'string','L 0');
        [ok,miss] = robot.senddata('L 0');
    end
end
function Callback_BotoGuardar(hobj,eventdata)
    global robot;
    set(findobj('Tag','TextComanda'),'string','SM');
    [ok,miss]=robot.senddatawait('SM');

    if(ok)
        disp('Moviment Emmagatzematge Fet!');
    else
        disp('Problema al realitzar el moviment');
    end
end
function Callback_BotoExpandir(hobj,eventdata)
    h = findobj('Tag','GUI_RobotCartesia_Mandos');
    if strcmp(get(hobj,'String'),'<')
        pos = get(h,'Position');
        pos(3) = 515;
        set(h,'Position',pos);
        set(hobj,'String','>');
        A{1,1} = 'Mostrar '; 
        A{1,2} = 'Potències ';
        mls = sprintf('%s\n%s',A{1,1},A{1,2});
        set(findobj('tag','textExpandir'),'String',mls);
    else
        pos = get(h,'Position');
        pos(3) = 830;
        set(h,'Position',pos);
        set(hobj,'String','<');
        A{1,1} = 'Ocultar '; 
        A{1,2} = 'Potències '; 
        mls = sprintf('%s\n%s',A{1,1},A{1,2});
        set(findobj('tag','textExpandir'),'String',mls);    
    end
end
%/////////////////////////////////////////////////////////////////////////


%/////////////////////////////////////////////////////////////////////////
% BOTONS PER CADA EIX
%/////////////////////////////////////////////////////////////////////////
function Callback_BotonsS(hobj,eventdata) %boto para un eix
    global robot
    eix = get(hobj,'Tag');
    eix = eix(3);
    set(findobj('Tag','TextComanda'),'string',['S' eix]);
    [ok,miss] = robot.senddata(['S' eix]);
end
function Callback_BotonsB(hobj,eventdata) %boto desfrena un eix
    global robot
    eix = get(hobj,'Tag');
    eix = eix(3);
    set(findobj('Tag','TextComanda'),'string',['BR' eix]);
    [ok,miss] = robot.senddata(['BR' eix]);
end
function Callback_BotonsZ(hobj,eventdata) %boto zero maquina d'un eix
    global robot
    eix = get(hobj,'Tag');
    eix = eix(3);
    set(findobj('Tag','TextComanda'),'string',['ZM' eix]);

    [ok,miss] = robot.senddatawait(['ZM' eix]);

    if  ok
        disp(['ZERO MAQUINA EIX (' eix ') FINALITZAT']);
    else
        disp('PROBLEMA DURANT ZERO MÀQUINA');
    end

end
%/////////////////////////////////////////////////////////////////////////


%/////////////////////////////////////////////////////////////////////////
% SLIDERS DESPLAÇAMENT I POTENCIA
%/////////////////////////////////////////////////////////////////////////
function Callback_Sliders(hobj,eventdata)
    global robot
    
    % Arrodonim i actualitzem a la barra
    val = round(get(hobj,'Value'));
    set(hobj,'Value',val);
    
    set(findobj('Tag','TextComanda'),'string',['M' get(hobj,'Tag') ' '  num2str(val)]);
    [ok,miss] = robot.senddata(['M' get(hobj,'Tag') ' ' num2str(val)]);       
        
    if (~ok)
        disp(miss); 
    else
        set(findobj('Tag',[get(hobj,'Tag') 'Valor']),'String',num2str(val));
    end
end
function Callback_Edit(hobj,eventdata)
    global robot
    val = str2num(get(hobj,'String')); %#ok<*ST2NM> 
    if(~isempty(val))
        eix = get(hobj,'Tag');    
        maxValue = get(findobj('Tag',eix(1)),'Max');    
        if(val <= maxValue && val >= 0)
            set(findobj('Tag','TextComanda'),'string',['M' eix(1) ' ' num2str(val) ]);
            [ok,miss] = robot.senddata(['M' eix(1) ' ' num2str(val)]);
            if ~ok
                disp(miss);
            else
                set(findobj('Tag',eix(1)),'Value',val);
            end
        else
            disp(['Valor massa gran (max = ' num2str(maxValue) ')']);
        end
    end
end
function Callback_SlidersP(hobj,eventdata)
    global robot
    val = round(get(hobj,'Value')/1000)*1000; % de 1 en 1 %
    eix = get(hobj,'Tag');
    set(findobj('Tag','TextComanda'),'string',['P' eix(1) ' ' num2str(val)]);

    [ok,miss] = robot.senddata(['P' eix(1) ' ' num2str(val)]);

    if (~ok)
         disp(miss);
    else
        set(hobj,'Value',val);
        eix = get(hobj,'Tag');
        tag = [eix(1) 'PValor'];
        set(findobj('Tag',tag),'String',[num2str(round(val/1000)) ' %']);
    end
end
%/////////////////////////////////////////////////////////////////////////


%/////////////////////////////////////////////////////////////////////////
% BOTONS MEMORITZAR POSICIONS
%/////////////////////////////////////////////////////////////////////////
function Callback_BotonsMem(hobj,eventdata)
    global posMem
    global robot
    if(isempty(posMem))
        try
            load posMem.mat posMem;
        catch
            posMem = zeros(7,10);
        end
    end
    str = get(hobj,'string');
    accio = str(1);
    pos = str2num(str(2));

    if(accio == 'S')

        [ok,miss] = robot.senddata('CE');
        miss(miss<0)=0;

        [ok2,miss2] = robot.senddata('CP');

        if(ok && numel(miss) == 5 && ok2 && numel(miss2) == 5)
            posMem(pos,:) =  [miss miss2];
            save posMem.mat posMem;
            disp(['Guardada posició: ' num2str(pos)]);
        else
            disp('ERROR AL GUARDAR LES DADES');
        end
    else
         desactivar_mandos();
         p=posMem(pos,6:10);
         [ok,miss] = robot.senddata(['P ' num2str(p(1)) ' ' num2str(p(2)) ' ' num2str(p(3)) ' ' num2str(p(4)) ' ' num2str(p(5))]);

         p=posMem(pos,1:5);
         disp(['Anar a posició: ' num2str(pos)]);
         [ok,miss]=robot.senddatawait(['M ' num2str(p(1)) ' ' num2str(p(2)) ' ' num2str(p(3)) ' ' num2str(p(4)) ' ' num2str(p(5))]);

         activar_mandos();
    end
end
function Callback_BotoMostrarMem(hobj,eventdata)
    global posMem
    if(isempty(posMem))
        try
            load posMem.mat posMem;
        catch
            posMem = zeros(7,10);
        end
    end
    disp('---------------------------------------------------');
    disp('              POSICIÓ       |       POTENCIA ');
    disp('---------------------------------------------------')
    disp('MEM|    X   Y   Z   R   P   |    X   Y   Z   R   P ');
    disp('---------------------------------------------------');
    for i=1:7
        cad = [];
        for j=1:10
            if(j == 6)
                cad = [cad  '   | '];
            end
            if(j>5)
                num = num2str(round(posMem(i,j)/1000));
            else
                num = num2str(posMem(i,j));            
            end        
            switch numel(num)
                case 1
                   cad = [cad  '   ' num];
                case 2
                   cad = [cad  '  ' num];
                case 3
                   cad = [cad  ' ' num];
            end               
        end
        cad = [num2str(i) '  | ' cad];
        disp(cad);
    end
    disp('---------------------------------------------------');
end
%/////////////////////////////////////////////////////////////////////////


%/////////////////////////////////////////////////////////////////////////
% CALLBACKS TIMERS
%/////////////////////////////////////////////////////////////////////////
% Controla el mostreig de imatges de la camera
function Callback_TimerCamera(hobj,eventdata)
global camera

    % Comprovar que existeixi la API
    if(isempty(camera)), return; end
    
    im = camera.getframe();
    if (~isempty(im))
        set(findobj('tag','CAMERA_IMG'),'CData',im);
    
        % ajustar escala del axis de la imatge
        h_axes = get(findobj('tag','CAMERA_IMG'),'Parent');
        axis(h_axes,'image');
    end
end

% Controla el mostreig de estat dels eixos del robot
function Callback_TimerRobot(hobj,eventdata)
    global robot    

    % Actualitzar el estat dels eixos
    [ok,miss] = robot.senddata('CS');    
    if(ok && numel(miss)==9)
        eix = 'X Y Z R P';
        for i = [1 3 5 7 9]
            % canviar de color per avisar del Brake
            if(miss(i) == 'B')
                if isequal(get(findobj('Tag',['A' eix(i)]),'Color'),[0.8 0.8 0.8])
                    set(findobj('Tag',['A' eix(i)]),'Color',[1 0 0]);
                end
            else
                if isequal(get(findobj('Tag',['A' eix(i)]),'Color'),[1 0 0])
                    set(findobj('Tag',['A' eix(i)]),'Color',[0.8 0.8 0.8]);
                end
            end
            
            % Posar el valor del estat per cada eix
            set(findobj('Tag',[eix(i) 'State']),'string',miss(i));
            
        end 
    else
        %disp('ERROR TimerRobot: Consultar Estat.');
    end
    
    % Actualitzar la posició dels eixos
    [ok2,miss2] = robot.senddata('CE');
    if(ok2 && numel(miss2) == 5)
        eixos = 'XYZRP';
        for i=1:5
            set(findobj('Tag',['Plot' eixos(i)]),'YData',[miss2(i) miss2(i)]);
            set(findobj('Tag',[eixos(i) 'Pos']),'String',num2str(miss2(i)));
        end
    else
        %disp('ERROR TimerRobot: Consultar Encoders.');
    end
end

% Controla el estat de la GUI (connexió del Robot i Càmera)
function Callback_TimerGUI(hobj,eventdata)
    global robot camera robon camon
    
    h_fig = findobj('Tag','GUI_RobotCartesia_Mandos');
    
    % Llegir estats API Robot i Camera (connectat/desconnectat)
    ok1 = 0;
    if(~isempty(robot)), [ok1,miss1] = robot.status(); end
    if (ok1 == 0), miss1 = 'OFF'; end
    ok2 = 0;
    if(~isempty(camera)), [ok2,miss2] = camera.status(); end
    if (ok2 == 0), miss2 = 'OFF'; end
    
    % Actualitzar titol de la finestra
    set(h_fig,'name',['Robot Cartesià Control Manual [Robot: ' miss1 ' / Càmera: ' miss2 ']']);
            
    % Actualitzar estat robot si es necessari
    if(robon == 0 && ok1 == 1)
        robon = 1;        
        activar_mandos();
    elseif(robon == 1 && ok1 == 0)
        robon = 0;
        desactivar_mandos();
    end
    
    % Actualitzar estat camera si es necessari
    if (camon == 0 && ok2 == 1)
        camon = 1;
        activar_camera();
    elseif (camon == 1 && ok2 == 0)
        camon = 0;
        desactivar_camera();
    end
        
end

