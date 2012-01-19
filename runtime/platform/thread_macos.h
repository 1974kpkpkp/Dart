// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef PLATFORM_THREAD_MACOS_H_
#define PLATFORM_THREAD_MACOS_H_

#if !defined(PLATFORM_THREAD_H_)
#error Do not include thread_macos.h directly; use thread.h instead.
#endif

#include <pthread.h>

#include "platform/globals.h"

namespace dart {

class ThreadData {
 private:
  ThreadData() {}
  ~ThreadData() {}

  pthread_t* tid() { return &tid_; }

  pthread_t tid_;

  friend class Thread;

  DISALLOW_ALLOCATION();
  DISALLOW_COPY_AND_ASSIGN(ThreadData);
};


class MutexData {
 private:
  MutexData() {}
  ~MutexData() {}

  pthread_mutex_t* mutex() { return &mutex_; }

  pthread_mutex_t mutex_;

  friend class Mutex;

  DISALLOW_ALLOCATION();
  DISALLOW_COPY_AND_ASSIGN(MutexData);
};


class MonitorData {
 private:
  MonitorData() {}
  ~MonitorData() {}

  pthread_mutex_t* mutex() { return &mutex_; }
  pthread_cond_t* cond() { return &cond_; }

  pthread_mutex_t mutex_;
  pthread_cond_t cond_;

  friend class Monitor;

  DISALLOW_ALLOCATION();
  DISALLOW_COPY_AND_ASSIGN(MonitorData);
};

}  // namespace dart

#endif  // PLATFORM_THREAD_MACOS_H_
