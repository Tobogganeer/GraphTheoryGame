
Node startNode;
Node endNode;

final float outerPush = 170f;
final float innerPush = 80f;
final float horizontalPushMult = 1.3f;
final float minSpacing = 70f;

Slider numNodesSlider;
Slider removeFactorSlider;
Slider edgeMinCostSlider;
Slider edgeMaxCostSlider;
Slider minMovesSlider;
Slider maxMovesSlider;

Button generateButton;
Button shiftUp;
Button shiftDown;
Button shiftLeft;
Button shiftRight;

void setup() {
  size(1000, 600);
  noStroke();
  fill(0);

  Applet.init(this);

  int minCost = 1, maxCost = 9;
  generateMap(20, 1f, minCost, maxCost);

  numNodesSlider = new Slider(new Rect(20, 30, 120, 10), "Number of Nodes", 6, 20, true, 6);
  removeFactorSlider = new Slider(new Rect(20, 60, 120, 10), "Edge Removal Multiplier", 0f, 3f, false, 1.5f);
  edgeMinCostSlider = new Slider(new Rect(20, 90, 120, 10), "Edge Min Cost", 0, 10, true, 1f);
  edgeMaxCostSlider = new Slider(new Rect(20, 120, 120, 10), "Edge Max Cost", 1, 20, true, 5f);
  minMovesSlider = new Slider(new Rect(20, 150, 120, 10), "Minimum Moves", 1, 10, true, 4f);
  maxMovesSlider = new Slider(new Rect(20, 180, 120, 10), "Maximum Moves", 2, 20, true, 6f);

  generateButton = new Button(20, 160, 120, 30, "Generate");

  //shiftUp = new Button(
}

void draw() {
  background(255);

  drawNodes();
  drawEdges();

  Button.displayAll();
  Slider.displayAll();

  validateSliders();
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
void generateMap(int numNodes, float removeFactor, int edgeMinCost, int edgeMaxCost)
{
  Node.all.clear();
  Edge.all.clear();

  // Set values for edges to colour themselves with gradients
  Edge.currentMinCost = edgeMinCost;
  Edge.currentMaxCost = edgeMaxCost;

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

  // Generate and then destroy some edges
  generateEdges(edgeMinCost, edgeMaxCost);
  destroyEdges(int(numNodes * removeFactor));
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


void generateEdges(int minCost, int maxCost)
{
  ArrayList<Triangle> triangles = Delauney.triangulateCurrentNodes();
  for (Triangle tri : triangles)
  {
    for (TriangleEdge triEdge : tri.edges)
    {
      // Add all edges from all triangles
      Edge edge = new Edge(int(random(minCost, maxCost + 1)), triEdge.a, triEdge.b);
      edge.tryAdd();
    }
  }
}

void destroyEdges(int num)
{
  int attemptsLeft = 1000;
  while (num > 0 && attemptsLeft-- > 0)
  {
    // Get a random edge
    Edge edge = Edge.all.get((int(random(Edge.all.size()))));

    // Destroy the edge
    edge.destroy();
    // Make sure we meet some criteria. Otherwise, add the edge back and try again
    boolean validPathStillExists = Pathfinding.findPath(startNode, endNode) != null;
    boolean nodesHaveMoreThanOneEdge = edge.nodeA.getAllEdges().size() > 1 && edge.nodeB.getAllEdges().size() > 1;
    if (validPathStillExists && nodesHaveMoreThanOneEdge)
      num--;
    else
      edge.forceAdd();
  }
}


void validateSliders()
{
  // Make sure costs and moves are always valid
  if (edgeMinCostSlider.currentValue > edgeMaxCostSlider.currentValue)
    edgeMaxCostSlider.setValue(edgeMinCostSlider.currentValue);
  if (minMovesSlider.currentValue > maxMovesSlider.currentValue)
    maxMovesSlider.setValue(minMovesSlider.currentValue);
}


// https://stackoverflow.com/questions/1519736/random-shuffling-of-an-array
ArrayList<Node> getShuffledNodeList()
{
  int index;
  ArrayList<Node> nodes = new ArrayList<Node>();
  for (int i = Node.all.size() - 1; i >= 0; i--)
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
