import java.util.HashMap;

static class Node
{
  static int nextId;
  static HashMap<Integer, Node> all = new HashMap<Integer, Node>();

  int id;
  PVector position;

  public Node(PVector position)
  {
    this.position = position.copy();
    id = nextId++;
    all.put(id, this);
  }
}
