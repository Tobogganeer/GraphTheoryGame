// https://en.wikipedia.org/wiki/Bowyer%E2%80%93Watson_algorithm
import java.util.ArrayList;

static class Delauney
{
  public ArrayList<Triangle> triangulateCurrentNodes()
  {
    ArrayList<Triangle> triangles = new ArrayList<Triangle>();
    ArrayList<TriangleEdge> edges = new ArrayList<TriangleEdge>();
    Node stA, stB, stC; // Store super triangle nodes so we can delete them later

    // https://bit-101.com/blog/posts/2024-02-11/supertriangle/
    // Calculate bounds of all nodes
    float minX = Node.all.get(0).position.x;
    float minY = Node.all.get(0).position.y;
    float maxX = minX;
    float maxY = minY;
    for (int i = 0; i < Node.all.size(); i++)
    {
      Node n = Node.all.get(i);
      if (n.position.x < minX) minX = n.position.x;
      if (n.position.y < minY) minY = n.position.y;
      if (n.position.x > maxX) maxX = n.position.x;
      if (n.position.y > maxY) maxY = n.position.y;
    }

    return triangles;
  }
}

static class Triangle
{
  Node a, b, c;

  public Triangle(Node a, Node b, Node c)
  {
    this.a = a;
    this.b = b;
    this.c = c;
    //new Edge(0, a, b);
    //new Edge(0, b, c);
    //new Edge(0, c, a);
  }

  /*
  ArrayList<Edge> getEdges()
   {
   ArrayList edges = new ArrayList<Edge>();
   edges.add(Edge.get(a, b));
   edges.add(Edge.get(b, c));
   edges.add(Edge.get(c, a));
   return edges;
   }
   */
}

// Store edges without messing with global Edge list
static class TriangleEdge
{
  Node a, b;

  public TriangleEdge(Node a, Node b)
  {
    this.a = a;
    this.b = b;
  }

  boolean equalTo(TriangleEdge other)
  {
    return (a == other.a && b == other.b) || (a == other.b && b == other.a);
  }
}
