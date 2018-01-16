#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void initialize(int* resWidth, int* resHeight, float* resWeight, float** addrT) {
  float* resT;
  scanf("%d", resWidth);
  scanf("%d", resHeight);
  scanf("%f", resWeight);

  int height = *resHeight;
  int width = *resWidth;

  resT = malloc((height * (width+2)) * sizeof(float));

  for (int j = 0; j < height; j++) {
    for (int i = 0; i < width; i++) {
      float scannedValue = 0;
      scanf("%f", &scannedValue);
      resT[i * height + j] = scannedValue;
    }
  }

  // 2 additional rows for temporary values during the flow
  // possibly could have been done in assembly, but it's fine
  memset(resT+(height*width), 0, height*2); 
  
  *addrT = resT;
}

float* initialize_step_stdin(int size) {
  float* arr = malloc(size * sizeof(float));

  for (int i = 0; i < size; i++) {
    scanf("%f", arr + i);
  }

  return arr;
}

void print_T(int height, int width, float* T) {
  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      printf("%f ", T[j * height + i]);
    }
    printf("\n");
  }
}

extern void start(int width, int height, float *M, float weight);
extern void step(float *M);

int main() {
  int width = 0;
  int height = 0;
  float weight = 0.0;
  float* T = malloc(sizeof(float*));

  initialize(&width, &height, &weight, &T);

  if (width < 1 || height < 1) {
    printf("width && height must be >= 1");
    return 1;
  }

  int steps = 0;
  scanf("%d", &steps);

  float* step_array = initialize_step_stdin(height);

  start(width, height, T, weight);

  for (int i = 0; i < steps; i++) {
    step(step_array);
    print_T(height, width, T);
  }


  return 0;
}
