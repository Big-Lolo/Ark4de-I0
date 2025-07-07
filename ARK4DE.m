%% ARK4DE
%This class would control all arcade system. (open the ui, get keys (using
%js), send info to robot and count points analizing camera images.

classdef ARK4DE < handle
    
    properties
        status; %paused, run, waiting....
        robot; %robot obj to connect with it
        robotPos; %robot position
        camera; %Camera obj to connect with it
        ui; %ui object
        points; %Rewards taken list
        session; %Actual session to save username, points...
        initialCoords; %Initial coords to start game
        depositCoords; %Coords of depositated object
        music; %Music player obj
        timers; %Timers obj
        connectToRobot; %True if robot is connected to avoid errors.
        actionItem; %Variable to save action pressed with controller.
        objectCoords; %Object to safe coords of delivery points.
        finish; %Status of game code.
    end

    methods (Access=public)
        function obj = ARK4DE()
            %Set true if robot is able. Set false to use ui without the
            %robot.
            obj.connectToRobot = true;
            
            %Initialization of other params.
            obj.points = cell(1,1);
            obj.actionItem = NaN;
            obj.depositCoords = '';
            obj.music.enable = false;
            obj.music.paused = false;
            obj.initialCoords = 'M 0 0 142 170 52';
            obj.robotPos.x = 0;
            obj.robotPos.y = 0;
            obj.robotPos.z = 144;
            obj.robotPos.rot = 170;
            obj.robotPos.pinz = 0;
            obj.robotPos.light = 0;
            obj.objectCoords = cell(1, 5);
            obj.fillObjectCoordsStruct()
            obj.finish = false;
            if obj.connectToRobot
                %This function would connect with robot before.
                obj.ensureRecreative();
            else
                obj.ensureArcade();
            end
        end
        
        %Function to full object objectCoords with coords and points of
        %delivery point
        function fillObjectCoordsStruct(obj)
            %For each delivery area, we register coords and base points
            obj.objectCoords{1}.coords = [247, 6, 116];
            obj.objectCoords{1}.points = 150;

            obj.objectCoords{2}.coords = [150, 4, 64];
            obj.objectCoords{2}.points = 100;

            obj.objectCoords{3}.coords = [187, 132, 116];
            obj.objectCoords{3}.points = 150;

            obj.objectCoords{4}.coords = [269, 192, 116];
            obj.objectCoords{4}.points = 150;

            obj.objectCoords{5}.coords = [121, 219, 64];
            obj.objectCoords{5}.points = 100;           
        end

        function ensureRecreative(obj)
             cr = obj.connectRotobt();

            % Check if connection with robot was succesful
            if ~cr.status()
                disp('Error connectant amb el robot cartesià')
                return;
            end
            
            
            % Create a new instance of camera on cc
            cc = obj.connectCamera();
            
            if ~cc.status()
                disp('Error connectant amb la càmera')
                
                % close connection
                cr.closeport();
                return;
            end

            obj.robot = cr;
            obj.camera = cc;

            %Now all is ok and we can tun on the arcade
            obj.ensureArcade();
        end
    end

    methods (Access=private)
    
        %This function is to enable ui for the game and place robot to
        %initial coords.
        function ensureArcade(obj)
            %create uifig
            obj.ui.fig = uifigure("Name","ARK4DE I0");
            obj.ui.fig.Position = [00 00 800 800];
            
            %create uihtml
            obj.ui.html = uihtml(obj.ui.fig);
            obj.ui.html.Position = [0 0 obj.ui.fig.Position(3) obj.ui.fig.Position(4)];
            
            %link html with uihtml
            obj.ui.html.HTMLSource = fullfile(pwd, 'assets/arcadeScreen.html');
            obj.ui.html.HTMLEventReceivedFcn = @obj.handleHTMLResponse;
            obj.ui.fig.DeleteFcn = @obj.closeFigure;
            if obj.connectToRobot
                %set power to 100%
                obj.robot.senddata('P 100000 100000 100000 100000 100000');
                %go to initial point
                obj.robot.senddatawait(obj.initialCoords);
            end
        end

        %this function would handle responses of html. Is linked with
        %HTMLEventRecivedFcn prop of uihtml
        function handleHTMLResponse(obj, ~, evt)
            action = evt.HTMLEventName;
            data = evt.HTMLEventData;
            
            %for each case, something would be done and prepared
            switch action
                case "start"
                    %Called on press start button
                    obj.status = data;

                case "startTime"
                    %Called on start time counter js
                    obj.status = "playing";

                case "endTime"
                    %Called when time ends to end game
                    obj.status = "endGame";

                case "userName"
                    %Called to register name of user for the end score.
                    obj.session.userName = data;
                    obj.session.position = "#Na";
                    obj.session.newUser = true;
                    
                case "getScoreboard"
                    %Called to get top 6 players scoreboard
                    obj.getScoreboard('all')

                case "getScore"
                    %Called to get player score and show it in last screen
                    obj.getScoreboard('user')

                case "keyPressed"
                    %Here we only register button pressed(button would be
                    %sended by js)
                    obj.actionItem = data;

                case "soundOn"
                    obj.music.enable = true;
                    if ~isfield(obj.music, "player")
                        obj.playerMedia()
                    end

                case "soundOff"
                    %Disable music
                    obj.music.enable = false;
                otherwise
                    obj.status = "";
                    return;
            end
            
            %if game doesn't finish yet, gameCore still working.
            if obj.finish == false
                obj.gameCore()
            end
        end
        
        %This function would send actions to robot.
        function sendActionToRobot(obj, ~, ~)
            %We analize obj.actionItemList and we execute actions.
             amountOfActions = length(obj.actionItem);
             
             %Get actual robot positions
             [~, posMotor] = obj.robot.senddata('CE');
            
             if amountOfActions > 0
                key = obj.actionItem;
                switch key
                    case 87 %w
                        %Move robot Y 
                        actualY = posMotor(2);
                        if obj.robotPos.y > 0
                            obj.robotPos.y = actualY - 3;
                            actualY = obj.robotPos.y;
                        end      
                        commandLine = ['M - ',num2str(actualY),' - - -'];
                        obj.robot.senddata(commandLine)
                   
                    case 65 %a
                        %Move robot Y down
                        actualX = posMotor(1);
                        if obj.robotPos.x > 0
                            obj.robotPos.x = actualX - 3;
                            actualX = obj.robotPos.x;
                        end      
                        commandLine = ['M ',num2str(actualX),' - - - -'];
                        obj.robot.senddata(commandLine)
                        
                    case 83 %s
                        %Move robot X right
                        actualY = posMotor(2);
                        if obj.robotPos.y < 234
                            obj.robotPos.y = actualY + 3;
                            actualY = obj.robotPos.y;
                        end      
                        commandLine = ['M - ',num2str(actualY),' - - -'];
                        obj.robot.senddata(commandLine)

                    case 68 %d
                        %Move robot X left
                        actualX = posMotor(1);
                        if obj.robotPos.x < 281
                            obj.robotPos.x = actualX + 3;
                            actualX = obj.robotPos.x;
                        end      
                        commandLine = ['M ',num2str(actualX),' - - - -'];
                        obj.robot.senddata(commandLine)

                    case 38 %up arrop
                        %raise crane
                        actualZ = posMotor(3);
                        if obj.robotPos.z < 143
                            obj.robotPos.z = actualZ + 3;
                            actualZ = obj.robotPos.z;
                        end      
                        commandLine = ['M - - ',num2str(actualZ),' - -'];
                        obj.robot.senddata(commandLine)

                    case 40 %down arrow
                        %lower crane
                        actualZ = posMotor(3);
                        if obj.robotPos.z > 0
                            obj.robotPos.z = actualZ - 3;
                            actualZ = obj.robotPos.z;
                        end      
                        commandLine = ['M - - ',num2str(actualZ),' - -'];
                        obj.robot.senddata(commandLine)

                    case 39 %right arrow
                        %Rotate crane right
                        actualRot = posMotor(4);
                        if obj.robotPos.rot > 0
                            obj.robotPos.rot = actualRot - 2;
                            actualRot = obj.robotPos.rot;
                        end      
                        commandLine = ['M - - - ',num2str(actualRot),' -'];
                        obj.robot.senddata(commandLine)

                    case 37 %left Arrow
                        %Rotate crane left
                        actualRot = posMotor(4);
                        if obj.robotPos.rot < 336
                            obj.robotPos.rot = actualRot + 2;
                            actualRot = obj.robotPos.rot;
                        end      
                        commandLine = ['M - - - ',num2str(actualRot),' -'];
                        obj.robot.senddata(commandLine)

                    case 76 %L
                        %Turn on/off light
                        lightStatus = obj.robotPos.light;
                        if lightStatus == 0
                            obj.robot.senddata('L 100000')
                            obj.robotPos.light = 1;
                        else
                            obj.robot.senddata('L 0')
                            obj.robotPos.light = 0;
                        end

                    case 77 %M
                        %Close crane
                        actualPinz = posMotor(5);
                        if obj.robotPos.pinz > 0
                            obj.robotPos.pinz = actualPinz - 2;
                            actualPinz = obj.robotPos.pinz;
                        end      
                        commandLine = ['M - - - - ',num2str(actualPinz)];
                        obj.robot.senddata(commandLine)

                    case 78 %N
                        %Open crane
                        actualPinz = posMotor(5);
                        if obj.robotPos.pinz < 52
                            obj.robotPos.pinz = actualPinz + 2;
                            actualPinz = obj.robotPos.pinz;
                        end      
                        commandLine = ['M - - - - ',num2str(actualPinz)];
                        obj.robot.senddata(commandLine)

                    otherwise

                end
                obj.actionItem = NaN;
            end
        end

        function gameCore(obj)
            %This function would control general aspects of game.
            statuss = obj.status;
            sessions = obj.session;
            if ~isempty(statuss)
                if statuss == "start"
                    if sessions.newUser == true
                        struct.name = sessions.userName;
                        struct.points = 0;
                        obj.session.scoreboard.user = struct;
                        obj.session.newUser = false;
                        if obj.connectToRobot
                            obj.robot.senddatawait(obj.initialCoords);
                        end
                    end 
                end

                if statuss == "playing"
                    %Create and start timer to refresh cam imgs
                    if ~isfield(obj.timers, "camera")
                        obj.timers.camera = timer("ExecutionMode","fixedRate", ...
                            "Period", 0.2, "BusyMode","drop", ...
                            "TimerFcn", @obj.cameraLayout, "Name","CamaraTimer");
                        start(obj.timers.camera);
                    end
                    %Create and start timer to send actions to robot.
                    if ~isfield(obj.timers, "controls")
                        obj.timers.controls = timer("ExecutionMode","fixedRate", ...
                            "Period", 0.1, "BusyMode","drop", ...
                            "TimerFcn", @obj.sendActionToRobot, "Name","ControlTimer");
                        start(obj.timers.controls);
                    end

                end
    
                if statuss == "endGame"
                    % Sometimes there are errors deleting the timers. 1 on
                    % 20 times
                    try
                        stop(obj.timers.camera)
                        stop(obj.timers.controls) 
                    catch
                    end

                    %Added pause to give time to the stop
                    pause(0.1);
                    delete(obj.timers.camera);
                    delete(obj.timers.controls);
                    delete(obj.ui.camera.imgPanel);
                    
                    %Set robot to deposit zone to count points.
                    if obj.connectToRobot
                        %obj.robot.senddatawait(obj.depositCoords);
                    end
                    
                    %Check if robot stops and then execute function to check
                    %points.
                    if obj.connectToRobot
                        moving = obj.robot.inmotion();
                        pause(0.1)
                        while moving == 1
                            pause(0.1)
                            moving = obj.robot.inmotion();
                        end
                        if obj.finish == true
                            return
                        else
                          obj.checkPoints()
                        end

                        %Return to initial point
                        obj.robot.senddatawait(obj.initialCoords);
                        
                    end
                    obj.finish = true;
                end
                obj.status = "";
            end
        end

        %This function would count points applying a bonification for color
        %Red figures are harder to pick, blue are medium difficulty and
        %green easy.
        function checkPoints(obj)
            total = 0;
            %With the next iterator, we go through each point to check if
            %there's any figure there.
            for i = 1:length(obj.objectCoords) 
                coords = obj.objectCoords{i}.coords;
                X = coords(1);
                Y = coords(2);
                Z = coords(3);

                obj.movement("M "+num2str(X)+" "+num2str(Y)+" 140 - -");
                obj.movement("M - - "+num2str(Z)+" - -");

                %With the next iterator, we try 5 times to detect colors in
                %case of fails on detection.
                for j = 1:5
                    img = obj.camera.getframe();
                    
                    %detectObjectArkade is a reciclated function. This
                    %function cheks color, orientation and distance to a
                    %black point on the figure.
                    [color, ~, ~] = detectObjectArkade(img);

                    %Once color is detected, break the iterator.
                    if color ~= ""
                        break
                    end
                end

                % Dependig on the color of the block, puntuation would be 
                % multiplied.
                multiplier = 0;
                switch color
                    case 'r'
                        multiplier = 2.5;
                    case 'b'
                        multiplier = 2;
                    case 'g'
                        multiplier = 1.5;
                    otherwise
                end

                total = total + obj.objectCoords{i}.points * multiplier;
            end
           
            %Send info to js about score.
            results.userName = obj.session.userName;
            results.score = total;
            results.position = "#";
            results = jsonencode(results);
            sendEventToHTMLSource(obj.ui.html, "FinalResults", results)
        end

        %This function is made to superpose a uipanel over our uihtml where
        % would be showed images from the camera.
        function cameraLayout(obj, ~, ~)
            if ~isfield(obj.ui, "camera")
                %Position is hardcoded, cause size of html changes.
                obj.ui.camera.imgPanel = uipanel(obj.ui.fig, Units="normalized", Position=[0.143,0.176,0.40,0.45]);
                obj.ui.camera.axes = axes(obj.ui.camera.imgPanel, ...
                    'Units', 'normalized', 'Position', [0 0 1 1], ... 
                    'XTick', [], 'YTick', [], 'XColor', 'none', 'YColor', 'none');
                 axis(obj.ui.camera.axes, 'image')
                 im1 = obj.camera.getframe();
                 obj.ui.camera.img = image(obj.ui.camera.axes, 'CData', im1);
            else
                if isvalid(obj.ui.camera.imgPanel)
                    data = obj.camera.getframe();
                    set(obj.ui.camera.img, 'CData', data);
                    drawnow limitrate;
                end
            end
        end
        
        %Here we get datas of scoreboard.
        function getScoreboard(obj, target)
            switch target
                case "all"
                    %In theory, here we would need to get data from a DB,
                    %but for this project is not important.
                    %Fake datas :)
                    scoreboard = [
                        struct('name', 'Manuel', 'score', 100)
                        struct('name', 'Pablo Scu', 'score', 200)
                        struct('name', 'Mario?', 'score', 300)
                        struct('name', 'Yes Mario!', 'score', 400)
                        struct('name', 'me?', 'score', 500)
                        struct('name', 'Luigi!', 'score', 600)
                    ];
                    sendEventToHTMLSource(obj.ui.html, "Scoreboard", scoreboard);
                case "user"
                    %The idea was to prepare and introduce player in
                    %general score.
                    
                otherwise

            end
        end

        function playerMedia(obj)
            [audio, Fs] = audioread("./assets/audio/arkade.mp3");
            obj.music.player = audioplayer(audio, Fs);
            play(obj.music.player);  % Play once
            
            while isfield(obj.music, "player")
                if isempty(obj.music.player)
                    break
                end
                if ~isplaying(obj.music.player) && ~obj.music.paused
                    play(obj.music.player);  % Vuelve a reproducir cuando termine
                end
                enable = obj.music.enable;
                if enable
                    obj.music.player.resume;
                    obj.music.paused = false;
                else
                    obj.music.player.pause;
                    obj.music.paused = true;
                end
                
                pause(0.3);  % Just a little pause
            end

        end

        %This function would be called when the ui is closed.
        function closeFigure(obj, ~, ~)
            %Stop music if enabled
            if isfield(obj.music, "player")
                stop(obj.music.player);
                delete(obj.music.player);
                obj.music.player = [];
            end
            %Stop and delete timers if are enambled.
            if ~isempty(obj.timers)
                namesTimer = fieldnames(obj.timers);
                numTimers = length(namesTimer);
                if numTimers > 0
                    %delete each timerr
                    for i = 1:numTimers
                        name = namesTimer{i};
                        if isvalid(obj.timers.(name))
                            obj.timers.(name)
                            stop(obj.timers.(name))
                            pause(0.1)
                            delete(obj.timers.(name))
                        end
                    end
                end
            end
        end

        %% Robot functions:
        function cr = connectRotobt(~)
            %**********************************************************************
            % Connexió amb el robot cartesià
            %**********************************************************************
            % Crear una nova instància de robot cartesià
            cr = robotcart();
            
            % Intentar establir connexió amb el robot
            for attempt = 1:3
                % Intentar obrir port 
                [ok, ~] = cr.openauto();
                
                % Mirar si hem tingut exit obrint el port
                if ok == 1
                    % s'ha tingut exit, sortir del bucle
                    break;
                end
                
                % No s'ha tingut exit, mostrar missatge d'error
            end
        end

        function cc = connectCamera(~)
            %**********************************************************************
            % Connexió la camera
            %**********************************************************************    
            
            % Crear una nova instància de la cam
            cc = robotcam();
            
            [ok, message] = cc.opencam();
            
            if ~ok
                disp(['Error connectant amb la cam: ',message]);
                cc = [];
            end 
        end

        %Function to move robot without applying a wait.
        function movement(obj, command)
            obj.robot.senddatawait(command);
            pause(0.2)
            waitToStop0 = 1;
            while waitToStop0 == 1
                pause(0.1)
                waitToStop0 = obj.robot.inmotion();
            end
        end
    end

end

