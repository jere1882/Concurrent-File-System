// https://code.google.com/p/c-pthread-queue/source/browse/trunk/queue.h
/*
c-pthread-queue - c implementation of a bounded buffer queue using posix threads
Copyright (C) 2008  Matthew Dickinson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <pthread.h>
#include <stdio.h>

#ifndef _QUEUE_H
#define _QUEUE_H

#define QUEUE_INITIALIZER(buffer) { buffer, sizeof(buffer) / sizeof(buffer[0]), 0, 0, 0, PTHREAD_MUTEX_INITIALIZER, PTHREAD_COND_INITIALIZER, PTHREAD_COND_INITIALIZER }

typedef struct queue_t
{
  void **buffer;
  int capacity;
  int size;
  int in;
  int out;
  pthread_mutex_t mutex;
  pthread_cond_t cond_full;
  pthread_cond_t cond_empty;
} queue;

queue * create_queue (void **buffer)
{
  queue *q = malloc (sizeof (queue));

  q->buffer     = buffer;
  q->capacity   = sizeof (buffer) / sizeof (buffer[0]);
  q->size       = 0;
  q->in         = 0;
  q->out        = 0;
  pthread_mutex_init (&q->mutex, NULL);
  pthread_cond_init (&q->cond_full, NULL);
  pthread_cond_init (&q->cond_empty, NULL);

  return q;
}

void enqueue (queue *queue, void *value)
{
  pthread_mutex_lock(&(queue->mutex));
  while (queue->size == queue->capacity)
    pthread_cond_wait(&(queue->cond_full), &(queue->mutex));
  // printf("Queue %d, enqueued %d\n", queue, *(int *)value);
  queue->buffer[queue->in] = value;
  ++ queue->size;
  ++ queue->in;
  queue->in %= queue->capacity;
  pthread_mutex_unlock(&(queue->mutex));
  pthread_cond_broadcast(&(queue->cond_empty));
}

void * dequeue (queue *queue)
{
  pthread_mutex_lock(&(queue->mutex));
  while (queue->size == 0)
    pthread_cond_wait(&(queue->cond_empty), &(queue->mutex));
  void *value = queue->buffer[queue->out];
  // printf("Queue %d, dequeue %d\n", queue, *(int *)value);
  -- queue->size;
  ++ queue->out;
  queue->out %= queue->capacity;
  pthread_mutex_unlock(&(queue->mutex));
  pthread_cond_broadcast(&(queue->cond_full));
  return value;
}

int queue_size (queue *queue)
{
  pthread_mutex_lock(&(queue->mutex));
  int size = queue->size;
  pthread_mutex_unlock(&(queue->mutex));
  return size;
}
// TODO: Maybe add a function to free queues.
#endif
