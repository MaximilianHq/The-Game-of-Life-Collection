import random, time, json, os
from cellgrid import Cellgrid
import functions as function

GRIDSIZE = 45
TICK_INTERVAL = 1 # seconds
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATAFILE = os.path.join(BASE_DIR, 'cellgrid.json')

def validateFile(pathh:str) -> bool:

    if not os.path.exists(pathh):
        print(f"Error: {pathh} does not exist. Run the simulation first.")
        return False

def runSimulation(cellg:Cellgrid, ticks:int):
    for i in range(ticks):
        cellg.displayCellgrid()
        cellg.updateCells
        time.sleep(TICK_INTERVAL)
        
def mainMenu():
    print("============\n1. run simulation\n2. simulation history\n3. exit\n============")

if __name__ == "__main__":

    # check if the file exists and delete it
    if os.path.exists(DATAFILE):
        os.remove(DATAFILE)

    # create cellgrid
    cellgrid = Cellgrid(GRIDSIZE)
    
    while True:
        mainMenu()
        men_v = int(function.inputBracket(""))
        if men_v == 1:
            sim_steps = int(function.inputBracket("Simulation steps"))
            if sim_steps > 0:
                runSimulation(cellgrid, sim_steps)
        elif men_v == 2:
            pass
        elif men_v == 3:
            exit()
        else:
            print("Not valid input")