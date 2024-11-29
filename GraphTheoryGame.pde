
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
