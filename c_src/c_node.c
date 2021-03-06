#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>
#include <opencv/cv.h>
#include <opencv/highgui.h>
#include "erl_interface.h"
#include "ei.h"

#define NUM_THREADS 10

typedef unsigned char byte;

CvMat* img(IplImage *source) {
  int width = 200;
  int height = (width * (source->height)) / (source->width);
  int param[3] = {CV_IMWRITE_PNG_COMPRESSION, 3, 0};
  IplImage *destination = cvCreateImage(
      cvSize( width, height ),
      source->depth, source->nChannels );
  cvResize( source, destination, CV_INTER_AREA );
  return cvEncodeImage(".png", destination, param );
}

void * handle_command(void *buf){
  ETERM *tuplep, *file;
  ETERM *fnp;
  tuplep = erl_decode(buf);
  fnp = erl_element(1, tuplep);
  char * path = "./priv/sample_images/ABST.00000000.tif";
  IplImage *source = cvLoadImage( path, CV_LOAD_IMAGE_GRAYSCALE );
  CvMat* pngImage = img(source);

  //if (strncmp(ERL_ATOM_PTR(fnp), "img", 3) == 0) {
    // no-op for now?
  //}

  file = erl_mk_binary((char *)pngImage->data.ptr, pngImage->cols);
  erl_encode(file, buf);
  write_cmd(buf, erl_term_len(file));

  erl_free_compound(tuplep);
  erl_free_term(fnp);
  erl_free_term(file);
}

void clear_active_threads(pthread_t *threads, int active_thread_count) {
  int rc, i;
  for(i = 0; i < active_thread_count - 1; ++i){
    rc = pthread_join(threads[i], NULL);
    //assert(0 == rc);
  }
}

int main() {
  int num_threads = 200;
  pthread_t threads[num_threads];
  int active_thread_count = 0;

  byte buf[1000000];
  erl_init(NULL, 0);

  while (read_cmd(buf) > 0) {
    if(active_thread_count == num_threads){
      clear_active_threads(threads, active_thread_count);
      active_thread_count = 0;
    }
    handle_command(buf);
    active_thread_count = active_thread_count + 1;
  }
  clear_active_threads(threads, active_thread_count);

  return 0;
}
