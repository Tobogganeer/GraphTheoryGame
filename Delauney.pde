// https://en.wikipedia.org/wiki/Bowyer%E2%80%93Watson_algorithm
import java.util.ArrayList;

static class Delauney
{
}

static class Triangle
{
  Node a, b, c;
  
  public Triangle(Node a, Node b, Node c)
  {
   this.a = a;
   this.b = b;
   this.c = c;
   new Edge(0, a, b);
   new Edge(0, b, c);
   new Edge(0, c, a);
  }

  ArrayList<Edge> getEdges()
  {
    ArrayList edges = new ArrayList<Edge>();
    edges.add(Edge.get(a, b));
    edges.add(Edge.get(b, c));
    edges.add(Edge.get(c, a));
    return edges;
  }
}
