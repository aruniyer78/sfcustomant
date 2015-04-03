/*
 * Daimler CRM - Extension Platform
 */
package task.handler;

import org.apache.tools.ant.Task;

/**
 * LogWrapper
 *
 * @author  XLEHMF
 */
public class LogWrapper
{

  private final Task task;

  public LogWrapper(Task task)
  {
    this.task = task;
  }

  public void log(String msg, Throwable t, int level)
  {
    task.log(msg, t, level);
  }

  public void log(String msg, int level)
  {
    task.log(msg, level);
  }

  public void log(String msg)
  {
    task.log(msg);
  }

}
