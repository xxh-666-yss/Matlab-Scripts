% Sulfate reduction rate 2D cloud map plot
clear; clc; close all
warning off
% Data entry
A = [1 5 5 5 1 5 1 5 9 9 9 9 5 1]; % COD/SO42-
B = [40 40 30 30 30 40 35 35 35 40 35 30 35 35]; % temperature
C = [0.105 0.2 0.2 0.01 0.105 0.01 0.01 0.105 0.2 0.105 0.01 0.105 0.105 0.2]; % Gas flow rate
response = [12.48055 25.35792 36.86151 85.73757 19.83483 63.09044 38.13484 38.27659 28.86984 26.70388 88.78447 85.09467 36.09676 10.39038]; % Sulfate reduction rate

% Create a grid
A_grid = linspace(1, 9, 20);
C_grid = linspace(0.01, 0.2, 20);
[A_mesh, C_mesh] = meshgrid(A_grid, C_grid);

% Temperature setting
temps = [30, 35, 40];

% Change both width and height to 1200
figure('Position', [100, 100, 1200, 1200]);

for i = 1:3
    subplot(1, 3, i);
    
    % Filter the data for the current temperature
    idx = (B == temps(i));
    A_temp = A(idx);
    C_temp = C(idx);
    response_temp = response(idx);
    
    if temps(i) == 30 || temps(i) == 40
        % Create rectangular grid points
        A_rect = [1, 5, 9];
        C_rect = [0.01, 0.105, 0.2];
        [A_rect_mesh, C_rect_mesh] = meshgrid(A_rect, C_rect);
        A_rect_flat = A_rect_mesh(:);
        C_rect_flat = C_rect_mesh(:);
        
        % Interpolation calculates the response value
        response_rect = griddata(A_temp, C_temp, response_temp, A_rect_flat, C_rect_flat, 'linear');
        
        % Process NaN values
        nan_idx = isnan(response_rect);
        if any(nan_idx)
            response_rect(nan_idx) = griddata(A_temp, C_temp, response_temp, A_rect_flat(nan_idx), C_rect_flat(nan_idx), 'nearest');
        end
        
        % Mesh interpolation
        Z = griddata(A_rect_flat, C_rect_flat, response_rect, A_mesh, C_mesh, 'cubic');
    else
        % Direct mesh interpolation
        Z = griddata(A_temp, C_temp, response_temp, A_mesh, C_mesh, 'cubic');
    end
    
    % Use pcolor to draw a cloud map
    pcolor(A_mesh, C_mesh, Z);
    shading interp; % Interpolation smooth
    hold on;
    
    % Create a contour hierarchy in multiples of 10
    min_val = min(Z(:));
    max_val = max(Z(:));
    
    % Calculate a multiple level of 10
  start_level = 10 * ceil(min_val/10); % Smallest multiple of 10 greater than or equal to the minimum value
end_level = 10 * floor(max_val/10); % Largest multiple of 10 less than or equal to the maximum value
levels = start_level:10:end_level; % Sequence of multiples of 10

% If there are fewer than 5 levels, generate 5 levels using the default method
if numel(levels) < 5
levels = linspace(min_val, max_val, 5);
levels = 10 * round(levels/10); % Round to the nearest multiple of 10
end

% === Modified contour labeling method ===
% Plot contours and obtain contour matrix
[contourMatrix, contourHandle] = contour(A_mesh, C_mesh, Z, levels, 'k', 'LineWidth', 0.5);

% Set label spacing to a large value to ensure only one label per contour line
set(contourHandle, 'LabelSpacing', 1000);

% Add contour labels
clabel(contourMatrix, contourHandle, 'FontSize', 8, 'Color', 'k');

colorbar;

% Add data points
scatter(A_temp, C_temp, 50, response_temp, 'filled', 'MarkerEdgeColor', 'k');

% Figure settings
xlabel('COD/SO_4^{2-}');
ylabel('Gas stripping flow');
title(sprintf(' %d°C', temps(i)));
colormap('jet');
grid on;
set(gca,'FontName','Times New Roman');
set(gca,'XTick',1:2:9);% Set the coordinate ticks to be displayed
set(gca,'YTick',[0.01:0.038:0.200]);% Set the coordinate ticks to be displayed
set(gca,'YTicklabel',{'0.010','0.048','0.086','0.124','0.162','0.200'})

% Set square aspect ratio
axis square;
end

% Adjust subplot positions to fit the larger figure window
for i = 1:3
subplot(1, 3, i);
pos = get(gca, 'Position');
% Adjust position: keep width, increase height, center vertically
new_height = min(pos(3), 0.25); % Maximum height is 0.25 (normalized units)
new_pos = [pos(1), (1 - new_height)/2, pos(3), new_height];
set(gca, 'Position', new_pos);
end
