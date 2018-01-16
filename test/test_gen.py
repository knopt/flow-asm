import sys
import os
from random import uniform, randint

MAX_DIM = 20
MAX_NUMBER = 2
MAX_STEPS = 4

EX_NUM = 200

for i in range(EX_NUM):
  height = randint(1, MAX_DIM)
  width = randint(1, MAX_DIM)
  weight = uniform(-MAX_NUMBER, MAX_NUMBER)
  steps = randint(1, MAX_STEPS)

  array = [
    [uniform(-MAX_NUMBER, MAX_NUMBER) for x in range(height)]
    for y in range(width)
  ]

  step_array = [uniform(-MAX_NUMBER, MAX_NUMBER) for x in range(height)]

  if not os.path.exists('ex'):
    os.makedirs('ex')


  with open('ex/{}.in'.format(i), 'w') as f:
    f.write("{}\n".format(width))
    f.write("{}\n".format(height))
    f.write("{}\n".format(weight))

    for h in range(height):
      for w in range(width):
        f.write("{} ".format(array[w][h]))
      f.write("\n")
    f.write("\n");

    f.write("{}\n".format(steps))

    for h in range(height):
      f.write("{} ".format(step_array[h]))

    f.write("\n")


  with open('ex/{}.out'.format(i), 'w') as f:
    for s_num in range(steps):
      old_left = list(step_array)
      old_middle = list(array[0])
      for w in range(width):
        for h in range(height):
          neighbours_sum = 0

          if h > 0:
            neighbours_sum += old_left[h-1] + old_middle[h-1] - (2*old_middle[h])

          if h < height - 1:
            neighbours_sum += old_left[h+1] + old_middle[h+1] - (2*old_middle[h])

          neighbours_sum += old_left[h] - old_middle[h]
          neighbours_sum *= weight

          array[w][h] += neighbours_sum

        if w < width - 1:
          old_left = list(old_middle)
          old_middle = list(array[w + 1])

      for h in range(height):
        for w in range(width):
          f.write("{} ".format(array[w][h]))
        f.write("\n")


  
