import random
from cell import Cell

class Cellgrid:

    def __init__(self, GRIDSIZE) -> None:
        self.GRIDSIZE = GRIDSIZE
        self.cellgrid = list()
        self.initializeGrid()

    def initializeGrid(self):
        self.cellgrid = [[Cell(random.choice([True, False, False])) \
                        for i in range(self.GRIDSIZE)] for j in range(self.GRIDSIZE)]
        
    def updateCells(self):
        pos = [-1,0,1] # positions arount each cell in each direction

        # itterate over all cells
        for i, row in enumerate(self.cellgrid):
            for j, cell in enumerate(row):
                neighbors = []

                # iterate through relative positions and gather neighbors
                for di in pos:  # delta for row
                    for dj in pos:  # delta for column
                        if di == 0 and dj == 0:
                            continue  # skip middle cell

                        # calculate neighbor indices
                        ni, nj = i + di, j + dj

                        # check if the neighbor indices are within bounds
                        if 0 <= ni < self.GRIDSIZE and 0 <= nj < self.GRIDSIZE:
                            neighbors.append(self.cellgrid[ni][nj])

                cell.setNextState(neighbors)
        
        # update each cell
        for row in self.cellgrid:
            for cell in row:
                cell.update()

    def displayCellgrid(self):
        for row in self.cellgrid:
            # display the representation of each cell
            print(" ".join(repr(cell) for cell in row))
        print("\n")