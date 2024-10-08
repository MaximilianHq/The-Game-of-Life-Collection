import random, time, json, os
from cellgrid import Cellgrid
import functions as function

GRIDSIZE = 45
TICK_INTERVAL = 1 # seconds
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATAFILE = os.path.join(BASE_DIR, 'cellgrid.json')

def displayCells():
    for row in cellgrid:
        print(" ".join(repr(cell) for cell in row))
    print("\n")

def validateFile(pathh:str) -> bool: #TODO ?

    if not os.path.exists(pathh):
        print(f"Error: {pathh} does not exist. Run the simulation first.")
        return False
    
def addToHistory(old_cellgrid):
    pass

def printToFile():
    
    serial_cellgrid = Cellgrid.SerializeGrid(cellgrid)

    # save it to JSON file
    with open(DATAFILE, "a") as file:
        json.dump(serial_cellgrid, file)
        file.close()

def readFile():
    if not validateFile(DATAFILE):
        return

    cellgrid_history = list()

    with open(DATAFILE, 'r') as file:
        loaded_data = json.load(file)  # load the entire file content
        file.close()

    # process the data in chunks of GRIDSIZE rows
    for i in range(0, len(loaded_data), GRIDSIZE):
        # extract up to GRIDSIZE rows (the last chunk may have fewer rows)
        grid_chunk = loaded_data[i:i + GRIDSIZE]

        # convert this chunk to a cellgrid
        un_serialized_cellgrid = Cellgrid.unSerializeGrid(grid_chunk)

        cellgrid_history.append(un_serialized_cellgrid)

    return cellgrid_history

def runSimulation(ticks:int, gen):
    for i in range(ticks):
        addToHistory(gen) #TODO
        displayCells()
        Cellgrid.updateCells()
        time.sleep(TICK_INTERVAL)

def replaySimulation(): #TODO
    cellgrid = readFile()
    runSimulation()

def mainMenu():
    print("============\n1. run simulation\n2. simulation history\n3. exit\n============")

if __name__ == "__main__":

    # check if the file exists and delete it
    if os.path.exists(DATAFILE):
        os.remove(DATAFILE)

    # create cellgrid
    cellgrid = Cellgrid(GRIDSIZE)
    generations = list()
    
    while True:
        mainMenu()
        men_v = int(function.inputBracket(""))
        if men_v == 1:
            sim_steps = int(function.inputBracket("Simulation steps"))
            if sim_steps > 0:
                runSimulation(sim_steps, generations)
        elif men_v == 2:
            replaySimulation()
        elif men_v == 3:
            exit()
        else:
            print("Not valid input")