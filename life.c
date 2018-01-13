#include <stdio.h>
#include <stdlib.h>

// C functions, to show how assembler funtions are implemented

char* globalT;
int globalWidth;
int globalHeight;

const int REINCARNATE = 3;
const int MIN_STAY_ALIVE = 2;
const int MAX_STAY_ALIVE = 3;

void initialize(int* resWidth, int* resHeight, int* step_number, char** addrT) {
  char* resT;
  printf("number of steps:\n");
  scanf("%d", step_number);
  printf("width: \n");
  scanf("%d", resWidth);
  printf("height: \n");
  scanf("%d", resHeight);

  int height = *resHeight;
  int width = *resWidth;

  resT = malloc(height * width * sizeof(char));

  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      int scannedValue = 0;
      scanf("%d", &scannedValue);
      if (scannedValue > 0) {
        resT[i * width + j] = (char) 1;
      } else {
        resT[i * width + j] = (char) 0;
      }
    }
  }
  
  *addrT = resT;
}

void start_C(int width, int height, char* T) {
  globalHeight = height;
  globalWidth = width;
  globalT = T;
  return;
}

void move_all_t_bits_left_C() {
  for (int i = 0; i < globalHeight; i++) {
    for (int j = 0; j < globalWidth; j++) {
      globalT[i * globalWidth + j] <<= 1;
    }
  }
}

int get_new_value_C(int index, int n_sum) {
  return ((globalT[index] >> 1 & 1) && (n_sum <= MAX_STAY_ALIVE || n_sum >= MIN_STAY_ALIVE)) || ((globalT[index] >> 1 ^ 1) && n_sum == 3);
}

int get_cell_neighbours_value_C(int col, int row) {
  int n_value = 0;

  for (int h = -1; h <= 1; h++) {
    for (int w = -1; w <= 1; w++) {
      int w_index = w + col;
      int h_index = h + row;
      if ((w_index < 0 || w_index >= globalWidth) || (h_index < 0 || h_index >= globalHeight) || (w == 0 && h == 0)) {
        continue;
      }
      n_value += globalT[globalWidth * h_index + w_index] >> 1 & 1;
    }
  }

  return n_value;
}

void run_one_step_C() {  
  for (int i = 0; i < globalHeight; i++) {
    for (int j = 0; j < globalWidth; j++) {
      int value = get_cell_neighbours_value_C(j, i);
      int position = i * globalWidth + j;
      int new_value = get_new_value_C(position, value);
      globalT[position] |= new_value;
    }
  }

}

void run_C(int steps_num) {
  for (int i = 0; i < steps_num; i++) {
    move_all_t_bits_left_C();
    run_one_step_C();
  }
  return;
}

void print_T(int height, int width, char* T) {
  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      printf("%d ", T[i * width + j] & 1);
    }
    printf("\n");
  }
}

// assembler functions
extern void start(int width, int height, char* T);
extern void run(float* S);

int main() {
  int width = 0;
  int height = 0;
  int step_number = 0;
  char* T = malloc(sizeof(char*));

  initialize(&width, &height, &step_number, &T);

  if (width < 1 || height < 1) {
    printf("width && height must be > 1");
    return 0;
  }

  start(width, height, T);
  run(step_number);
  print_T(height, width, T);

  return 0;
}
