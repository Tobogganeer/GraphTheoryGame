class Edge
{
  float cost;
  Node nodeA;
  Node nodeB;

  public Edge(float cost, Node a, Node b)
  {
    this.cost = cost;
    this.nodeA = a;
    this.nodeB = b;
  }

  boolean touchesNode(Node node)
  {
    return node == nodeA || node == nodeB;
  }

  boolean connectsNodes(Node a, Node b)
  {
    return touchesNode(a) && touchesNode(b);
  }
}
