import sys
from random import random, randint

MAX_DIM = 20
MAX_NUMBER = 1000

for i in range(20):
  height = randint(0, MAX_DIM)
  width = randint(0, MAX_DIM)

  array = [
    [random() * MAX_NUMBER for x in range(height)]
    for y in range(width)
  ]

  print(array)

  step_array = [random() * MAX_NUMBER for x in range(height)]

  