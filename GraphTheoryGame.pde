
Node startNode;
Node endNode;

void setup() {
  size(800, 600);
  noStroke();
  fill(0);

  Applet.init(this);

  generateMap(20);

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

  for (Triangle tri : debugDraw)
  {
    stroke(0);
    line(tri.a.position.x, tri.a.position.y, tri.b.position.x, tri.b.position.y);
    line(tri.b.position.x, tri.b.position.y, tri.c.position.x, tri.c.position.y);
    line(tri.c.position.x, tri.c.position.y, tri.a.position.x, tri.a.position.y);
    Circle circ = tri.getCircumcircle();
    ellipse(circ.center.x, circ.center.y, circ.radius / 2f, circ.radius / 2f);
  }

  Triangle tri = new Triangle(Node.all.get(3), Node.all.get(5), Node.all.get(7));
  line(tri.a.position.x, tri.a.position.y, tri.b.position.x, tri.b.position.y);
  line(tri.b.position.x, tri.b.position.y, tri.c.position.x, tri.c.position.y);
  line(tri.c.position.x, tri.c.position.y, tri.a.position.x, tri.a.position.y);
  Circle circ = tri.getCircumcircle();
  ellipse(circ.center.x, circ.center.y, circ.radius / 2f, circ.radius / 2f);
  println(circ.center);

  PVector dirA = tri.b.position.copy().sub(tri.a.position).normalize(); // Dir from a to b
  PVector dirB = tri.b.position.copy().sub(tri.c.position).normalize(); // Dir from c to b

  stroke(255, 0, 0);
  drawLine(tri.a.position, tri.a.position.copy().add(dirA.copy().mult(100)));

  PVector bisectorDirA = new PVector(dirA.y, -dirA.x);
  PVector bisectorDirB = new PVector(dirB.y, -dirB.x);

  PVector midpointA = PVector.lerp(tri.a.position, tri.b.position, 0.5f);
  PVector midpointB = PVector.lerp(tri.c.position, tri.b.position, 0.5f);
  
  stroke(0, 255, 0);
  drawLine(midpointA, midpointA.copy().add(bisectorDirA.copy().mult(100)));
  drawLine(midpointB, midpointB.copy().add(bisectorDirB.copy().mult(100)));


  // Have points and direction, re-arrange to linear form y = mx + b
  // b = y - mx (we have x, y, and can get slope from bisector dir)

  float slopeA = bisectorDirA.y / bisectorDirA.x;
  float slopeB = bisectorDirB.y / bisectorDirB.x;
  
  println("A: " + slopeA + " - B: " + slopeB);
  //float slopeA = -(1f / ((b.position.y - a.position.y) / (b.position.x - a.position.x)));
  //float slopeB = -(1f / ((b.position.y - c.position.y) / (b.position.x - c.position.x)));

  // y = mx + b
  // midpoint.y = slope * midpoint.x + b
  // b = midpoint.y - slope * midpoint.x

  // y = midpoint.y, x = midpoint.x, m = slope
  float interceptA = midpointA.y - (slopeA * midpointA.x);
  float interceptB = midpointB.y - (slopeB * midpointB.x);
  
  float xIntercept = (interceptB - interceptA) / (slopeA - slopeB);
  float yIntercept = slopeA * xIntercept + interceptA; // mx + b
  
  ellipse(xIntercept, yIntercept, 20, 20);
}

void drawLine(PVector a, PVector b)
{
  line(a.x, a.y, b.x, b.y);
}

/*
 Map generation idea:
 - Generate [2] rings of nodes - push them out random amounts (outside circle pushed farther)
 - Find farthest left node, add start node to left
 - Find farthest right node, add end node to right
 - For each node:
 *   Choose random number of edges to connect (2-4, bias towards 2-3)
 *   Connect to closest neighbouring nodes
 - Select random number of edges (1-5) and delete them randomly
 *   Ensure a path is still possible after checking each deletion
 */
void generateMap(int numNodes)
{
  Node.all.clear();
  Edge.all.clear();

  final float outerPush = 170f;
  final float innerPush = 80f;
  final float horizontalPushMult = 1.3f;
  final float minSpacing = 50f;


  // Start and end
  numNodes -= 2;

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

  ArrayList<Triangle> triangles = Delauney.triangulateCurrentNodes();
  debugDraw = triangles;
}

ArrayList<Triangle> debugDraw;



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
  final int iterations = 40;
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
