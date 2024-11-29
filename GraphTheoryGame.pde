
Node startNode;
Node endNode;

void setup() {
  size(800, 600);
  noStroke();
  fill(0);

  Applet.init(this);

  generateMap(10);

  /*
  Node nodeA = new Node(100, 100);
   Node nodeB = new Node(200, 100);
   Node nodeC = new Node(200, 200);
   Node nodeD = new Node(300, 150);
   
   new Edge(2, nodeA, nodeB);
   new Edge(1, nodeA, nodeC);
   new Edge(3, nodeB, nodeC);
   new Edge(2, nodeC, nodeD);
   new Edge(4, nodeD, nodeB);
   */
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
 - Generate [2] rings of nodes - push them out random amounts (outside circle pushed farther)
 - Find farthest left node, add start node to left
 - Find farthest right node, add end node to right
 - For each node:
 - Choose random number of edges to connect (2-4, bias towards 2-3)
 - Connect to closest neighbouring nodes
 - Select random number of edges (1-5) and delete them randomly
 - Ensure a path is still possible after checking each deletion
 
 */
void generateMap(int numNodes)
{
  Node.all.clear();
  Edge.all.clear();

  final float outerPush = 150f;
  final float innerPush = 80f;
  final float horizontalPushMult = 1.3f;
  final float minSpacing = 30f;

  // Calculate nodes for the 2 rings
  int outerNodes = numNodes / 2;
  int innerNodes = numNodes - outerNodes;

  for (int i = 0; i < outerNodes; i++)
    generateRingNode(outerPush, horizontalPushMult);
  for (int i = 0; i < innerNodes; i++)
    generateRingNode(innerPush, horizontalPushMult);
}



Node generateRingNode(float push, float horizontalMult)
{
  float x = random(-push, push) * horizontalMult;
  float y = random(-push, push);
  x += width / 2f;
  y += height / 2f;
  return new Node(x, y);
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
