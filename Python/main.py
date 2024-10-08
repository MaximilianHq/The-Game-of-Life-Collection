import random, time, copy
from cellgrid import Cellgrid
import functions as function

GRIDSIZE = 8
TICK_INTERVAL = 1 # seconds
# BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# DATAFILE = os.path.join(BASE_DIR, 'cellgrid.json')

# def validateFile(pathh:str) -> bool:
    # if not os.path.exists(pathh):
        # print(f"Error: {pathh} does not exist. Run the simulation first.")
        # return False

def runSimulation(cellg:Cellgrid, ticks:int = 10, visibility:bool = True):
    for i in range(ticks):
        if visibility:
            cellg.displayCellgrid()
            time.sleep(TICK_INTERVAL)
        cellg.updateCells()
    # if was previously hidden
    if not visibility:
        cellg.displayCellgrid()
        return cellg
    
def MenuBorder(text:str):
    border = "================="
    return f"\n{border}\n{text}\n{border}\n"

if __name__ == "__main__":

    # check if the file exists and delete it
    # if os.path.exists(DATAFILE):
        # os.remove(DATAFILE)
    
    while True:
        menu_str = "1. run GoL\n2. exit"
        men_v = int(function.inputBracket(MenuBorder(menu_str)))

        if men_v == 1:
            cellgrid = Cellgrid(GRIDSIZE)
            mode_str = "select mode:\n1. default\n2. simulation"

            while True:
                mode = int(function.inputBracket(MenuBorder(mode_str)))
                sim_steps = int(function.inputBracket("simulation steps"))

                if sim_steps > 0:
                    runSimulation(cellgrid, sim_steps, False if mode == 2 else True)

                    if not function.inputBracket("Continue simulation from point (y/n)?") == "y":
                        break
    
        elif men_v == 2:
            exit()
        else:
            print("Not valid input")