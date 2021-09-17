import yaml 
import pprint 
import sys 

data = yaml.load(sys.stdin.read(), Loader=yaml.Loader)
pprint.pprint(data, compact=False)


