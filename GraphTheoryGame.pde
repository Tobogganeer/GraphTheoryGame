
void setup() {
  size(800, 600);
  noStroke();
  fill(0);
  
  Applet.init(this);

  Node nodeA = new Node(100, 100);
  Node nodeB = new Node(200, 100);
  Node nodeC = new Node(200, 200);
  Node nodeD = new Node(300, 150);
  
  new Edge(2, nodeA, nodeB);
  new Edge(1, nodeA, nodeC);
  new Edge(3, nodeB, nodeC);
  new Edge(2, nodeC, nodeD);
  new Edge(4, nodeD, nodeB);
}

void draw() {
  background(255);
  //textSize(20);
  //text("Hi!", 200, 200);
  
  drawNodes();
  drawEdges();
}

/*

Map generation idea:
- Generate [2] circles of points - push them out random amounts (outside circle pushed farther)
- Find farthest left node, add start node to left
- Find farthest right node, add end node to right
- For each node:
  - Choose random number of edges to connect (2-4, bias towards 2-3)
  - Connect to closest neighbouring nodes
- Select random number of edges (1-5) and delete them randomly
  - Ensure a path is still possible after checking each deletion

*/
void generateMap(float padding, int numNodes)
{
  
}

void drawNodes()
{
  for (Node n : Node.all)
    n.draw();
}

void drawEdges()
{
  // TODO: Highlighting/colours
  for (Edge e : Edge.all)
    e.draw();
}
