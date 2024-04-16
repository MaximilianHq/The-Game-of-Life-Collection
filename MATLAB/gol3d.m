
%% Game of Life
clear
clc
close all

enum_state = struct('dead',0,'alive',1);
entity = struct('state',enum_state.alive);

GRIDHEIGHT = 10;
GRIDWIDTH = GRIDHEIGHT;
GRIDDEPTH = GRIDHEIGHT;
SIM_STEPS = 100;        % generation count
FRAMERATE = 1;          % fps
CELLSIZE = 500;         % px (45)
CELLCOLOR = 'b';
FIGURESIZE = 600;       % px

cells = repmat(entity,[GRIDHEIGHT,GRIDWIDTH,GRIDDEPTH]);
cells = genRandomSeed(cells,GRIDHEIGHT,GRIDWIDTH,GRIDDEPTH,enum_state);

for f = 1:SIM_STEPS
    binary_array = zeros(GRIDHEIGHT,GRIDWIDTH,GRIDDEPTH);

    % loop through cells
    for i = 1:GRIDHEIGHT
        for j = 1:GRIDWIDTH
            for k = 1:GRIDDEPTH
                % calculate next state
                population = getNeighborsAlive( ... 
                    i,j,k,cells,GRIDHEIGHT,GRIDWIDTH,GRIDDEPTH);
                cells(i,j,k).state = applyGamelogic(...
                    i,j,k,cells,population,enum_state);
    
                % convert structure array to binary
                if cells(i,j,k).state == enum_state.alive
                    binary_array(i,j,k) = 1;
                end
            end
        end
    end
    
    % plot alive cells only
    % create x,y,z translation vector
    [x, y, z] = meshgrid(1:GRIDWIDTH, GRIDHEIGHT:-1:1, GRIDDEPTH:-1:1);
    indices = find(binary_array); % find indices where status ~= 0
    scatter3(x(indices),y(indices),z(indices), ...
        CELLSIZE,'filled','MarkerEdgeColor','k')

    % plot components
    fig = gcf;                                      % get figure handle
    screen_size = get(0, 'ScreenSize');             % get screen size
    fig_position = [(screen_size(3)-FIGURESIZE)/2, ...
        (screen_size(4)-FIGURESIZE)/2, FIGURESIZE, FIGURESIZE];
    set(fig, 'Position', fig_position);

    axis off;                                       % remove axis ticks
    axis([0 GRIDHEIGHT 0 GRIDWIDTH 0 GRIDDEPTH]);   % force aspect ratio

    title(['Cells alive: ' num2str(length(indices))]); % set title
    
    % pause to create animation effect
    pause(1/FRAMERATE);
    
    % clear the current plot
    clf;
end

function cells_random = genRandomSeed( ... % generate random cellmap
    cells,GRIDHEIGHT,GRIDWIDTH,GRIDDEPTH,enum_state)
    
    % loop through cells
    for i = 1:GRIDHEIGHT
        for j = 1:GRIDWIDTH
            for k = 1:GRIDDEPTH
                % get a random state for each cell
                state_names = fieldnames(enum_state);
                selected_state = enum_state.(state_names{randi([1, 2])});
                cells(i,j,k).state = selected_state;
            end
        end
    end
    cells_random = cells;

end

function next_state = applyGamelogic( ... % apply gamerules
    i,j,k,cells,population,enum_state)
    
    current_state = cells(i,j,k).state;
    next_state = current_state;
    
    if current_state == enum_state.alive
        if population < 5 || population > 6
            next_state = enum_state.dead;
        end
    else
        if population == 4
            next_state = enum_state.alive;
        end
    end

end

function neighbors_alive = getNeighborsAlive( ... % count neighbors alive
    i,j,k,cells,GRIDHEIGHT,GRIDWIDTH,GRIDDEPTH)
    
    neighbors_alive = 0;
    
    for h = -1:1
        for g = -1:1
            for f = -1:1
                % skip center cell
                if i==0 && j==0 && k==0
                    continue;
                end
                % check if neighbors are within bounds
                if i+h>=1 && i+h<=GRIDHEIGHT ...
                        && j+g>=1 && j+g<=GRIDWIDTH ...
                        && k+f>=1 && k+f<=GRIDDEPTH
                    neighbors_alive = neighbors_alive + ...
                        cells(i+h, j+g, k+f).state;
                end
            end
        end
    end
end