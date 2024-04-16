
%% Game of Life
clear
clc
close all

enum_state = struct('dead',0,'alive',1);
entity = struct('state',enum_state.alive);

GRIDHEIGHT = 10;
GRIDWIDTH = 10;
SIM_STEPS = 100;        % generation count
FRAMERATE = 1;          % fps
CELLSIZE = 10;          % px (45)
CELLCOLOR = 'b';
FIGURESIZE = 600;       % px

cells = repmat(entity,[GRIDHEIGHT,GRIDWIDTH]);
cells = genRandomSeed(cells,GRIDHEIGHT,GRIDWIDTH,enum_state);

for f = 1:SIM_STEPS
    binary_array = zeros(GRIDHEIGHT,GRIDWIDTH);

    % loop through cells
    for i = 1:GRIDHEIGHT
        for j = 1:GRIDWIDTH
            % calculate next state
            population = getNeighborsAlive(i,j,cells,GRIDHEIGHT,GRIDWIDTH);
            cells(i,j).state = applyGamelogic(...
                i,j,cells,population,enum_state);

            % convert structure array to binary
            if cells(i,j).state == enum_state.alive
                binary_array(i,j) = 1;
            end
        end
    end
    
    % plot alive cells only

    [x, y] = meshgrid(1:GRIDWIDTH, GRIDHEIGHT:-1:1); % create x and y vector
    z = y;
    indices = find(binary_array); % find indices where status ~= 0
    scatter3(x(indices),y(indices),z(indices),CELLSIZE,'filled')
    % plot components
    fig = gcf;                                      % get figure handle
    screen_size = get(0, 'ScreenSize');             % get screen size
    fig_position = [(screen_size(3)-FIGURESIZE)/2, ...
        (screen_size(4)-FIGURESIZE)/2, FIGURESIZE, FIGURESIZE];
    set(fig, 'Position', fig_position);
    %axis off;                                      % remove axis ticks
    axis([0 10 0 10 0 10]);                         % force aspect ratio

    title("Canway's Game of Life");                 % set title
    xlabel('x')
    ylabel('y')
    zlabel('z')
    
    
    % pause to create animation effect
    pause(1/FRAMERATE);
    
    % clear the current plot
    clf;
end

function cells_random = genRandomSeed( ... % generate random cellmap
    cells,GRIDHEIGHT,GRIDWIDTH,enum_state)
    
    % loop through cells
    for i = 1:GRIDHEIGHT
        for j = 1:GRIDWIDTH
            % get a random state for each cell
            state_names = fieldnames(enum_state);
            selected_state = enum_state.(state_names{randi([1, 2])});
            cells(i,j).state = selected_state;
        end
    end
    cells_random = cells;

end

function next_state = applyGamelogic( ... % apply gamerules
    i,j,cells,population,enum_state)
    
    current_state = cells(i,j).state;
    next_state = current_state;
    
    if current_state == enum_state.alive
        if population < 2 || population > 3
            next_state = enum_state.dead;
        end
    else
        if population == 3
            next_state = enum_state.alive;
        end
    end

end

function neightbors_alive = getNeighborsAlive( ... % count neighbors alive
    i,j,cells,GRIDHEIGHT,GRIDWIDTH)
    
    neightbors_alive = 0;
    
    % top section
    if i-1 >= 1 && j-1 >= 1
        neightbors_alive = neightbors_alive + cells(i-1,j-1).state;
    end
    if i-1 >= 1
        neightbors_alive = neightbors_alive + cells(i-1,j).state;
    end 
    if i-1 >= 1 && j+1 <= GRIDWIDTH
        neightbors_alive = neightbors_alive + cells(i-1,j+1).state;
    end
    % middle section
    if j-1 >= 1
        neightbors_alive = neightbors_alive + cells(i,j-1).state;
    end
    if j+1 <= GRIDWIDTH
        neightbors_alive = neightbors_alive + cells(i,j+1).state;
    end
    % bottom section
    if i+1 <= GRIDHEIGHT && j-1 >= 1
        neightbors_alive = neightbors_alive + cells(i+1,j-1).state;
    end
    if i+1 <= GRIDHEIGHT
        neightbors_alive = neightbors_alive + cells(i+1,j).state;
    end
    if i+1 <= GRIDHEIGHT && j+1 <= GRIDWIDTH
        neightbors_alive = neightbors_alive + cells(i+1,j+1).state;
    end

end