import random, time
from cellgrid import Cellgrid
import functions as function

GRIDSIZE = 40
TICK_INTERVAL = 1 # seconds

# def validateFile(pathh:str) -> bool:
    # if not os.path.exists(pathh):
        # print(f"Error: {pathh} does not exist. Run the simulation first.")
        # return False

def runSimulation(cellg:Cellgrid, ticks:int = 10, visibility:bool = True):
    for i in range(ticks):
        if visibility:
            cellg.displayCellgrid()
            time.sleep(TICK_INTERVAL)
        if not cellg.updateCells() and not visibility:
            break
    # if was previously hidden
    if not visibility:
        cellg.displayCellgrid()
    
def MenuBorder(text:str):
    border = "================="
    return f"\n{border}\n{text}\n{border}\n"

if __name__ == "__main__":
    
    while True:
        menu_str = "1. run GoL\n2. change gridsize\n3. exit"
        men_v = int(function.inputBracket(MenuBorder(menu_str)))

        if men_v == 1:
            cellgrid = Cellgrid(GRIDSIZE)
            mode_str = "select mode:\n1. default\n2. simulation"

            while True:
                mode = int(function.inputBracket(MenuBorder(mode_str)))
                if mode == 3:
                    continue

                sim_steps = int(function.inputBracket("simulation steps"))
                if sim_steps > 0:
                    runSimulation(cellgrid, sim_steps, False if mode == 2 else True)

                    if not function.inputBracket("Continue simulation from point (y/n)?") == "y":
                        break
                
        elif men_v == 2:
            gridsize_str = "set new gridsize"
            GRIDSIZE = int(function.inputBracket(gridsize_str))
    
        elif men_v == 3:
            exit()
        else:
            print("non valid input")