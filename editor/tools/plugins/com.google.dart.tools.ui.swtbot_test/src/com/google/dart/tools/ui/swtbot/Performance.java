/*
 * Copyright 2012 Dart project authors.
 * 
 * Licensed under the Eclipse Public License v1.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.google.dart.tools.ui.swtbot;

import org.eclipse.swtbot.eclipse.finder.SWTWorkbenchBot;
import org.eclipse.swtbot.swt.finder.SWTBot;
import org.eclipse.swtbot.swt.finder.waits.ICondition;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Comparator;

public class Performance {

  /**
   * Represents a named performance metric
   */
  public static class Metric {
    public final String name;
    public final long threshold;

    Metric(String name, long threshold) {
      this.name = name;
      this.threshold = threshold;
    }

    /**
     * Log the elapsed time
     * 
     * @param start the start time
     */
    public void log(long start, String... comments) {
      Result result = new Result(this, System.currentTimeMillis() - start, comments);
      result.print();
      synchronized (allResults) {
        allResults.add(result);
      }
    }

    /**
     * Log the elapsed time for the condition to become <code>true</code>. This operation blocks the
     * current thread.
     * 
     * @param condition the condition (not <code>null</code>)
     */
    public void log(SWTWorkbenchBot bot, ICondition condition, String... comments) {
      log(bot, System.currentTimeMillis(), condition, comments);
    }

    /**
     * Log the elapsed time for the condition to become <code>true</code>. This operation blocks the
     * current thread.
     * 
     * @param start the start time
     * @param condition the condition (not <code>null</code>)
     */
    public void log(SWTWorkbenchBot bot, long start, ICondition condition, String... comments) {
      bot.waitUntil(condition, 20000);
      log(start, comments);
    }

    /**
     * Log the elapsed time for the condition to become <code>true</code>. This operation runs in a
     * background thread and does not block the current thread.
     * 
     * @param condition the condition (not <code>null</code>)
     */
    public void logInBackground(ICondition condition, String... comments) {
      logInBackground(System.currentTimeMillis(), condition, comments);
    }

    /**
     * Log the elapsed time for the condition to become <code>true</code>. This operation runs in a
     * background thread and does not block the current thread.
     * 
     * @param start the start time
     * @param condition the condition (not <code>null</code>)
     */
    public void logInBackground(final long start, final ICondition condition,
        final String... comments) {
      synchronized (Performance.allResults) {
        Performance.pending++;
      }
      new Thread("Timing " + name) {
        @Override
        public void run() {
          long limit = System.currentTimeMillis() + 20000;
          Throwable exception = null;
          while (true) {
            try {
              if (condition.test()) {
                log(start, comments);
                break;
              }
            } catch (Throwable e) {
              exception = e;
              //$FALL-THROUGH$
            }
            try {
              Thread.sleep(100);
            } catch (InterruptedException e) {
              //$FALL-THROUGH$
            }
            if (System.currentTimeMillis() > limit) {
              String[] more = new String[comments.length + 1];
              System.arraycopy(comments, 0, more, 0, comments.length);
              more[comments.length] = exception != null ? exception.getMessage() : "<<< timed out";
              log(start, more);
              break;
            }
          }
          synchronized (Performance.allResults) {
            Performance.pending--;
          }
        };
      }.start();
    }
  }

  /**
   * Represents the result of executing a particular metric
   */
  private static class Result {
    private final Metric metric;
    private final long elapsed;
    private final String[] comments;

    Result(Metric metric, long elapsed, String... comments) {
      this.metric = metric;
      this.elapsed = elapsed;
      this.comments = comments;
    }

    /**
     * Log the elapsed time
     */
    void print() {
      StringBuilder line = new StringBuilder();
      appendText(line, 20, metric.name);
      appendLong(line, metric.threshold);
      line.append(" ms ");
      line.append(metric.threshold < elapsed ? '<' : ' ');
      appendLong(line, elapsed);
      line.append(" ms");
      for (String comment : comments) {
        line.append(", ");
        line.append(comment);
      }
      System.out.println(line.toString());
    }
  }

  public static final Metric NEW_APP = new Metric("New App", 300);
  public static final Metric LAUNCH_APP = new Metric("Launch App", 3000);
  public static final Metric COMPILE = new Metric("Compile", 3000);
  public static final Metric CODE_COMPLETION = new Metric("Code Completion", 200);
  public static final Metric COMPILER_WARMUP = new Metric("Compiler Warmup", 5000);

  private static final Collection<Result> allResults = new ArrayList<Performance.Result>(20);
  private static int pending = 0;

  /**
   * Echo the allResults to standard out.
   * 
   * @see #waitForResults(SWTWorkbenchBot)
   */
  public static void printResults() {
    System.out.println("=============================================================");
    Result[] sortedResults;
    synchronized (allResults) {
      sortedResults = allResults.toArray(new Result[allResults.size()]);
    }
    Arrays.sort(sortedResults, new Comparator<Result>() {
      @Override
      public int compare(Result r1, Result r2) {
        return r1.metric.name.compareTo(r2.metric.name);
      }
    });
    for (Result result : sortedResults) {
      result.print();
    }
  }

  /**
   * Wait for any timed background operations to complete
   */
  public static void waitForResults(SWTWorkbenchBot bot) {
    int timeout;
    synchronized (allResults) {
      if (pending < 1) {
        return;
      }
      timeout = 20000 * pending;
    }
    bot.waitUntil(new ICondition() {

      @Override
      public String getFailureMessage() {
        synchronized (Performance.allResults) {
          return "Gave up waiting for " + pending + " background operations";
        }
      }

      @Override
      public void init(SWTBot bot) {
      }

      @Override
      public boolean test() throws Exception {
        synchronized (Performance.allResults) {
          return pending == 0;
        }
      }
    }, timeout);
  }

  private static void appendLong(StringBuilder line, long num) {
    String text = Long.toString(num);
    appendSpaces(line, 7 - text.length());
    line.append(text);
  }

  private static void appendSpaces(StringBuilder line, int count) {
    for (int i = 0; i < count; i++) {
      line.append(' ');
    }
  }

  private static void appendText(StringBuilder line, int count, String text) {
    line.append(text);
    appendSpaces(line, count - text.length());
  }
}
