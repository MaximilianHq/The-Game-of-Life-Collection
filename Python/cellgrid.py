import random
from cell import Cell

class Cellgrid:

    def __init__(self, GRIDSIZE) -> None:
        self.GRIDSIZE = GRIDSIZE
        self.cellgrid = list()
        self.initializeGrid()
        self.static_cells = 0

    def initializeGrid(self):
        self.cellgrid = [[Cell(random.choice([True, False, False])) \
                        for i in range(self.GRIDSIZE)] for j in range(self.GRIDSIZE)]
        
    def updateCells(self, static_cell_limit:int = 20,
                    static_cell_repetitions:int = 20):
        self.static_cells = 0 # reset static cell count
        pos = [-1,0,1] # positions arount each cell in each direction

        # itterate over all cells
        for i, row in enumerate(self.cellgrid):
            for j, cell in enumerate(row):

                # check static
                if cell.repetitions > static_cell_repetitions:
                    self.static_cells += 1

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

        if self.static_cells > static_cell_limit:
            return False
        else:
            return True

    def displayCellgrid(self):
        for row in self.cellgrid:
            # display the representation of each cell
            print(" ".join(repr(cell) for cell in row))
        print("\n")