from model import mainmodel, hawks, doves, food
from mesa.visualization.modules import CanvasGrid
from mesa.visualization.ModularVisualization import ModularServer


def agent_portrayal(agent):

    if type(agent) is doves:
        portrayal = {"Shape": "circle",
                     "Filled": "true",
                     "Layer": 0,
                     "Color": "red",
                     "r": 0.5}
    elif type(agent) is hawks:
        portrayal = {"Shape": "circle",
                     "Filled": "true",
                     "Layer": 0,
                     "Color": "black",
                     "r": 0.5}
    elif type(agent) is food:
        portrayal = {"Shape": "circle",
                     "Filled": "true",
                     "Layer": 0,
                     "Color": "blue",
                     "r": 0.5}
    return portrayal


grid = CanvasGrid(agent_portrayal, 10, 10, 500, 500)
server = ModularServer(mainmodel,
                       [grid],
                       "Evolutionary Game Theory",
                       {"n1": 1, "n2": 1, "n3": 20, "width": 10, "height": 10})
server.port = 8521
server.launch()
