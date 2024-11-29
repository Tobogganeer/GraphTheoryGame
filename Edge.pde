import java.util.ArrayList;

static class Edge
{
  static ArrayList<Edge> all = new ArrayList<Edge>();

  public int cost;
  Node nodeA;
  Node nodeB;

  public Edge(int cost, Node a, Node b)
  {
    this.cost = cost;
    this.nodeA = a;
    this.nodeB = b;

    all.add(this);
  }

  public void destroy()
  {
    all.remove(this);
  }

  boolean touchesNode(Node node)
  {
    return node == nodeA || node == nodeB;
  }

  boolean connectsNodes(Node a, Node b)
  {
    return touchesNode(a) && touchesNode(b);
  }

  Node getOtherNode(Node notThisOne)
  {
    if (nodeA == notThisOne)
      return nodeB;
    return nodeA;
  }
  
  static Edge get(Node a, Node b)
  {
    for (Edge e : Edge.all)
    {
      if (e.connectsNodes(a, b))
        return e;
    }
    
    return null;
  }
  
  void draw()
  {
    Draw.start();
    
    Applet.get().stroke(#4253E3);
    Applet.get().strokeWeight(5);
    Applet.get().line(nodeA.position.x, nodeA.position.y, nodeB.position.x, nodeB.position.y);
    
    Draw.end();
  }
}
