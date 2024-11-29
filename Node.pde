//import java.util.HashMap;
import java.util.ArrayList;

static class Node
{
  //static int nextId;
  //static HashMap<Integer, Node> all = new HashMap<Integer, Node>();
  static ArrayList<Node> all = new ArrayList<Node>();

  //int id;
  public PVector position;

  public Node(PVector position)
  {
    this.position = position.copy();
    all.add(this);
    //id = nextId++;
    //all.put(id, this);
  }
  
  public Node(float x, float y)
  {
    this(new PVector(x, y));
  }

  boolean connectedWith(Node other)
  {
    for (Edge e : Edge.all)
    {
      if (e.connectsNodes(this, other))
        return true;
    }

    return false;
  }

  Edge getEdge(Node other)
  {
    for (Edge e : Edge.all)
    {
      if (e.connectsNodes(this, other))
        return e;
    }

    return null;
  }

  ArrayList<Edge> getAllEdges()
  {
    ArrayList<Edge> edges = new ArrayList<Edge>();
    for (Edge e : Edge.all)
    {
      if (e.touchesNode(this))
        edges.add(e);
    }

    return edges;
  }

  ArrayList<Node> getAllNeighbours()
  {
    ArrayList<Node> neighbours = new ArrayList<Node>();

    for (Edge e : getAllEdges())
      neighbours.add(e.getOtherNode(this));

    return neighbours;
  }
  
  void draw()
  {
    Draw.start();
    
    final float diameter = 10;
    
    Applet.get().fill(#4253E3);
    Applet.get().ellipse(position.x, position.y, diameter, diameter);
    
    Draw.end();
  }
}
