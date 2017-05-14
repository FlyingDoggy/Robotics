classdef Robot
    
    properties (Constant)
        wheelCircumference = 4.32 * pi;
        interWheelDistance = 11.5;
    end
    
    properties
        simMode
        botSim
        nxtHandle
        mLeft
        mRight
        mBoth
        mScan
        numScan;
    end
    
    methods
        %% Constructor
        function bot = Robot(botSim)
            if nargin < 1
                bot.simMode = 0;
                
                warning ('off','all');
                COM_CloseNXT('all');
                bot.nxtHandle = COM_OpenNXT();
                COM_SetDefaultNXT(bot.nxtHandle);

                bot.mLeft = NXTMotor('C');
                bot.mLeft.ActionAtTachoLimit = 'Brake';
                bot.mLeft.SmoothStart = true;
                bot.mLeft.SpeedRegulation = true;

                bot.mRight = bot.mLeft;
                bot.mRight.Port = MOTOR_B;

                bot.mBoth = bot.mLeft;
                bot.mBoth.Port = [MOTOR_B; MOTOR_C];
                bot.mBoth.SpeedRegulation = false;

                bot.mScan = NXTMotor('A');
                bot.mScan.ActionAtTachoLimit = 'Brake';
                bot.mScan.SmoothStart = false;
                bot.mScan.SpeedRegulation = true;
                bot.mScan.ResetPosition();

                OpenUltrasonic(SENSOR_1);

                BatteryLevel = NXT_GetBatteryLevel()
            else
                bot.simMode = 1;
                bot.botSim = botSim;
            end
        end
        
        %% Destructor
        function close(bot)
            if bot.simMode == 0
                bot.mLeft.Stop('off');
                bot.mRight.Stop('off');
                bot.mBoth.Stop('off');
                bot.mScan.Stop('off');

                CloseSensor(SENSOR_1);

                COM_CloseNXT(bot.nxtHandle);
            end
        end
        
        %% Turn off motors
        function off(bot)
            if bot.simMode == 0
                bot.mLeft.Stop('off');
                bot.mRight.Stop('off');
                bot.mBoth.Stop('off');
                bot.mScan.Stop('off');
            end
        end
        
        %% Play tone when complete
        function complete(bot)
            if bot.simMode == 0
                NXT_PlayTone(440, 500);
            end
        end
        
        %% Move, parameter - cm
        function move(bot, distance)
            if distance == 0
                return
            end
            
            if bot.simMode
                bot.botSim.move(distance);
            else
                % Calibration
                lim = (distance + 0.0929) / 0.0364;

                bot.mBoth.ResetPosition();
                bot.mBoth.TachoLimit = abs(round(lim));

                if distance > 0
                    bot.mBoth.Power = 70;
                else
                    bot.mBoth.Power = -70;
                end

                bot.mBoth.SendToNXT();
                bot.mBoth.WaitFor();
                bot.mBoth.Stop('brake');
            end
        end
        
        %% Turn, parameter - radian
        function turn(bot, angle)
            if angle == 0
                return
            elseif angle > 0
                angle = wrapTo2Pi(angle);
            else
                angle = -wrapTo2Pi(abs(angle));
            end
            
            if angle > pi
                angle = -(2*pi - angle);
            end
            
            if bot.simMode
                bot.botSim.turn(angle);
            else 
                % Calibration
%                 angle = (angle -0.0164)/0.848;
                angle = (angle-0.0044)/0.8649; %new Calibration equation
                lim = angle * bot.interWheelDistance * 0.5 / bot.wheelCircumference * 360;

                bot.mLeft.ResetPosition();
                bot.mRight.ResetPosition();
                bot.mLeft.TachoLimit = abs(round(lim));
                bot.mRight.TachoLimit = abs(round(lim));

                if angle == 0
                    return;
                elseif angle > 0
                    bot.mLeft.Power = -30;
                    bot.mRight.Power = 30;
                else
                    bot.mLeft.Power = 30;
                    bot.mRight.Power = -30;
                end

                bot.mLeft.SendToNXT();
                bot.mRight.SendToNXT();

                bot.mLeft.WaitFor();
                bot.mRight.WaitFor();
                bot.mLeft.Stop('brake');
                bot.mRight.Stop('brake');
            end
        end
        
        %% Use ultrasonic sensor to scan
        function distance = scanFront(bot)
            if bot.simMode
                scan = bot.botSim.ultraScan();
                distance = scan(1);
            else
                distance = GetUltrasonic(SENSOR_1);
                if distance < 25
                    % Calibration
                    distance = (distance - 5) / 0.8333;
                end
                if distance < 0 || distance > 250
                    distance = -1;
                end
            end
        end
        
        %% Scan around
        function distances = scan(bot)
            if bot.simMode
                distances = bot.botSim.ultraScan();
            else 
                distances(bot.numScan, 1) = 0;
                delta = round(365 / bot.numScan);

                bot.mScan.TachoLimit = delta;
                bot.mScan.Power = 50;

                for i = 1:bot.numScan-1
                    distances(i) = bot.scanFront();
                    bot.mScan.SendToNXT();
                    bot.mScan.WaitFor();
                    bot.mScan.Stop('brake');
                end
                distances(bot.numScan) = bot.scanFront();
                
                bot.resetScanMotor();
            end
        end
        
        function distances = scan2(bot)
            if bot.simMode
                distances = bot.botSim.ultraScan();
            else 
                distances(bot.numScan, 1) = 1;
                bot.mScan.TachoLimit = 360;
                bot.mScan.Power = 15;
                bot.mScan.SendToNXT();

                anglesToScan(bot.numScan) = 0;
                for i = 0:bot.numScan - 1
                    anglesToScan(i+1) = i * 360 / bot.numScan;
                end

                data = NXT_GetOutputState(bot.mScan.Port);
                count = 0;
                while data.RotationCount <= (bot.numScan - 1) * 360 / bot.numScan + 1
                    if count < bot.numScan && data.RotationCount >= anglesToScan(count+1)
                        count = count + 1;
                        distances(count) = bot.scanFront();
                    end
                    data = NXT_GetOutputState(bot.mScan.Port);
                end
                bot.mScan.WaitFor();
                bot.mScan.Stop('brake');
                bot.resetScanMotor();
            end
        end
        
        function resetScanMotor(bot)
            if bot.simMode == 0
                data = NXT_GetOutputState(bot.mScan.Port);

                bot.mScan.TachoLimit = abs(data.RotationCount);
                if data.RotationCount > 0
                    bot.mScan.Power = -50;
                else
                    bot.mScan.Power = 50;
                end
                bot.mScan.SendToNXT();
                bot.mScan.WaitFor();
                bot.mScan.Stop('brake');
            end
        end
        
    end
    
end

