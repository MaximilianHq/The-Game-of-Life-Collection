import random, time
from cellgrid import Cellgrid
import functions as function
import menu_response as menu

GRIDSIZE = 40
TICK_INTERVAL = 1 # seconds

def runSimulation(cellg:Cellgrid, ticks:int = 10, visibility:bool = True):
    for i in range(ticks):
        if visibility:
            cellg.displayCellgrid()
            time.sleep(TICK_INTERVAL)
        if not cellg.updateCells() and not visibility:
            print("Simulation done!")
            break
    # if was previously hidden
    if not visibility:
        cellg.displayCellgrid()

def runGoL():
    cellgrid = Cellgrid(GRIDSIZE)

    while True:
        mode_str = "select mode:\n1. default\n2. simulation"
        mode = int(function.inputBracket(menu.MenuBorder(mode_str)))
        sim_steps = int(function.inputBracket("simulation steps"))

        match mode:
            case 1:
                runSimulation(cellgrid, sim_steps)
            case 2:
                runSimulation(cellgrid, sim_steps, False)
            case _:
                menu.InvalidInput(mode)

        if not function.inputBracket("Continue simulation from point (y/n)?") == "y":
            break

if __name__ == "__main__":

    while True:
        menu_str = "1. run GoL\n2. change gridsize\n3. exit"
        men_v = int(function.inputBracket(menu.MenuBorder(menu_str)))

        match men_v:
            case 1:
                runGoL()
            case 2:
                gridsize_str = "set new gridsize"
                GRIDSIZE = int(function.inputBracket(gridsize_str))
            case 3:
                exit()
            case _:
                menu.InvalidInput(men_v)