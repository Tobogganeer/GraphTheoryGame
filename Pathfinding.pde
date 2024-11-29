import java.util.HashMap;
import java.util.ArrayList;

// Dijkstra's Algorithm
// Referenced from https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm

static class Pathfinding
{
  public static Path findPath(Node from, Node to)
  {
    HashMap<Node, Integer> distances = new HashMap<Node, Integer>();
    HashMap<Node, Node> previousNodes = new HashMap<Node, Node>();
    ArrayList<Node> unvisited = new ArrayList<Node>();

    for (Node n : Node.all)
    {
      distances.put(n, 10000);
      unvisited.add(n);
    }

    // Starting node has a distance of 0
    distances.put(from, 0);

    while (unvisited.size() > 0)
    {
      Node newNode = getLowestCostNode(unvisited, distances);

      // Found target node
      if (newNode == to)
      {
        ArrayList<Node> path = new ArrayList<Node>();
        if (previousNodes.containsKey(newNode) || from == to)
        {
          while (newNode != null)
          {
            // Add previous step and keep going
            path.add(0, newNode);
            newNode = previousNodes.getOrDefault(newNode, null);
          }

          return new Path(path);
        }
      }

      unvisited.remove(newNode);

      ArrayList<Node> neighbours = newNode.getAllNeighbours();

      for (Node neighbour : neighbours)
      {
        if (!unvisited.contains(neighbour))
          continue; // Keep going if we've already calculated this neighbour
        int newLength = distances.get(newNode) + Edge.get(newNode, neighbour).cost;
        // Found shorter path to neighbour
        if (newLength < distances.get(neighbour))
        {
          // Set this node as path leading to neighbour
          distances.put(neighbour, newLength);
          previousNodes.put(neighbour, newNode);
        }
      }
    }
  }

  static Node getLowestCostNode(ArrayList<Node> nodes, HashMap<Node, Integer> costs)
  {
    Node node = nodes.get(0);
    int cost = costs.get(node);
    for (Node n : nodes)
    {
      // Cache for perf
      int newNodeCost = costs.get(n);
      if (costs.get(n) < cost)
      {
        node = n;
        cost = newNodeCost;
      }
    }

    return node;
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
