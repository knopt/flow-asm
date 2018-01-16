Tomasz Knopik, Assembly Assignment 2

>Our goal is to write functions simulating fictional flow of some pseudophysical property (with values from the domain of real numbers) along rectangular net. To make discussion easier we will call this property pollution (ecology is trendy).
>
>We are given rectangular net in the form of two-dimensional matrix (of course a program depending on its needs could store matrix contents in a different form, but we talk about external, ``logical'' representation). Each cell stores the current value of pollution it its vicinity.
>
>We assume that the direction of the flow of control is from left to right. Simulation will be performed in steps. In each step, at the left border of the net, new input values of pollution will enter the net. In all other places the change of values is determined by concurrent computation of increment (``delta'') based on values of neighboring cells from the previous step. We allow negative increments.

### Build
```
$ make
```

### Run
```
$ ./run
```
Then you have to provide:
-width (int)
-height (int)
-weight (float)
-array (float)
-steps number (int)
-initial step values array (float)

### Test
Create venv in test/ directory and install requirements
```
$ cd test
$ source venv/bin/activate
$ python test_gen.py
$ python check.py
``` 
