function c = robotcam
% OJO, recordar que s'ha de cridar amb () al final
% exemple: c.opencam()
%
% OJO, Aquesta API només funciona amb el "Webcam support Package"
%
    c.opencam    = @opencam;
    c.getframe   = @getframe;
    c.closecam   = @closecam;
    c.status     = @status;
end

%//////////////////////////////////////////////////////////////////////////
function [ok,miss] = opencam()
global camCART %#ok<*GVMIS> 

    % Activar amb Webcam support Package (funció "webcam")
    % http://es.mathworks.com/hardware-support/matlab-webcam.html
    
    % Comprovar estat anterior
    if(~isempty(camCART))
        if (isvalid(camCART) && isa(camCART,'webcam'))
            ok = 1;
            miss = 'WARNING: device already connected';
            return;
        else 
            delete(camCART);
            camCART = [];
        end
    end
    

    % Obtenir el objecte webcam
    try
        % Cercar el dispositiu de camera del robot cartesià    
        camList = webcamlist;
        cameraID = [];
        name = 'USB Camera';
        for i = 1:length(camList)
            if (strcmp(char(camList(i)), name))
                cameraID = i;
                break;
            end
        end

        % Connectar camera
        if(~isempty(cameraID))
            camCART = webcam(cameraID);
            ok = 1;
            miss = ['OK: Camera Connected: ' camCART.Resolution];
        else
            ok = 0;
            miss = 'ERROR: USB camera not found';
        end
            
    catch exception
        ok = 0;
        miss = ['FATAL ERROR: ' exception.message];
    end

end

%//////////////////////////////////////////////////////////////////////////
function im = getframe()
global camCART
    % package matlab
    try
        im = snapshot(camCART);
    catch 
        im = [];
    end
end

%//////////////////////////////////////////////////////////////////////////
function [ok,miss] = closecam()
global camCART
    % Comprovar estat anterior
    if(~isempty(camCART))
        if (isvalid(camCART) && isa(camCART,'webcam'))
            delete(camCART);
            camCART = [];  
            ok = 1;
            miss = 'OK: Camera disconnected';            
        else 
            delete(camCART);
            camCART = [];
            ok = 1;
            miss = 'OK: Camera object repaired';
        end
    else
        ok = 1;
        miss = 'OK: Camera already disconnected';
    end
end

%//////////////////////////////////////////////////////////////////////////
function [ok,miss] = status()
global camCART
    % Comprovar estat anterior
    if(~isempty(camCART))
        if (isvalid(camCART) && isa(camCART,'webcam'))
            ok = 1;
            miss = camCART.Resolution;
        else 
            ok = 0;
            miss = 'Camera object not valid';
        end
    else
        ok = 0;
        miss = 'Camera not connected';
    end
end


