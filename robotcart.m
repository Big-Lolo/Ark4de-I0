function r = robotcart
% OJO, recordar que s'ha de cridar amb () al final
% exemple: b = r.inmotion()
    r.openauto     = @openauto;
    r.openport     = @openport;
    r.closeport    = @closeport;
    r.status       = @status;    
    r.senddata     = @senddata;
    r.getdata      = @getdata;
    r.inmotion     = @inmotion;
    r.senddatawait = @senddatawait;    
end

%/////////////////////////////////////////////////////////////////////////
function [ok,miss] = openport(p)
global conCART %#ok<*GVMIS> 

    % li podem indicar a quin port es ens volem connectar, si no ho fem busca
    % els disponibles, i si n'hi ha mes d'un ens pregunta a quin d'ells ens volem
    % connectar. Per indicar el port es pot fer de qualsevol manera, ex:
    %  openport(2)
    %  openport('COM2')
    %  openport('COM 2')

    if(~isempty(conCART))
        if (isvalid(conCART) && isa(conCART,'serial'))
            if(strcmp(conCART.Status,'open'))
                ok = 1;
                miss = 'WARNING: device already connected';
                return;
            else
                fclose(conCART);
                delete(conCART);
                conCART = [];
            end
        else 
            delete(conCART);
            conCART = [];
        end
    end
    

    if (nargin == 1)
        if isnumeric(p)
            port = p;
        else
            % recuperar el número de port
            ind = regexp(p,'\d');
            port = str2double(p(ind));
        end
    else
        ok = 0;
        miss = 'WARNING: no port';
        return;
    end
    
    com_txt = ['COM' num2str(port)];

    % definir el port
    conCART = serial(com_txt); %#ok<SERIAL> 
    set(conCART,'BaudRate',115200);
    set(conCART,'Timeout',0.5);
    set(conCART,'InputBufferSize',80000);
    set(conCART,'FlowControl','none');
    set(conCART,'Parity','none');
    set(conCART,'StopBits',1);
    set(conCART,'DataBits',8);
    set(conCART,'terminator',char(13));  % /r
    % intentar obrir
    warning off;    
    try
        fopen(conCART);
        
        % fer una primera comunicació i esperar resposta
        [ok,miss] = senddata('CS');

        % Comprovem si tenim resposta correcta
        if (ok == 0 || length(miss) ~= 9)
            % error al obrir -> tancar port
            fclose(conCART);
            delete(conCART);    
            conCART = [];
            miss = ['Error connecting to serial ' com_txt '. -- ' miss ' --'];
        else
            miss = ['Connected to: ' com_txt];
        end
    
    catch exception
        % error
        ok = 0;
        delete(conCART);    
        conCART = [];           
        miss = ['Error connecting to serial ' com_txt '. -- ' exception.message ' --'];     
    end
    warning on;
end

%//////////////////////////////////////////////////////////////////////////
function [ok,miss] = closeport()
global conCART;

    if(~isempty(conCART))
        if (isvalid(conCART) && isa(conCART,'serial'))
            if(strcmp(conCART.Status,'open'))
                fclose(conCART);
                delete(conCART);
                conCART = [];
                ok = 1;
                miss = 'OK: Port closed';
            else
                delete(conCART);
                conCART = [];
                ok = 1;
                miss = 'OK: Port already closed';
            end
        else 
            delete(conCART);
            conCART = [];            
            ok = 1;
            miss = 'OK: Port not valid but fixed';
        end
    else
        ok = 1;
        miss = 'Serial object not detected';      
    end
end

%//////////////////////////////////////////////////////////////////////////
function [ok,miss] = status()
global conCART;

    if(~isempty(conCART))
        if (isvalid(conCART) && isa(conCART,'serial'))
            if(strcmp(conCART.Status,'open'))                
                ok = 1;
                miss = conCART.Port;
            else
                ok = 0;
                miss = 'Port closed';
            end
        else 
            ok = 0;
            miss = 'Serial object not valid';
        end
    else
        ok = 0;
        miss = 'Serial object not created';
    end
end

%//////////////////////////////////////////////////////////////////////////
function [ok,miss] = openauto()
global conCART

    % Comprovar estat actual del serial
    if(~isempty(conCART))
        if (isvalid(conCART) && isa(conCART,'serial'))
            if(strcmp(conCART.Status,'open'))
                ok = 1;
                miss = 'WARNING: device already connected';
                return;
            else
                fclose(conCART);
                delete(conCART);
                conCART = [];
            end
        else 
            delete(conCART);
            conCART = [];
        end
    end
    
%     % verificar si hi ha altres connexions
%     i_open = instrfind;
%     if (~isempty(i_open))
%         close(i_open);
%         delete(i_open);
%     end

    warning off;    
        
    list = serialportlist;
    h_wait = waitbar(0,'Searching COM RS-232'); 
    set(h_wait,'CloseRequestFcn',@close_auto);
    
    xBtnStatus = 0;
    for i=length(list):-1:1
        port = list(i).char();

        h_wait.CurrentAxes.Title.String = ['Searching COM RS-232. ' port '...'];
        drawnow;
        
        % explorar sequencialment
        [ok,miss] = openport(port);
        
        if (ok)
            % port connectat
            break;
        end

        if (xBtnStatus == 1) 
            break;
        end
        waitbar((length(list)-i)/length(list),h_wait);
    end

    delete(h_wait);
    warning on;
    
    if (ok == 0)
        miss = 'Robot Cartesià NOT FOUND!';
    end

    function close_auto(~,~)
        xBtnStatus = 1;
    end
end

%////////////////////////////////////////////////////////////////////////
function [ok,miss] = senddata(cadena)
global conCART;    
    try
        % send robot order
        fprintf(conCART,cadena);
        % get immediate answer
        [ok,miss]=getdata();
        if find(strcmp(cadena(1:2),{'CM','CE','CP'}))
            % decode as a number
            miss=str2num(miss);  %#ok<ST2NM>
        end
    catch exception
        ok = 0;
        miss = ['ERROR: Problem on data send: --' exception.message '--'];
        return;
    end
end

%////////////////////////////////////////////////////////////////////////
function [ok,miss] = getdata()
global conCART;
    timeout_steps = 200;
    miss = [];
    try        
        % timeout waiting response data
        it=0;
        while (~conCART.BytesAvailable) && (it < timeout_steps)
            it = it + 1;
        end
        
        while conCART.BytesAvailable
            datatmp = fgetl(conCART);
            miss = [miss datatmp]; %#ok<AGROW>
        end
        
        if (isempty(miss))
            ok = 0;
            if(it == timeout_steps)
                miss = 'ERROR: timeout waiting response.';
            else
                miss = 'ERROR: no data received.';
            end
        else
            ok = 1;
        end
    catch exception
        ok = 0;
        miss = ['ERROR: Communication HW error. --' exception.message '--'];
    end
end

%////////////////////////////////////////////////////////////////////////
% Use only with the next commands: ZM,CA,M,RM,SM 
function [ok,miss] = senddatawait(cadena)
    [ok,miss] = senddata(cadena);
    if ~ok
        return;
    end
    com = cadena(1:2);
    switch com
        case 'ZM'
            c = 'Z';
        case 'CA'
            c = 'C';
        case 'M '
            c = 'M';
        case 'MX'
            c = 'M';
        case 'MY'
            c = 'M';
        case 'MZ'
            c = 'M';
        case 'MR'
            c = 'M';
        case 'MP'
            c = 'M';
        case 'RM'
            c = 'M';
        case 'SM'
            c = 'M';
        otherwise
            miss='NV';
            ok=0;
            return;
    end
    
    [ok,miss1] = senddata('CS');
    tic;
    while numel(strfind(miss1,c)) && toc < 120
        pause(0.01);
        [ok, miss1] = senddata('CS');
        
        % If error in feedback reception, continue
        if(ok == 0)
            miss1=c; 
        elseif(numel(miss1) ~= 9) % Si es diferent a 9 elements
            miss1=c;
        elseif(~isempty(str2num(miss1))) %#ok<ST2NM> % Si te numeros
            miss1=c;
        elseif(miss1(2) ~= ' ' || miss1(4) ~= ' ' || miss1(6) ~= ' ' || miss1(8) ~= ' ') % si no te els espais on toca
            miss1=c;
        end
    end
end

%////////////////////////////////////////////////////////////////////////
function ok = inmotion()
    % per defecte suposem que hi ha moviment
    ok = 1;
   
    try
       [ok2,miss] = senddata('CS');
       
       % Si s'ha rebut correctament...
       if ok2
           
            % Detectar possibles fallos de solapament de transmissions
            if(numel(miss) ~= 9) % Si es diferent a 9 elements
                % com a mesura de seguretat es respon que està en moviment
                ok = 1;
            elseif(~isempty(str2num(miss))) %#ok<ST2NM> % Si te numeros
                % com a mesura de seguretat es respon que està en moviment
                ok = 1;                
            elseif(miss(2) ~= ' ' || miss(4) ~= ' ' || miss(6) ~= ' ' || miss(8) ~= ' ') % si no te els espais on toca
                % com a mesura de seguretat es respon que està en moviment
                ok = 1;
            % averiguar el número de motors en moviment           
            elseif (numel(strfind(miss,'M')) == 0)
               % no n'hi ha cap en moviment
               ok = 0;
           end
       else
         % com a mesura de seguretat es respon que està en moviment
         ok = 1; 
       end
   
    catch
         % com a mesura de seguretat es respon que està en moviment
         ok = 1; 
    end
    
end