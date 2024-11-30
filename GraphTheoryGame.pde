
Node startNode;
Node endNode;

Path desiredPath;
Path currentPath;

final float outerPush = 170f;
final float innerPush = 100f;
final float horizontalPushMult = 1.4f;
final float minSpacing = 90f;

Slider numNodesSlider;
Slider removeFactorSlider;
Slider edgeMinCostSlider;
Slider edgeMaxCostSlider;
Slider numMovesSlider;

Button generateButton;

Button easyButton;
Button mediumButton;
Button hardButton;

Button shiftUp;
Button shiftDown;
Button shiftLeft;
Button shiftRight;

final int defaultEdgeColour = #4253E3;
final int startColour = #3CDEA4;
final int endColour = #E0307C;
final int desiredPathColour = #70E893;
final int currentPathColour = #FFA040;

final int numTweakCandidatesConsidered;


void setup() {
  size(1000, 600);
  noStroke();
  fill(0);

  Applet.init(this);

  numNodesSlider = new Slider(new Rect(20, 30, 120, 10), "Number of Nodes", 6, 20, true, 11f);
  removeFactorSlider = new Slider(new Rect(20, 60, 120, 10), "Edge Removal Multiplier", 0f, 1.5f, false, 0.5f);
  edgeMinCostSlider = new Slider(new Rect(20, 90, 120, 10), "Edge Min Cost", 0, 10, true, 1f);
  edgeMaxCostSlider = new Slider(new Rect(20, 120, 120, 10), "Edge Max Cost", 1, 20, true, 5f);
  numMovesSlider = new Slider(new Rect(20, 150, 120, 10), "Required Moves", 1, 12, true, 5f);

  generateButton = new Button(20, 170, 120, 30, "Generate");
  new Label(20, 220, 120, 20, "^^ Settings ^^", 16);

  new Label(20, 400, 120, 20, "vv Quick Play vv", 16);
  easyButton = new Button(30, 450, 100, 24, "Easy");
  mediumButton = new Button(30, 480, 100, 24, "Medium");
  hardButton = new Button(30, 510, 100, 24, "Hard");

  //shiftUp = new Button(

  generateMapWithCurrentSliders();

  // avg ~520 ms for 100 000 iterations, 11 nodes
}

void draw() {
  background(255);

  drawGame();
  drawUI();
}

void drawGame()
{
  drawEdges();
  drawNodes();
  desiredPath.draw(desiredPathColour);
  currentPath.draw(currentPathColour);
  drawStartAndEnd();
}

void drawUI()
{
  Button.displayAll();
  Slider.displayAll();
  Label.displayAll();
  drawLegend();

  validateSliders();
}


void mouseReleased()
{
  if (generateButton.isHovered())
    generateMapWithCurrentSliders();
}

void generateMapWithCurrentSliders()
{
  generateMap(
    int(numNodesSlider.currentValue),
    removeFactorSlider.currentValue,
    int(edgeMinCostSlider.currentValue),
    int(edgeMaxCostSlider.currentValue),
    int(numMovesSlider.currentValue));
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
void generateMap(int numNodes, float removeFactor, int edgeMinCost, int edgeMaxCost, int requiredMoves)
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

  // Find current lowest-cost path
  desiredPath = Pathfinding.findPath(startNode, endNode);

  // Make sure generation didn't fail for some reason
  if (desiredPath == null)
  {
    generateMap(numNodes, removeFactor, edgeMinCost, edgeMaxCost, requiredMoves);
    return;
  }

  // Change edge costs so our lowest-cost path is cheaper
  currentPath = transformPath(requiredMoves, edgeMinCost, edgeMaxCost);
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

/*

 Theory/planning:
 - Generate a bunch of tweaked paths
 - See which one is the most "interesting" and stick with it
 
 */
Path transformPath(int requiredMoves, int minCost, int maxCost)
{
  // Store the costs before we tweak anything
  int[] baseCosts = TweakCandidate.getCurrentCosts();

  TweakCandidate[] candidates = new TweakCandidate[numTweakCandidatesConsidered];

  TweakCandidate mostInteresting = null;
  int leastMatchingNodes = 100;

  for (int i = 0; i < candidates.length; i++)
  {
    // Generate a new candidate for the tweaked costs
    candidates[i] = generateTweakedPath(requiredMoves, minCost, maxCost);
    // Reset the costs for the next candidate
    TweakCandidate.applyCosts(baseCosts);

    // See how different this candidate is from the starting path
    int numMatchingNodes = candidates[i].numMatchingNodes(desiredPath);
    if (numMatchingNodes < leastMatchingNodes)
    {
      // Store it as the "most interesting" candidate so far
      leastMatchingNodes = numMatchingNodes;
      mostInteresting = candidates[i];
    }
  }
}

/*

 Theory/planning time:
 - Choose a random edge. Adjust its cost, making sure to respect min/max costs
 - Check if the lowest-cost path changes. If so, move along.
 - Otherwise, try tweaking the value again in the same direction (if possible)
 - Repeat until requiredMoves tweaks have been made
 
 */
TweakCandidate generateTweakedPath(int requiredMoves, int minCost, int maxCost)
{
  Path currentLowestCostPath = desiredPath;
  int tweaksMade = 0;
  int itersLeft = 10000;

  do
  {
    Edge victim = Edge.all.get(int(random(Edge.all.size())));
    int ogCost = victim.cost;
    int tweakDirection = random(1f) > 0.5f ? -1 : 1;
    if (ogCost == maxCost)
      tweakDirection = -1; // Lower cost if we can't go any higher
    else if (ogCost == minCost)
      tweakDirection = 1; // Increase cost by if we can't go any lower

    // How many times we can possibly tweak before reaching the max/min
    int possibleTweaks = tweakDirection == 1 ? maxCost - ogCost : ogCost - minCost;
    // Make sure we have enough tweaks left
    possibleTweaks = min(possibleTweaks, requiredMoves - tweaksMade);

    for (int i = 0; i < possibleTweaks; i++)
    {
      victim.cost += tweakDirection * i;
      Path newPath = Pathfinding.findPath(startNode, endNode);
      // If the path changed...
      if (newPath != null && !newPath.equalTo(desiredPath))
      {
        tweaksMade++;
        currentLowestCostPath = newPath;
        break;
      } else
      {
        victim.cost = ogCost; // Reset cost - the loop will increment it even more next time
      }
    }
  }
  while (tweaksMade < requiredMoves && itersLeft-- > 0);

  return new TweakCandidate(currentLowestCostPath);
}



void validateSliders()
{
  // Make sure costs and moves are always valid
  if (edgeMinCostSlider.currentValue > edgeMaxCostSlider.currentValue)
    edgeMaxCostSlider.setValue(edgeMinCostSlider.currentValue);
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












// ==================== DRAW ==========================







void drawNodes()
{
  for (Node n : Node.all)
    n.draw(defaultEdgeColour);
}

void drawEdges()
{
  // TODO: Highlighting/colours
  for (Edge e : Edge.all)
    e.draw(defaultEdgeColour);
}


void drawStartAndEnd()
{
  final float diameter = 14;

  Draw.start();

  // Start
  fill(startColour);
  ellipse(startNode.position.x, startNode.position.y, diameter, diameter);
  textAlign(RIGHT, CENTER);
  text("Start", startNode.position.x - 10, startNode.position.y);

  // End
  fill(endColour);
  ellipse(endNode.position.x, endNode.position.y, diameter, diameter);
  textAlign(LEFT, CENTER);
  text("END", endNode.position.x + 10, endNode.position.y);

  Draw.end();
}

void drawLegend()
{
  Draw.start();

  fill(120);
  rectMode(CORNER);
  rect(width / 2 - 20, 0, 200, 60);

  fill(desiredPathColour);
  rectMode(CENTER);
  rect(width / 2, 10, 20, 20);
  textAlign(LEFT, CENTER);
  text("Target Path", width / 2 + 30, 10);

  fill(currentPathColour);
  rect(width / 2, 30, 20, 20);
  textAlign(LEFT, CENTER);
  text("Current Lowest-Cost Path", width / 2 + 30, 30);

  Draw.end();
}
