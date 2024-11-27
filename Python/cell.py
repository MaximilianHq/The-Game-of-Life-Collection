import html

class Cell:

    def __init__(self, state:bool=False):
        self.state = state
        self.next_state = state
        self.repetitions = 0

    def __repr__(self):
        # represent alive cell as ascii icon
        return html.unescape("&#9632;") if self.state \
        else " " # html.unescape("&#9633;")

    def setNextState(self, neighbors:list):

        # make sure all neighbors are cells
        if not all(isinstance(neighbor, Cell) for neighbor in neighbors):
            raise TypeError(f"Element is not an instance of Cell.")  # raise an error
            
        # count neighbors alive
        population = sum(1 for cell in neighbors if cell.state)
        
        # apply gamerules
        if (population < 2 or population > 3) and self.state == True:
            self.next_state = False
        elif population == 3 and self.state == False:
            self.next_state = True

    def update(self):
        self.state = self.next_state

        if self.state == self.next_state and self.state == True:
            self.repetitions += 1
        else:
            self.repetitions = 0