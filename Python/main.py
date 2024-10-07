import random, time, json, os
from cell import Cell
import functions

GRIDSIZE = 45
TICK_INTERVAL = 1 # seconds
DATAFILE = 'cellmap.json'

def updateCells():
    pos = [-1,0,1] # positions arount each cell in each direction

    # itterate over all cells
    for i, row in enumerate(cellmap):
        for j, cell in enumerate(row):
            neighbors = []

            # iterate through the relative positions to gather neighbors
            for di in pos:  # delta for row
                for dj in pos:  # delta for column
                    if di == 0 and dj == 0:
                        continue  # skip middle cell

                    # calculate neighbor indices
                    ni, nj = i + di, j + dj

                    # check if the neighbor indices are within bounds
                    if 0 <= ni < GRIDSIZE and 0 <= nj < GRIDSIZE:
                        neighbors.append(cellmap[ni][nj])

            cell.setNextState(neighbors)
    
    for row in cellmap:
        for cell in row:
            cell.update()

def displayCells():
    for row in cellmap:
        print(" ".join(repr(cell) for cell in row))
    print("\n")

def printToFile():
    
    # convert to dict
    serial_cellmap = [[cell.serialize() for cell in row] \
                      for row in cellmap]

    # save it to JSON file
    with open(DATAFILE, "a") as file:
        json.dump(serial_cellmap, file)
        file.close()

def readFile():

    with open(DATAFILE, 'r') as file:
        loaded_data = json.load(file)
        file.close()

    # convert to cellmap
    loaded_cellmap = [[Cell.from_dict(cell_data) for cell_data in row] \
                      for row in loaded_data]
    
    return loaded_cellmap

def runSimulation(ticks:int=10):
    for i in range(ticks):
        printToFile()
        displayCells()
        updateCells()
        time.sleep(TICK_INTERVAL)

def mainMenu():
    print("============\
          1. run simulation\
          2. simulation history\
          3. exit\
           ============")

if __name__ == "__main__":

    # check if the file exists and delete it
    if os.path.exists(DATAFILE):
        os.remove(DATAFILE)

    # create cellmap
    cellmap = [[Cell(random.choice([True, False, False])) \
                for i in range(GRIDSIZE)] for j in range(GRIDSIZE)]
    
    mainMenu()
    


    runSimulation()