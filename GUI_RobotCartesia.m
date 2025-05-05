function GUI_RobotCartesia
    global robot camera %#ok<*GVMIS> 

    h = findobj('Tag','GUI_RobotCartesia');
    if isempty(h)

        % crear el figure normal
        h = figure;
        set(h,'numbertitle','off');               % treu el numero de figura
        set(h,'name','Robot Cartesià - EPS [Robot: OFF / Càmera: OFF]');
        set(h,'MenuBar','none');                  % treiem el menu d'icons
        set(h,'doublebuffer','on');               % dos buffers de grafics
        set(h,'Interruptible','off');
        set(h,'Tag','GUI_RobotCartesia');
        set(h,'CloseRequestFcn',@stopBucle);
    
        % Construïm barra de menú
        hmenu = uimenu('Label','&RobotCartesia','Tag','MENU_WORKING');
            uimenu(hmenu,'Label','Connectar','Callback',@connectarRobot,'Tag','MENU_CON_ROB','enable','on');
            uimenu(hmenu,'Label','Desconnectar','Callback',@tancarRobot,'Tag','MENU_DES_ROB','enable','off');
            uimenu(hmenu,'Label','Activar GUI Control Manual','Callback',@activarControlManual,'separator','on');
            uimenu(hmenu,'Label','EXIT (tancar programa)','Callback',@tancar,'Tag','MENU_TANCAR_PROGRAM','separator','on'); 
            uimenu(hmenu,'Label','EXIT (tancar programa / càmera / connexió amb robot)','Callback',@tancar,'Tag','MENU_TANCAR_ALL'); 

        hmenu = uimenu('Label','&Càmera','Tag','MENU_WORKING');
            uimenu(hmenu,'Label','Connectar (amb USB Webcams Package)','Callback',@connectarCamera,'Tag','MENU_CON_CAM');
            uimenu(hmenu,'Label','Desactivar','Callback',@tancarCamera,'tag','MENU_DES_CAM','enable','off');
            uimenu(hmenu,'Label','improfile','Callback','improfile;','enable','off','tag','MENU_WEBCAM','separator','on');
            uimenu(hmenu,'Label','Capturar 1 imatge','Callback',@capturaImatge,'enable','off','tag','MENU_WEBCAM');
            uimenu(hmenu,'Label','Guardar Imatge...','Callback',@guardarImatge,'enable','off','tag','MENU_WEBCAM');

        hmenu = uimenu('Label','&Exemples','Tag','MENU_WORKING');
            uimenu(hmenu,'Label','Ex1: Obtenir imatges de la càmera en bucle','Callback',@exemple1,'tag','MENU_ALUMNES','enable','off');  
            uimenu(hmenu,'Label','Ex2: Moure eix X al extrem','Callback',@exemple2,'tag','MENU_ALUMNES','enable','off');  
            uimenu(hmenu,'Label','Ex3: Capturar imatges mentre es mou el braç','Callback',@exemple3,'tag','MENU_ALUMNES','enable','off');  
            uimenu(hmenu,'Label','Ex4: Moure eix X i detectar i agafar stick','Callback',@exemple4,'tag','MENU_ALUMNES','enable','off');  
            uimenu(hmenu,'Label','Ex5: Sistema de control per centrar pinça','Callback',@exemple5,'tag','MENU_ALUMNES','enable','off');
            uimenu(hmenu,'Label','Ex6: Seqüencia de moviments amb estructura','Callback',@exemple6,'tag','MENU_ALUMNES','enable','off');

        hmenu = uimenu('Label','&Estudiants','Tag','MENU_WORKING');
            uimenu(hmenu,'Label','Codi1: ...','Callback',@codi1,'tag','MENU_ALUMNES','enable','off');  
            uimenu(hmenu,'Label','Codi2: ...','Callback',@codi2,'tag','MENU_ALUMNES','enable','off');


        % Obtenir le instancies de control del robot i de la càmera
        if isempty(robot)
            robot = robotcart;
        end
        if isempty(camera)
            camera = robotcam;
        end
        
        % Capturar una imatge si ja esta conectat a la camera
        [ok, miss] = camera.status(); %#ok<*ASGLU> 
        if(ok)
            capturaImatge(0,0);
        end

        % Start timer general (actualització connexió Robot i Càmera)
        tGUI = timerfind('Tag','TimerUpdateGUI');
        if (isempty(tGUI))
            tGUI = timer('TimerFcn',@timerUpdateGUI,'Period',1,'Tag','TimerUpdateGUI','executionMode','fixedSpacing','BusyMode','drop');            
        end    
        stop(tGUI);
        start(tGUI);

    else
        % mostrar figure en primer pla
        figure(h);
    end
end


% Controla el estat de la GUI (connexió del Robot i Càmera)
function timerUpdateGUI(hobj,eventdata) %#ok<*INUSD> 
    global robot camera
    
    h_fig = findobj('Tag','GUI_RobotCartesia');
    
    % Llegir estats API Robot i actualitzar GUI (connectat/desconnectat)
    ok1 = 0;
    if(~isempty(robot)), [ok1,miss1] = robot.status(); end
    if (ok1)
        % Activar/desactivar funcions de menu
        set(findobj('Tag','MENU_CON_ROB'),'enable','off');
        set(findobj('Tag','MENU_DES_ROB'),'enable','on');
        set(findobj('Tag','MENU_ALUMNES'),'enable','on');
    else
        % Activar/desactivar funcions de menu
        set(findobj('Tag','MENU_CON_ROB'),'enable','on');
        set(findobj('Tag','MENU_DES_ROB'),'enable','off');
        set(findobj('Tag','MENU_ALUMNES'),'enable','off');
        
        miss1 = 'OFF';
    end
       
    % Llegir estats API Càmera i actualitzar GUI (connectat/desconnectat)
    ok2 = 0;
    if(~isempty(camera)), [ok2,miss2] = camera.status(); end
    if (ok2)
        % Activar/desactivar funcions de menu
        set(findobj('Tag','MENU_CON_CAM'),'enable','off');
        set(findobj('Tag','MENU_DES_CAM'),'enable','on');
        set(findobj('Tag','MENU_WEBCAM'),'enable','on');
    else
        % Activar/desactivar funcions de menu
        set(findobj('Tag','MENU_CON_CAM'),'enable','on');
        set(findobj('Tag','MENU_DES_CAM'),'enable','off');
        set(findobj('Tag','MENU_WEBCAM'),'enable','off');
        
        miss2 = 'OFF'; 
    end
    
    % Actualitzar titol de la finestra
    set(h_fig,'name',['Robot Cartesià - EPS [Robot: ' miss1 ' / Càmera: ' miss2 ']']);

end

%//////////////////////////////////////////////////////////////////////////
% FUNCIONS DE MENÚ
%//////////////////////////////////////////////////////////////////////////
function connectarRobot(hobj,eventdata)
global robot

    % Crear instancia si no existeix
    if isempty(robot)    
        robot = robotcart;
    end

    % intentar fer la connexió
    [ok,miss] = robot.openauto();

    if (ok)
        disp(['CONNECTAT! (' miss ')']);
        
        % Fer Zero Màquina inicial
        disp('FENT Zero Màquina...');
        [ok,miss] = robot.senddatawait('ZM');
        disp('FI Zero Màquina');
    else
        disp('ATENCIÓ: NO HI HA CONNEXIÓ AMB EL ROBOT CARTESIÀ');
        disp(['ATENCIÓ: ' miss]);       
    end
    
    % Actualitzar estat GUI (menús i títols)
    timerUpdateGUI(0,0);

end
function tancarRobot(hobj,eventdata)
global robot

    % Crear instancia si no existeix
    if isempty(robot)    
        robot = robotcart;
    end
    
    % intentar tancar connexió
    [ok,miss] = robot.closeport();
    
    if (ok)
        disp(['DESCONNECTAT. (' miss ')']);
    else
        disp('ERROR: NO S''HA POGUT DESCONNECTAR!');
        disp(['ERROR: ' miss]);
    end
    
    % Actualitzar estat GUI (menús i títols)
    timerUpdateGUI(0,0);
end
function connectarCamera(hobj,eventdata)
global camera

    % Crear instancia si no existeix
    if isempty(camera)    
        camera = robotcam;
    end

    % intentar fer la connexió
    [ok,miss] = camera.opencam();

    if (ok)
        disp(['CÀMERA CONNECTADA! (' miss ')']);
        
        % obtenir i mostrar imatge
        capturaImatge(0,0);
        
    else
        disp('ATENCIÓ: NO HI HA CONNEXIÓ AMB LA CÀMERA');
        disp(['ATENCIÓ: ' miss]);       
    end
    
    % Actualitzar estat GUI (menús i títols)
    timerUpdateGUI(0,0);
end
function tancarCamera(hobj,eventdata)
global camera

    % Crear instancia si no existeix
    if isempty(camera)    
        camera = robotcam;
    end
    
    % intentar tancar connexió
    [ok,miss] = camera.closecam();
    
    if (ok)
        disp(['DESCONNECTADA. (' miss ')']);
    else
        disp('ERROR: NO S''HA POGUT DESCONNECTAR!');
        disp(['ERROR: ' miss]);
    end
    
    % Actualitzar estat GUI (menús i títols)
    timerUpdateGUI(0,0);
end
function tancar(hobj,eventdata)
    switch get(hobj,'Tag')
    case 'MENU_TANCAR_PROGRAM'
        % tancar el programa
        close('force');

    case 'MENU_TANCAR_ALL'
        % programa, connexió amb el robot i control remot
        ButtonName = questdlg('Segur que vols tancar el programa, el port del Robot i la càmera','Tancar','Si','No','Si');

        if (strcmp(ButtonName,'Si'))

            % tancar la camera
            tancarCamera(0,0);

            % tancar el robot
            tancarRobot(0,0);

            % eliminar timer GUI
            tGUI = timerfind('Tag','TimerUpdateGUI');
            if (~isempty(tGUI))
                stop(tGUI);
                delete(tGUI);
            end

            % tancar finestra
            close('force');
        end
    end
end
function stopBucle(hobj,eventdata)
global btnXflag
    % Flag de premer el boto 'X'
    btnXflag = 1;
    
    % Activar menus
    set(findobj('Tag','MENU_WORKING'),'enable','on');

end
function activarControlManual(hobj,eventdata)
    % Activar/mostrar la GUI de control remot
    GUI_ControlManual();
end
function capturaImatge(hobj,eventdata)
global camera
    
    % obtenir i mostrar imatge
    im = camera.getframe();
    imagesc(im,'Tag','GUI_IMATGE');
    title('');
    refresh;
    drawnow;
        
end
function guardarImatge(hobj,eventdata)
    im = get(findobj('Tag','GUI_IMATGE'),'CData');
    if(isempty(im))
        uiwait(warndlg('No hi ha cap imatge per guardar!', 'Atenció !!'));
    else
        [filename, pathname] = uiputfile('*.bmp','BMP format');
        if ~isequal(filename,0) && ~isequal(pathname,0)
            imwrite(im,[pathname filename],'bmp');
        end    
    end
end


%//////////////////////////////////////////////////////////////////////////
% INICI CODIS EXEMPLE
%//////////////////////////////////////////////////////////////////////////

% Example 1: Obtenir imatges de la càmera en bucle
function exemple1(hobj,eventdata)
global camera btnXflag

    % Desactivar menus
    set(findobj('Tag','MENU_WORKING'),'enable','off');
    
    % Reset del flag del boto 'X'
    btnXflag = 0;
    
    % Posem text al titol
    titol = get(get(findobj('Tag','GUI_IMATGE'),'Parent'),'Title');
    set(titol,'String','EX1: Camera live...');
        
    % Mentre no es premi el boto 'X'
    while (btnXflag == 0)
        
       % Obté imatge
       im = camera.getframe();

       % Pinta en pantalla
       set(findobj('Tag','GUI_IMATGE'),'CData',im);

       % Força refresc de la figura
       refresh;
       drawnow;
    end
    
    % Activar menus
    set(findobj('Tag','MENU_WORKING'),'enable','on');
    
    set(titol,'String','EX1: FI');
end

% Exemple 2: Portar el braç a un extrem de l'eix X (bloquejant)
% (les posicions es poden verificar amb el control manual)
function exemple2(hobj,eventdata)
global robot

    % Desactivar menus
    set(findobj('Tag','MENU_WORKING'),'enable','off');
    
    % Posem text al titol
    titol = get(get(findobj('Tag','GUI_IMATGE'),'Parent'),'Title');
    set(titol,'String','EX2: INICI');

    % Anar a la posició inicial
    set(titol,'String','EX2: Anant posició inicial...');
    [ok,miss] = robot.senddatawait('M 0 0 0 170 0');
    
    set(titol,'String','EX2: Fent moviments...');  
    % Hi ha dues opcions, cada eix bloquejant o tots els eixos a la vegada.
    % Opcio 1: Pas a Pas
    [ok,miss] = robot.senddatawait('MP 45');  % Obrir la pinça  
    [ok,miss] = robot.senddatawait('MZ 100'); % pujar l'eix Z
    [ok,miss] = robot.senddatawait('MX 270'); % anar a la posició final d'eix X
    
    % Opcio 2: a la vegada
    %[ok,miss] = robot.senddatawait('M 270 - 100 - 45');
    
    set(titol,'String','EX2: FI');

    % Activar menus
    set(findobj('Tag','MENU_WORKING'),'enable','on');
end

% Exemple 3: Analitzar imatge mentre es mou
function exemple3(hobj,eventdata)
global robot camera btnXflag

    % Desactivar menus
    set(findobj('Tag','MENU_WORKING'),'enable','off');

    % Reset del flag del boto 'X'
    btnXflag = 0;

    % Posem text al titol
    titol = get(get(findobj('Tag','GUI_IMATGE'),'Parent'),'Title');
    set(titol,'String','EX3: INICI');

    set(titol,'String','EX3: Pas 1. Anant posició inicial...');
    [ok,miss] = robot.senddatawait('MZ 100'); % Pujar Z (bloquejant)
    [ok,miss] = robot.senddatawait('M 0 0 100 170 45'); % Resta de eixos (a la vegada)

    set(titol,'String','EX3: Pas 2. Moure X=270mm mentre s''obtenen imatges...');
    [ok,miss] = robot.senddata('MX 270'); % Moure eix X fins a 270 mm (sense bloquejar)

    % Bucle per analitzar la imatge
    % mentre esta en moviment i no es premi el boto 'X'
    isBusy = 1;
    while (isBusy && ~btnXflag)

        % Obté imatge
        im = camera.getframe();

        % Mostrar imatge
        set(findobj('Tag','GUI_IMATGE'),'CData',im);

        % Consultar si s'esta movent
        isBusy = robot.inmotion();

        refresh;
        drawnow;
    end

    % Si l'usuari ha premut la 'X' parem l'execució
    if(btnXflag == 1)
        [ok,miss] = robot.senddata('S');
        set(titol,'String','EX3: Interromput per l''usuari');
        return;
    end

    set(titol,'String','EX3: Pas 3. Fen moviment vertical (eix Y=50mm)...');
    [ok,miss] = robot.senddatawait('MY 50');

    set(titol,'String','EX3: Pas 4. Tornant (X=0mm) mentre s''obtenen imatges...');
    [ok,miss] = robot.senddata('MX 0');

    % Bucle per analitzar la imatge
    % mentre esta en moviment
    isBusy = 1;
    while (isBusy && ~btnXflag)

        % Obté imatge
        im = camera.getframe();

        % Mostrar imatge
        set(findobj('Tag','GUI_IMATGE'),'CData',im);

        % Consultar si s'esta movent
        isBusy = robot.inmotion();

        refresh;
        drawnow;
    end

    % Si l'usuari ha premut la 'X' parem l'execució
    if(btnXflag == 1)
        [ok,miss] = robot.senddata('S');
        set(titol,'String','EX3: Interromput per l''usuari');
        return;
    end

    set(titol,'String','EX3: FI');

    % Activar menus
    set(findobj('Tag','MENU_WORKING'),'enable','on');
end

% Exemple 4: Moure robot, detectar objecte, 
% agafar-lo i portar-lo a la posició d'enmagatzematge.
function exemple4(hobj,eventdata)
global robot camera btnXflag

    % Desactivar controls del menu
    set(findobj('Tag','MENU_WORKING'),'enable','off');

    % Reset del flag del boto 'X'
    btnXflag = 0;

    % Posem text al titol
    titol = get(get(findobj('Tag','GUI_IMATGE'),'Parent'),'Title');
    set(titol,'String','EX4: START');
    
    % Obtenir tamany imatges
    im = camera.getframe();
    [n_row,n_col,n_dim] = size(im);
    
    % Calcular columna central
    % tancament pinça (OJO, AJUSTAR!!)
    col_pinca = n_col/2 + 63; % La càmera està una mica descentrada

    % borrar totes les linies anteriors
    delete(findobj('Tag','EX4_PLOTS'));
    
    % Plotejar noves linies per mostrar la detecció
    hold on;
    % Marcar la columna central amb linia vermella en la imatge de la camera.
    plot([1 n_row],(n_row/2)*[1 1],'r','Tag','EX4_PLOTS');
    % marcar el inici i final d'objecte segmentat
    h_linia = plot([1 n_col],(n_row/2)*[1 1],'mo','Tag','EX4_PLOTS');
    % marcar el centre de detecció
    h_centre = plot(1, n_row/2,'y+','Tag','EX4_PLOTS');
    % linia per la orientació
    h_orientacio = plot([0 0], [0 0],'g--','Tag','EX4_PLOTS');
    hold off;

    % Crear una Figura addicional per veure el profile de la fila central
    figure('Name',['Profile of row: ' num2str(n_row/2)]);
    h_R = plot(1:1:n_col,zeros(1,n_col),'r');
    hold on;
    h_G = plot(1:1:n_col,zeros(1,n_col),'g');
    h_B = plot(1:1:n_col,zeros(1,n_col),'b');    
    hold off;
    xlabel('Column');
    ylabel('Color intensity');
    
    % PAS 1. Posició Inicial
    set(titol,'String','EX4: GOING to initial position...');
    % primer pujar Z
    [ok,miss] = robot.senddata('P 100000 100000 100000 100000 100000'); %#ok<*SETNU> 
    [ok,miss] = robot.senddatawait('MZ 100');
    % resta de moviments
    [ok,miss] = robot.senddatawait('M 0 0 100 170 45');

    
    % PAS 2. Enviar a X=150 o X=0 (Exploració en horitzontal)
    posicio(1).ordre = 'MX 150';    % 'MX 270' per anar al final de l'eix
    posicio(2).ordre = 'MX 0';

    % index d'exploració
    index_exploracio = 1;

    % Acabar al detectar un objecte
    objecte_detectat = 0;
    while (~objecte_detectat && ~btnXflag)

        % Enviar d'un extrem a l'altre
        [ok,miss] = robot.senddata(posicio(index_exploracio).ordre);
        % actualitzar index
        if (index_exploracio == 1)
            index_exploracio = 2;        
            set(titol,'String','EX4: Exploration Right...');
        else
            index_exploracio = 1;        
            set(titol,'String','EX4: Exploration Left...');
        end 

        % Bucle per tractar la imatge mentre es mou
        while (robot.inmotion() && ~objecte_detectat && ~btnXflag)
            % Obtenir imatge i mostrarla
            im = camera.getframe();
            set(findobj('Tag','GUI_IMATGE'),'CData',im);

            % Obtenir els nivells RGB de la fila central de la imatge
            % 3 vectors:
            r = im(n_row/2,:,1);
            g = im(n_row/2,:,2);
            b = im(n_row/2,:,3);

            % Mostrar els nivells de la fila central al figure addicional
            set(h_R,'yData',r);
            set(h_G,'yData',g);
            set(h_B,'yData',b);

            % Detectar columna inici i final d'objecte sobre aquesta linea
            centre_objecte = find(g < 50 | r <50 | b < 50); % OJO!! ajustar nivell en funció il·luminació
            if ~isempty(centre_objecte)
                % Si s'ha detectat alguna cosa
                col_ini    = centre_objecte(1);
                col_fi     = centre_objecte(end);
                col_centre = mean(centre_objecte);

                % Mostrar deteccio a la imatge
                set(h_linia,'xData',[col_ini col_fi]);
                set(h_centre, 'xData',col_centre);

                % Aturar si el centre de l'objecte s'apropa al centre de la imatge
                if (abs(col_centre - col_pinca) < 10)
                    set(titol,'String','EX4: OBJECT FOUND!'); 
                    
                    % STOP eix
                    [ok,miss] = robot.senddatawait('SX');

                    % l'agafem i el portem a una posicio de guardar (10,60)
                    processarObjecte();

                    objecte_detectat = 1; % Per sortir dels bucles
                end
            end

           refresh;
           drawnow;
        end
    end

    % Si l'usuari ha premut la 'X' parem l'execució
    if(btnXflag == 1)
        [ok,miss] = robot.senddata('S');
        set(titol,'String','EX4: Stopped by user');
        
        % Borrar objectes plots
        delete(findobj('Tag','EX4_PLOTS'));                
        return;
    end    
        
    % borrar els objectes de la imatge
    delete(findobj('Tag','EX4_PLOTS'));
    
    set(titol,'String','EX4: FINISHED');

    % Activar menus
    set(findobj('Tag','MENU_WORKING'),'enable','on');
    
    % Funció anidada (nested function)
    % Si s'ha detectat un objecte l'agafem i el portem
    % a una posicio de guardar (10,60)
    function processarObjecte()
        % Stop eix X
        [ok,miss] = robot.senddatawait('SX');
        
        % Descomentar per acceptar objectes inclinats
        % Corregeix orientació pinça
        corregirOrientacio();
        
        set(titol,'String','EX4: Picking it...');
        [ok,miss] = robot.senddatawait('MZ 5');   % Baixar eix Z
        [ok,miss] = robot.senddatawait('MP 0');   % Tancar pinça
        [ok,miss] = robot.senddatawait('MZ 80'); % Elevar eix Z
                
        set(titol,'String','GOING to storage position (10,60)...');
        [ok,miss] = robot.senddatawait('M 10 60 - 170 -'); % Anar a posició de guardar
        
        set(titol,'String','Release the object...');        
        [ok,miss] = robot.senddatawait('MZ 10');  % Baixar Z
        [ok,miss] = robot.senddatawait('MP 45');  % Obrir pinça        
        [ok,miss] = robot.senddatawait('MZ 100'); % Elevar eix Z
    end

    % Funció anidada (nested function)
    % Corregeix l'orientació de un stick detectat
    function corregirOrientacio()
        set(titol,'String','EX4: Adjusting orientation...');

        % Obtenir imatge
        im = camera.getframe();
        set(findobj('Tag','GUI_IMATGE'),'CData',im);
            
        % Segmentar tota la imatge
        % pixels que tinguin poc R o poc B o poc G
        imseg = (im(:,:,1) < 50 | im(:,:,2) < 50 | im(:,:,3) < 50);

        % Mostrar segmentació
        im(:,:,1) = 255.*imseg;
        im(:,:,2) = 255.*imseg;
        im(:,:,3) = 255.*imseg;
        set(findobj('Tag','GUI_IMATGE'),'CData',im);

        % Etiquetar objectes
        [L,num] = bwlabel(imseg,4);

        % Obtenir mesures de orientacio
        STATS   = regionprops(L,'All');

        % Buscar el mes gran (en teoria la peça)
        i_max = [];
        a_max = 0;
        for i=1:1:num
            if (STATS(i).Area > a_max)
                a_max = STATS(i).Area;
                i_max = i;
            end
        end

        % Obtenir angle
        angul = STATS(i_max).Orientation;
        
        % Mostrar el resultat a la imatge
        x_cen = STATS(i_max).Centroid(1);
        y_cen = STATS(i_max).Centroid(2);
        altura = STATS(i_max).BoundingBox(4);
        xi = x_cen - 0.5 * altura * cosd(angul);
        yi = y_cen + 0.5 * altura * sind(angul);
        xf = x_cen + 0.5 * altura * cosd(angul);
        yf = y_cen - 0.5 * altura * sind(angul);        
        set(h_orientacio,'xData',[xi xf],'yData',[yi yf]);

        % rotar la pinça
        if (angul<0), angul = angul + 180; end
        [ok,miss] = robot.senddatawait(['MR ' num2str(round(170 + angul - 90))]);
    end    
end

% Exemple 5: Sistema de control de llaç tancat 
% per centrar la pinça al objecte.
function exemple5(hobj,eventdata)
global robot camera btnXflag

    % Desactivar menus
    set(findobj('Tag','MENU_WORKING'),'enable','off');

    % Reset del flag del boto 'X'
    btnXflag = 0;
    
    % Posem text al titol
    titol = get(get(findobj('Tag','GUI_IMATGE'),'Parent'),'Title');
    set(titol,'String','EX5: INICI');
    
    % borrar totes les linies anteriors
    delete(findobj('Tag','EX5_PLOTS'));
    
    % Obtenir dimensions imatge
    im = camera.getframe();
    [n_row,n_col,n_dim] = size(im);
    
    % Posicio de referencia
    xref = n_col/2 + 63; % La càmera esta descentrada
    yref = n_row/2;
    
    % Constant proporcional
    Kp = 5000;
    
    % Obtenir pos maximes
    [ok,miss] = robot.senddata('CM');
    xmax = miss(1);
    ymax = miss(2);
        
    % Plotejar noves linies per mostrar la detecció
    hold on;
    % Plotejar punt de referencia.
    plot(xref,yref,'g+','Tag','EX5_PLOTS');
    % Centre de detecció
    h_centre = plot(0,0,'m+','Tag','EX5_PLOTS');    
    % Boundary Box de detecció
    h_boundary = plot(0,0,'y--','Tag','EX5_PLOTS');
    hold off;

    set(titol,'String','EX5: Anant posició inicial...');
    [ok,miss] = robot.senddatawait('M - - 130 170 45'); 

    
    % Bucle per fer el control
    % mentre no es premi el boto 'X'
    while (~btnXflag)

        % Obté imatge i la mostra
        im = camera.getframe();
        set(findobj('Tag','GUI_IMATGE'),'CData',im);
        
        % Obtenir la posició objecte        
        [xAct, yAct] = calculaPosObjecte();
        
        % Comprovem si no hi ha detecció
        if (xAct == -1)
            set(titol,'String','EX5: Objecte no present');
            
            % Parem tots els motors
            [ok,miss] = robot.senddata('S');
        else
            xerror = xref-xAct;
            yerror = yref-yAct;

            set(titol,'String',['EX5:  errorX= ' num2str(xerror) ' errorY= ' num2str(yerror)]);
            
            % Control del eix X
            if(abs(xerror) < 2)
                [ok,miss] = robot.senddata('SX');
            else
                % PWM (factor proporcional)
                xpwm = abs(xerror)*Kp;
                
                % Saturador
                if(xpwm > 100000), xpwm = 100000; end
                if(xpwm < 50000), xpwm = 50000; end % voltatge mínim motor
                
                % Apliquem el nou PWM
                [ok,miss] = robot.senddata(['PX ' num2str(xpwm)]);
                
                % Direcció
                if(xerror >0)
                    [ok,miss] = robot.senddata(['MX ' num2str(xmax)]);
                else
                    [ok,miss] = robot.senddata('MX 0');
                end
            end            
                        
            % Control del eix Y
            if(abs(yerror) < 2)
                [ok,miss] = robot.senddata('SY');
            else
                 % PWM (factor proporcional)
                ypwm = abs(yerror)*Kp;
                
                % Saturador
                if(ypwm > 100000), ypwm = 100000; end
                if(ypwm < 50000), ypwm = 50000; end % voltatge mínim motor
                
                % Apliquem el nou PWM
                [ok,miss] = robot.senddata(['PY ' num2str(ypwm)]);
                
                % Direcció
                if(yerror >0)
                    [ok,miss] = robot.senddata(['MY ' num2str(ymax)]);
                else
                    [ok,miss] = robot.senddata('MY 0');
                end
            end
        end
        
        refresh;
        drawnow;
    end

    set(titol,'String','EX5: FI');
        
    % Parem tots els motors
    [ok,miss] = robot.senddata('S');
    
    % borrar totes les linies
    delete(findobj('Tag','EX5_PLOTS'));
        
    % Activar menus
    set(findobj('Tag','MENU_WORKING'),'enable','on'); 
    
    function [x,y] = calculaPosObjecte()
        % Segmentar la imatge        
        r = im(:,:,1);
        g = im(:,:,2);
        b = im(:,:,3);
        
        % Per objecte vermell
        %imseg = uint8(r > g*1.8 & r > b*1.8 & abs(b-g) < 15);
        % Per objecte negre
        imseg = uint8(r < 30 & g < 30 & b < 30);
        
        % delete small objects
        imseg = bwareaopen(imseg, 200, 4);

        % Etiquetar objectes
        [L,num] = bwlabel(imseg,4);
        
        % Obtenir mesures de orientacio
        STATS = regionprops(L,'Area','BoundingBox','Centroid');

        % Buscar el mes gran (en teoria la peça)
        i_max = [];
        a_max = 0;
        for i=1:1:num
            if (STATS(i).Area > a_max)
                a_max = STATS(i).Area;
                i_max = i;
            end
        end
    
        % Si no hi han objectes
        if (isempty(i_max))
            x = -1;
            y = -1;
            set(h_centre,'xData',0,'yData',0);
            set(h_boundary,'xData',0,'yData',0);            
            return;
        end
        
        % Ens quedem amb els pixels que formen el objecte més gran
        imseg = (L == i_max);
        
        % Mostrar segmentació
        im(:,:,1) = 255.*imseg;
        im(:,:,2) = 255.*imseg;
        im(:,:,3) = 255.*imseg;
        set(findobj('Tag','GUI_IMATGE'),'CData',im);

        c_centroid = STATS(1).Centroid(1);
        r_centroid = STATS(1).Centroid(2);
        c_min = STATS(1).BoundingBox(1);
        r_min = STATS(1).BoundingBox(2);
        c_max = STATS(1).BoundingBox(1) + STATS(1).BoundingBox(3);
        r_max = STATS(1).BoundingBox(2) + STATS(1).BoundingBox(4);
        set(h_centre,'xData',c_centroid,'yData',r_centroid);
        set(h_boundary,'xData',[c_min c_min c_max c_max c_min],'yData',[r_min r_max r_max r_min r_min]);
        
        % Retorna valors
        x = round(c_centroid);
        y = round(r_centroid);
        
    end
end

% Exemple 6: Exemple de sequencia de moviments 
% implementat amb una estructura de dades
function exemple6(hobj,eventdata)
global robot camera btnXflag %#ok<*NUSED> 

    % Desactivar menus
    set(findobj('Tag','MENU_WORKING'),'enable','off');

    % Reset del flag del boto 'X'
    btnXflag = 0;
    
    % Posem text al titol
    titol = get(get(findobj('Tag','GUI_IMATGE'),'Parent'),'Title');
    set(titol,'String','EX6: INICI');
    
    % Sequencia de moviments entrada
    entrada(1).moviment(1).ordre = 'MZ 50';         % elevar Z del terra
    entrada(1).moviment(2).ordre = 'M 0 0 - 170 -'; % Posició de entrada de peçes
    entrada(1).moviment(3).ordre = 'MP 45';         % obrir pinça
    entrada(1).moviment(4).ordre = 'MZ 5';          % baixar eix Z a 5mm del terra
    entrada(1).moviment(5).ordre = 'MP 0';          % tancar pinça
    entrada(1).moviment(6).ordre = 'MZ 50';         % elevar eix Z a 50 mm del terra
    
    % Sequencia de moviments sortida
    % peça 1
    sortida(1).moviment(1).ordre = 'M 120 50 - 80 -';% Posició X,Y per guardar peça 1
    sortida(1).moviment(2).ordre = 'MZ 8';            % baixar Z a 8 mm del terra
    sortida(1).moviment(3).ordre = 'MP 45';           % obrir pinça
    sortida(1).moviment(4).ordre = 'MZ 50';           % elevar eix Z a 50 mm del terra    
    % peça 2
    sortida(2).moviment(1).ordre = 'M 120 125 - 80 -';% Posició X,Y per guardar peça 2
    sortida(2).moviment(2).ordre = 'MZ 8';            % baixar Z a 8 mm del terra
    sortida(2).moviment(3).ordre = 'MP 45';           % obrir pinça
    sortida(2).moviment(4).ordre = 'MZ 50';           % elevar eix Z a 50 mm del terra
    % peça 3
    sortida(3).moviment(1).ordre = 'M 120 200 - 80 -';% Posició X,Y per guardar peça 3
    sortida(3).moviment(2).ordre = 'MZ 8';            % baixar Z a 8 mm del terra
    sortida(3).moviment(3).ordre = 'MP 45';           % obrir pinça
    sortida(3).moviment(4).ordre = 'MZ 120';          % elevar eix Z a 120 mm del terra

    % Velocitats de tots els eixos al màxim
    [ok,miss] = robot.senddata('P 100000 100000 100000 100000 100000');
    
    % Bucle per fer el control
    % mentre no es premi el boto 'X'
    n_objecte = 1;
    while (n_objecte <= 3 &&  ~btnXflag)      
        % sequencia per la entrada        
        for ii=1:1:6
            % enviar ordres de forma sequencial              
            set(titol,'String',['EX6: Seqüència entrada (' num2str(ii) '/6)...']);
            [ok,miss] = robot.senddatawait(entrada(1).moviment(ii).ordre);

            % Si el usuari prem 'X' sortim
            if(btnXflag == 1), break; end            
        end
        
        % sequencia per la sortida        
        for ii=1:1:4
            set(titol,'String',['EX6: Seqüència sortida peça ' num2str(n_objecte) ' (' num2str(ii) '/4)...']);            
            % enviar ordres de forma sequencial
            [ok,miss] = robot.senddatawait(sortida(n_objecte).moviment(ii).ordre);
            
            % Si el usuari prem 'X' sortim
            if(btnXflag == 1), break; end
        end
 
        % incrementar objecte
        n_objecte = n_objecte + 1;
    end

    
    % Si l'usuari ha premut la 'X' parem l'execució
    if(btnXflag == 1)
        [ok,miss] = robot.senddata('S');
        set(titol,'String','EX6: Interromput per l''usuari');
        return;
    end
    
    set(titol,'String','EX6: FI');
           
    % Activar menus
    set(findobj('Tag','MENU_WORKING'),'enable','on');
    
end




%///////////////////  C O D I - E S T U D I A N T S   /////////////////////
%//////////////////////////////////////////////////////////////////////////
function codi1(hco,eventStruct)
global robot camera btnXflag

    %Desactiva controls del menu
    set(findobj('Tag','MENU_WORKING'),'enable','off');
    
    
    % codi......................


    % Activar controls del menu, surt del bucle.
    set(findobj('Tag','MENU_WORKING'),'enable','on');
end

function codi2(hco,eventStruct)
global robot camera btnXflag

    %Desactiva controls del menu
    set(findobj('Tag','MENU_WORKING'),'enable','off');

    % codi......................


    % Activar controls del menu, surt del bucle.
    set(findobj('Tag','MENU_WORKING'),'enable','on');
end
