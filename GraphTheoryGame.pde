
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

  final float outerPush = 170f;
  final float innerPush = 80f;
  final float horizontalPushMult = 1.3f;
  final float minSpacing = 50f;

  // Calculate nodes for the 2 rings
  int outerNodes = numNodes / 2;
  int innerNodes = numNodes - outerNodes;

  // Generate rings
  for (int i = 0; i < outerNodes; i++)
    generateRingNode(outerPush, horizontalPushMult);
  for (int i = 0; i < innerNodes; i++)
    generateRingNode(innerPush, horizontalPushMult);

  // Start + end
  generateStartAndEnd();

  // Make sure they are spread out
  spaceAllNodes(minSpacing);
}



void generateRingNode(float push, float horizontalMult)
{
  float x = random(-push, push) * horizontalMult;
  float y = random(-push, push);
  x += width / 2f;
  y += height / 2f;
  new Node(x, y);
}

void generateStartAndEnd()
{
  // Find edges of node bounds
  Node leftNode = Node.all.get(0), rightNode = Node.all.get(0);
  float minX = width, maxX = 0;
  for (Node n : Node.all)
  {
    if (n.position.x < minX)
    {
      leftNode = n;
      minX = n.position.x;
    } else if (n.position.x > maxX)
    {
      rightNode = n;
      maxX = n.position.x;
    }
  }

  // Random Y offsets for start and end
  float startY = random(-30f, 30f);
  float endY = random(-30f, 30f);

  // Create nodes slightly past edge nodes
  startNode = new Node(leftNode.position.copy().add(new PVector(-60, startY)));
  endNode = new Node(rightNode.position.copy().add(new PVector(60, endY)));
}

void spaceAllNodes(float minSpacing)
{
  // Should be more than enough
  final int iterations = 20;
  for (int i = 0; i < iterations; i++)
  {
    for (Node a : getShuffledNodeList())
    {
      for (Node b : getShuffledNodeList())
      {
        // Don't check against ourselves
        if (a == b)
          continue;
        // Far away enough, move along
        if (a.position.dist(b.position) > minSpacing - 0.1f)
          continue;

        PVector offset = a.position.copy().sub(b.position);
        float currentDist = offset.mag();
        offset.normalize();
        float neededSeperation = minSpacing - currentDist;
        offset.mult(neededSeperation / 2f); // Will be applied to both, halve needed "push"
        // Push them apart
        a.position.add(offset);
        b.position.sub(offset);
      }
    }
  }
}

// https://stackoverflow.com/questions/1519736/random-shuffling-of-an-array
ArrayList<Node> getShuffledNodeList()
{
  int index;
  ArrayList<Node> nodes = new ArrayList<Node>();
  for (int i = Node.all.size() - 1; i > 0; i--)
  {
    index = int(random(i + 1));
    nodes.add(Node.all.get(index));
  }
  
  return nodes;
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
