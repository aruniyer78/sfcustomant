package backup;
/*
 *  Daimler CRM - Extension Platform
 */

import java.util.List;


/**
 * TODO document class ChunkedExecutor
 *
 * @author  xlehmf
 */
public abstract class ChunkedExecutor<T, U, X extends Exception> {
  
  public final U execute(List<T> list, int chunkSize, U param) throws X {
    U result = param;
    int start = 0;
    while (start < list.size()) {
      result = chunky(list.subList(start, Math.min(start + chunkSize, list.size())), result);
      start += chunkSize;
    }
    
    return result;
  }
  
  public abstract U chunky(List<T> chunk, U result) throws X;
}
