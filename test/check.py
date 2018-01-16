import subprocess
import fnmatch
import os
import numpy as np

EXEC_PATH='../run'

PRECISION=2

passed = 0
failed = 0

for in_file_name in sorted(os.listdir('ex')):
  if fnmatch.fnmatch(in_file_name, '*.in'):
    no_ext = os.path.splitext(os.path.basename(in_file_name))[0]
    no_ext = str(no_ext)

    command = EXEC_PATH

    with open(os.path.join('ex', in_file_name), 'r') as in_file:
      with open(os.path.join('res', no_ext) + '.out', 'w') as out_file:      
        process = subprocess.Popen(command, shell=True, stdout=out_file, stdin=in_file)
        process.wait()

    with open(os.path.join('ex', no_ext) + '.out', 'r') as correct_file:
      with open(os.path.join('res', no_ext) + '.out', 'r') as checked_file:
        try:
            floats_correct = [[float(y.strip()) for y in x.split()] for x in correct_file.readlines()]
            floats_checked = [[float(y.strip()) for y in x.split()] for x in checked_file.readlines()]
            correct = np.array(floats_correct, dtype=np.float32)
            checked = np.array(floats_checked, dtype=np.float32)
        except Exception as e:
          failed += 1
          print("[ERR] Exception for checking file {}. {}".format(no_ext, e))
          continue

        try:
          np.testing.assert_array_almost_equal(correct, checked, decimal=2)
        except AssertionError as e:
          failed += 1
          print("[ERR] Arrays not equal! {}".format(e))
          continue

        passed += 1
        print("[OK] {}".format(no_ext))

        
if failed == 0:
  print("All {} test passed".format(passed))
else:
  print("ERROR: {} not passed".format(failed))
