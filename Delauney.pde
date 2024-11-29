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
    
    // Calculate width and height
    float w = maxX - minX;
    float h = maxY - minY;
    // Add nodes to the left of bounds, plus one to the right
    // See bit-101 link above
    stA = new Node(minX - w * 0.1, minY - h);
    stB = new Node(minX - w * 0.1, minY + h * 2);
    stC = new Node(minX + w * 1.7, minY + h * 0.5f);
    
    // Add super triangle
    triangles.add(new Triangle(stA, stB, stC));
    
    for (Node node : Node.all)
    {
      ArrayList<Triangle> badTriangles = new ArrayList<Triangle>();
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
  
  boolean isNodeInsideCircumcircle(Node node)
  {
    // https://www.kristakingmath.com/blog/circumscribed-and-inscribed-circles-of-triangles
    // Calculate directions of bisectors for 2 edges
    PVector dirA = b.position.copy().sub(a.position).normalize(); // Dir from a to b
    PVector dirB = b.position.copy().sub(c.position).normalize(); // Dir from c to b
    
    PVector bisectorDirA = new PVector(dirA.y, -dirA.x);
    PVector bisectorDirB = new PVector(dirB.y, -dirB.x);
    
    PVector midpointA = PVector.lerp(a.position, b.position, 0.5f);
    PVector midpointB = PVector.lerp(c.position, b.position, 0.5f);
    
    // Have points and direction, re-arrange to linear form y = mx + b
    // b = y - mx (we have x, y, and can get slope from bisector dir)
    
    float slopeA = bisectorDirA.y / bisectorDirA.x;
    float slopeB = bisectorDirB.y / bisectorDirB.x;
    
    // y = midpoint.y, x = midpoint.x, m = slope
    float interceptA = midpointA.y - (slopeA * midpointA.x);
    float interceptB = midpointB.y - (slopeB * midpointB.x);
    
    // y = mx + b for both lines
    // When intersecting, both y's are the same
    // Therefore m1x1 + b1 = m2x2 + b2
    // m1x1 - m2x2 = b2 - b1
    // x = (b2 - b1) / (m1 - m2)
    float xIntercept = interceptB - interceptA / slopeA - slopeB;
    float yIntercept = slopeA * midpointA.x + interceptB; // mx + b
    
    // Huzzah at long last
    PVector circumcenter = new PVector(xIntercept, yIntercept);
    float circumcircleRadius = PVector.dist(circumcenter, a.position); // Dist to any original vertex
    
    return node.position.dist(circumcenter) < circumcircleRadius;
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
