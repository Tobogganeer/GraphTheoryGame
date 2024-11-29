import java.util.HashMap;
import java.util.ArrayList;

// Dijkstra's Algorithm
// Referenced from https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm

static class Pathfinding
{
  public static Path findPath(Node from, Node to)
  {
  }
}

static class Path
{
  ArrayList<Node> nodes;

  public Path(ArrayList<Node> nodes)
  {
    this.nodes = nodes;
  }

  public boolean equalTo(Path other)
  {
    if (nodes.size() != other.nodes.size())
      return false;

    for (int i = 0; i < nodes.size(); i++)
    {
      if (nodes.get(i) != other.nodes.get(i))
        return false;
    }

    return true;
  }
}
