



clc; clear; close all;

% ---------------- ??????? ??? ----------------
nLayers = 7; % ????? ??????? (???)
Rin = 2;     % ???? ?????
Rout = 7;    % ???? ?????
theta = linspace(0, pi/2, 200); % ??? ?? ????? ?????
models = {'UD','A','V','X','O'};
minColorIntensity = 0.01; % ????? ??? ???

% ---------------- ???? ????? ----------------
getDistribution = @(modelType, n) ...
    ( ...
        strcmp(modelType,'UD') * ones(1,n) + ...
        strcmp(modelType,'A')  * linspace(0.2, 1, n) + ...
        strcmp(modelType,'V')  * linspace(1, 0.2, n) + ...
        strcmp(modelType,'X')  * [linspace(0.2,1,ceil(n/2)), linspace(1-1/(ceil(n/2)-1),0.2,ceil(n/2)-1)] + ...
        strcmp(modelType,'O')  * [linspace(1,0.2,ceil(n/2)), linspace(0.2+1/(ceil(n/2)-1),1,ceil(n/2)-1)] ...
    );

% ---------------- ??? ?: ??????? ?????? ----------------
figure('Name','Graphene Distributions','Color','w');
for m = 1:length(models)
    subplot(1,5,m)
    fracs = getDistribution(models{m}, nLayers);
    fracs = (fracs - min(fracs)) / (max(fracs) - min(fracs) + eps);
    
    % ????? ?????? ????? ???? UD
    if strcmp(models{m}, 'UD')
        darknessFactor = 0.5; % ???????
    else
        darknessFactor = 1;
    end
    
    for i = 1:nLayers
        r1 = Rin + (i-1)*(Rout-Rin)/nLayers;
        r2 = Rin + i*(Rout-Rin)/nLayers;
        X1 = r1*cos(theta); Y1 = r1*sin(theta);
        X2 = r2*cos(fliplr(theta)); Y2 = r2*sin(fliplr(theta));
        c = minColorIntensity + fracs(i)*(1-minColorIntensity)*darknessFactor;
        fill([X1 X2],[Y1 Y2], [0 0 c] + (1-c)*[0 1 1], 'EdgeColor','k'); % ??? ??? ???? ?????
        hold on;
    end
    title(['Graphene - ' models{m}]);
    axis equal off;
end

% ---------------- ??? ?: ??????? ????? ----------------
figure('Name','Porosity Distributions','Color','w');
for m = 1:length(models)
    subplot(1,5,m)
    fracs = getDistribution(models{m}, nLayers);
    fracs = (fracs - min(fracs)) / (max(fracs) - min(fracs) + eps);
    
    % ????? ?????? ????? ???? UD
    if strcmp(models{m}, 'UD')
        darknessFactor = 0.7; % ???????
    else
        darknessFactor = 1;
    end
    
    for i = 1:nLayers
        r1 = Rin + (i-1)*(Rout-Rin)/nLayers;
        r2 = Rin + i*(Rout-Rin)/nLayers;
        X1 = r1*cos(theta); Y1 = r1*sin(theta);
        X2 = r2*cos(fliplr(theta)); Y2 = r2*sin(fliplr(theta));
        c = minColorIntensity + fracs(i)*(1-minColorIntensity)*darknessFactor;
        fill([X1 X2],[Y1 Y2], [c 0 0] + (1-c)*[1 1 0], 'EdgeColor','k'); % ??? ???? ???? ?????
        hold on;
    end
    title(['Porosity - ' models{m}]);
    axis equal off;
end
