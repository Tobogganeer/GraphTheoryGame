import java.util.ArrayList;

static class Edge
{
  static ArrayList<Edge> all = new ArrayList<Edge>();
  
  static int currentMinCost, currentMaxCost; // Used for colouring

  public int cost;
  Node nodeA;
  Node nodeB;
  
  PVector midPoint;
  Rect costRect;

  public Edge(int cost, Node a, Node b)
  {
    this.cost = cost;
    this.nodeA = a;
    this.nodeB = b;
    calculateMidpoint();
  }
  
  void calculateMidpoint()
  {
    midPoint = PVector.lerp(nodeA.position, nodeB.position, 0.5f);
    costRect = Rect.center(midPoint.x, midPoint.y, 12, 16);
  }

  public void tryAdd()
  {
    for (Edge e : all)
      if (e.equalTo(this))
        return;
    all.add(this);
  }

  public void forceAdd()
  {
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

  boolean equalTo(Edge other)
  {
    return other.connectsNodes(nodeA, nodeB);
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

    PApplet app = Applet.get();

    app.stroke(#4253E3);
    app.strokeWeight(3);
    app.line(nodeA.position.x, nodeA.position.y, nodeB.position.x, nodeB.position.y);
    
    app.fill(255);
    app.strokeWeight(2);
    
    app.stroke(app.lerpColor(#68E860, #F5395B, (cost - currentMinCost) / (float)(currentMaxCost - currentMinCost)));
    costRect.draw(5);
    
    app.textAlign(CENTER, CENTER);
    app.fill(0);
    app.text(cost, midPoint.x, midPoint.y);

    Draw.end();
  }
}
