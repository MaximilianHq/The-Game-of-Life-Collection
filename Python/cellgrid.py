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

                # iterate through the relative positions to gather neighbors
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
        
        for row in self.cellgrid:
            for cell in row:
                cell.update()

    def displayCellgrid(self):
        for row in self.cellgrid:
            print(" ".join(repr(cell) for cell in row))
        print("\n")
        
    def SerializeGrid(self):
        # convert to dict
        serial_cellgrid = [[Cell.serialize() for cell in row] \
                            for row in self.cellgrid]
        
        return serial_cellgrid

    @classmethod
    def unSerializeGrid(cls, grid_chunk):
        un_serialized_cellgrid = [[Cell.unSerialize(cell_data) for cell_data in row] \
                                    for row in grid_chunk]
        
        return un_serialized_cellgrid