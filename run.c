#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void initialize(int* resWidth, int* resHeight, float* resWeight, float** addrT) {
  float* resT;
  printf("width: \n");
  scanf("%d", resWidth);
  printf("height: \n");
  scanf("%d", resHeight);
  printf("weight:\n");
  scanf("%f", resWeight);

  int height = *resHeight;
  int width = *resWidth;


  resT = malloc((height * (width+2)) * sizeof(float));

  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      float scannedValue = 0;
      scanf("%f", &scannedValue);
      resT[i * height + j] = scannedValue;
    }
  }

  memset(resT+(height*width), 0, height*2); // 2 additional rows for temporary values during the flow
  
  *addrT = resT;
}

float* initialize_step(int size) {
  float* arr = malloc(size * sizeof(float));

  srand48(time(NULL));

  for (int i = 0; i < size; i++) {
    arr[i] = (float) drand48() * 10;
  }

  return arr;
}

void print_T(int height, int width, float* T) {
  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      printf("%f ", T[i * width + j]);
    }
    printf("\n");
  }
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < height; j++) {
      printf("%f ", T[width * height + height * i + j]);
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
    printf("width && height must be > 1");
    return 0;
  }

  float* step_array = initialize_step(height);

  printf("values array addr: %p\n", T);
  printf("values array addr first temp: %p\n", T + height * width * 4);
  printf("values array addr first temp: %p\n", T + height * (width+1) * 4);
  printf("step array addr: %p\n", step_array);

  start(width, height, T, weight);
  step(step_array);

  print_T(height, width, T);

  return 0;
}
