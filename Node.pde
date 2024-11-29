//import java.util.HashMap;
import java.util.ArrayList;

static class Node
{
  //static int nextId;
  //static HashMap<Integer, Node> all = new HashMap<Integer, Node>();
  static ArrayList<Node> all = new ArrayList<Node>();

  //int id;
  PVector position;

  public Node(PVector position)
  {
    this.position = position.copy();
    all.add(this);
    //id = nextId++;
    //all.put(id, this);
  }
}
