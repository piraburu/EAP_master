from mesa import Model
from mesa.space import MultiGrid
from mesa import Agent
from mesa.time import RandomActivation
import matplotlib 
import numpy as np

class mainmodel(Model):
    def __init__(self, n1,n2,n3, width, height):
        super().__init__()   # this fixes the problem 
        self.doves_n = n1
        self.hawks_n = n2
        self.food = n3
        self.grid = MultiGrid(width, height, True)
        self.schedule = RandomActivation(self)
        # Create agents
        for i in range(self.doves_n):
            a = doves(i,self)
            self.schedule.add(a)
            # Add the agent to a random grid cell
            x = self.random.randrange(self.grid.width)
            y = self.random.randrange(self.grid.height)
            self.grid.place_agent(a, (x, y))
        for i in range(self.hawks_n):
            b = hawks(i, self)
            self.schedule.add(b)
            # Add the agent to a random grid cell
            x = self.random.randrange(self.grid.width)
            y = self.random.randrange(self.grid.height)
            self.grid.place_agent(b, (x, y))
        for i in range(self.food):
            c = food(i, self)
            self.schedule.add(c)
            # Add the agent to a random grid cell
            x = self.random.randrange(self.grid.width)
            y = self.random.randrange(self.grid.height)
            self.grid.place_agent(c, (x, y))        
    def step(self):
        self.schedule.step()
        n1=self.doves_n
        n2=self.hawks_n


class doves(Agent):
    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)
        self.food = 1
    def move(self):
        possible_steps = self.model.grid.get_neighborhood(
            self.pos,
            moore=True,
            include_center=False)
        new_position = self.random.choice(possible_steps)
        self.model.grid.move_agent(self, new_position)
   def give_food(self):
        cellmates = self.model.grid.get_cell_list_contents([self.pos])
        if len(cellmates) > 1:
            doves = [obj for obj in cellmates if isinstance(obj, doves)]
            food = [obj for obj in cellmates if isinstance(obj, food)]
            hawks = [obj for obj in cellmates if isinstance(obj, hawks)
            if len(hawks)> 0 and len(food)> 0 and food.eaten==0:
                other.food = 0
                self.food  = 0
                food.eaten = 1
            if len(doves)>0 and len(food)>0 and food.eaten==0:
               other.food += 1
               self.food  += 1 
               food.eaten  = 1
	   if len(food)>0 and food.eaten==0:
               self.food +=2
               food.eaten=1
    def step(self):
        if self.food < 0:
            self.model.grid._remove_agent(self.pos, self)
            self.model.schedule.remove(self)            
        if self.food >= 2:
           Model.doves_n +=1
        self.move()
        self.food-=1


class hawks(Agent):
    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)
        self.food = 1
    def move(self):
        possible_steps = self.model.grid.get_neighborhood(
            self.pos,
            moore=True,
            include_center=False)
        new_position = self.random.choice(possible_steps)
        self.model.grid.move_agent(self, new_position)
   def steal_food(self):
        cellmates = self.model.grid.get_cell_list_contents([self.pos])
        if len(cellmates) > 1:
            doves = [obj for obj in cellmates if isinstance(obj, doves)]
            food = [obj for obj in cellmates if isinstance(obj, food)]
            hawks = [obj for obj in cellmates if isinstance(obj, hawks)
            if len(hawks)>0 and len(food)>0 and food.eaten==0:
                other.food=0
                self.food=0
                food.eaten=1
            if len(doves)>0 and len(food)>0 and food.eaten==0:
               other.food += 0.5
               self.food  += 1.5   
               food.eaten=1
	   if len(food)>0 and food.eaten==0:
               self.food +=2     
               food.eaten=1   
    def step(self):
        if self.food < 0:
            self.model.grid._remove_agent(self.pos, self)
            self.model.schedule.remove(self)
        if self.food >= 2:
           Model.hawks_n +=1    
        self.food-=1

        
# Food Agent
class food(Agent):
    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)
        self.eaten=false
    def move(self):
        possible_steps = self.model.grid.get_neighborhood(
            self.pos,
            moore=True,
            include_center=False)
        new_position = self.random.choice(possible_steps)
        self.model.grid.move_agent(self, new_position)
    def step(self):
        self.move()

# Model inputs
model = mainmodel(10,10,10,10,10)
for i in range(20):
    model.step()


