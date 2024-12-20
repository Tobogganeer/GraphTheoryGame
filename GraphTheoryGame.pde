import java.util.HashMap;

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

int generationAttempts = 0;
final int maxGenerationAttempts = 10;

final float tweakMutatorChance = 0.3f;


int[] baseCosts;
int currentTweaks;
int tweaksForThisGeneration;
int minCostForThisGeneration;
int maxCostForThisGeneration;
static HashMap<Edge, Integer> tweakHistory = new HashMap<Edge, Integer>();

Button increaseButton;
Button decreaseButton;
Edge currentHoveredEdge;

Button resetCostsButton;

final int tweakButtonAppearDist = 50;

Label victory;

//Button shiftUp;
//Button shiftDown;
//Button shiftLeft;
//Button shiftRight;

final int defaultEdgeColour = #4253E3;
final int startColour = #3CDEA4;
final int endColour = #E0307C;
final int desiredPathColour = #70E893;
final int currentPathColour = #FFA040;

final int numTweakCandidatesConsidered = 20;
final int minPathLength = 4;


void setup() {
  size(1000, 600);
  noStroke();
  fill(0);

  Applet.init(this);

  numNodesSlider = new Slider(new Rect(20, 30, 120, 10), "Number of Nodes", 8, 20, true, 11f);
  removeFactorSlider = new Slider(new Rect(20, 60, 120, 10), "Edge Removal Multiplier", 0f, 1.5f, false, 0.5f);
  edgeMinCostSlider = new Slider(new Rect(20, 90, 120, 10), "Edge Min Cost", 0, 10, true, 1f);
  edgeMaxCostSlider = new Slider(new Rect(20, 120, 120, 10), "Edge Max Cost", 1, 20, true, 7f);
  numMovesSlider = new Slider(new Rect(20, 150, 120, 10), "Generation Tweaks", 6, 20, true, 8f);

  generateButton = new Button(20, 170, 120, 30, "Generate");
  new Label(20, 220, 120, 20, "^^ Settings ^^", 16);

  new Label(20, 400, 120, 20, "vv Quick Play vv", 16);
  easyButton = new Button(30, 450, 100, 24, "Easy");
  mediumButton = new Button(30, 480, 100, 24, "Medium");
  hardButton = new Button(30, 510, 100, 24, "Hard");

  // Path tweaking buttons
  increaseButton = new Button(0, 0, 14, 16, "^");
  decreaseButton = new Button(0, 0, 14, 16, "v");
  increaseButton.enabled = false;
  decreaseButton.enabled = false;

  resetCostsButton = new Button(width - 120, height - 40, 100, 30, "Reset Costs");

  victory = new Label(width / 2 - 200, height / 2 - 50, 400, 100, "You Won!", 30);
  victory.enabled = false;

  //shiftUp = new Button(

  generateMapWithCurrentSliders();

  // avg ~520 ms for 100 000 iterations, 11 nodes
}

void draw() {
  background(255);

  drawGame();
  drawUI();
  handleTweaks();

  drawVictoryScreen();
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
  drawCurrentTweaks();

  Popup.update();

  validateSliders();
}

void handleTweaks()
{
  ArrayList<Edge> edgesWithinReach = new ArrayList<Edge>();
  ArrayList<Float> distances = new ArrayList<Float>();
  PVector mousePos = new PVector(mouseX, mouseY);
  // tweakButtonAppearDist
  for (Edge edge : Edge.all)
  {
    float dist = edge.midPoint.dist(mousePos);
    if (dist < tweakButtonAppearDist)
    {
      edgesWithinReach.add(edge);
      distances.add(dist);
    }
  }
  // We can edit an edge
  if (edgesWithinReach.size() > 0)
  {
    Edge closest = edgesWithinReach.get(0);
    float closestDist = distances.get(0);

    // Get closest edge of the bunch, in case they are close
    for (int i = 1; i < edgesWithinReach.size(); i++)
    {
      if (distances.get(i) < closestDist)
      {
        closestDist = distances.get(i);
        closest = edgesWithinReach.get(i);
      }
    }

    currentHoveredEdge = closest;

    // Turn on buttons if we can tweak in a certain direction
    increaseButton.enabled = currentHoveredEdge.cost < maxCostForThisGeneration;
    decreaseButton.enabled = currentHoveredEdge.cost > minCostForThisGeneration;

    increaseButton.setPosition(closest.midPoint.copy().add(new PVector(-7, -26)));
    decreaseButton.setPosition(closest.midPoint.copy().add(new PVector(-7, 10)));
  }
  // No edges nearby
  else
  {
    increaseButton.enabled = false;
    decreaseButton.enabled = false;
  }
}



void mouseReleased()
{
  if (generateButton.isHovered())
    generateMapWithCurrentSliders();

  if (easyButton.isHovered())
    easy();
  if (mediumButton.isHovered())
    medium();
  if (hardButton.isHovered())
    hard();

  if (increaseButton.isHovered())
    increaseCost();
  if (decreaseButton.isHovered())
    decreaseCost();

  if (resetCostsButton.isHovered())
  {
    currentTweaks = 0;
    TweakCandidate.applyCosts(baseCosts);
    tweakHistory.clear();
    recalculatePath();
  }
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
  if (generationAttempts > maxGenerationAttempts)
  {
    Popup.show("Generation failed after " + generationAttempts + " attempts. Invalid settings?", 5.0f);
    generationAttempts = 0;
    return;
  }

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

  // Edges didn't generate (don't know why but it is happening)
  if (Edge.all.size() == 0)
  {
    generateMapWithCurrentSliders();
    return;
  }
  destroyEdges(int(numNodes * removeFactor));

  // Find current lowest-cost path
  desiredPath = Pathfinding.findPath(startNode, endNode);

  // Make sure generation didn't fail for some reason
  if (desiredPath == null || desiredPath.nodes.size() < minPathLength)
  {
    generateMapWithCurrentSliders();
    return;
  }

  // Change edge costs to give us a random starting path
  Path startingPath = transformPath(requiredMoves, edgeMinCost, edgeMaxCost);
  // If null, we are regenerating the map
  if (startingPath == null)
    return;

  currentPath = startingPath;
  generationAttempts = 0; // Generation successful

  tweaksForThisGeneration = requiredMoves;
  minCostForThisGeneration = edgeMinCost;
  maxCostForThisGeneration = edgeMaxCost;
  currentTweaks = 0;
  baseCosts = TweakCandidate.getCurrentCosts();
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

  //TweakCandidate[] candidates = new TweakCandidate[numTweakCandidatesConsidered];

  TweakCandidate mostInteresting = null;
  int leastMatchingNodes = 100;

  for (int i = 0; i < numTweakCandidatesConsidered; i++)
  {
    // Generate a new candidate for the tweaked costs
    TweakCandidate candidate = generateTweakedPath(requiredMoves, minCost, maxCost);
    //if (canBeSolvedInOneTweak(candidate)
    // Reset the costs for the next candidate
    TweakCandidate.applyCosts(baseCosts);

    // See how different this candidate is from the starting path
    int numMatchingNodes = candidate.numMatchingNodes(desiredPath);
    if (numMatchingNodes < leastMatchingNodes)
    {
      // Store it as the "most interesting" candidate so far
      leastMatchingNodes = numMatchingNodes;
      mostInteresting = candidate;

// TODO: Don't just stop here! That's why we are getting paths that can be solved in one
// Calculate which paths take more thingies to beat
      // Start and end
      if (numMatchingNodes == 2)
        break;
    }
  }

  // If the least matching path only changed 1 node (or none at all)
  if (desiredPath.nodes.size() - leastMatchingNodes <= 1)
  {
    // Make a new map
    generateMapWithCurrentSliders();
    return null;
  }

  TweakCandidate.applyCosts(mostInteresting.costs);
  return mostInteresting.path;
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

  ArrayList<Path> previousPaths = new ArrayList<Path>();
  previousPaths.add(desiredPath);

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
      if (newPath != null && !pathInList(newPath, previousPaths))
      {
        tweaksMade++;

        // Random chance to tweak a little further in that direction
        if (random(1f) < tweakMutatorChance && tweaksMade < requiredMoves &&
          victim.cost + tweakDirection <= maxCost && victim.cost + tweakDirection >= minCost)
        {
          victim.cost += tweakDirection;
          tweaksMade++;
        }

        currentLowestCostPath = newPath;
        previousPaths.add(currentLowestCostPath);
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

boolean pathInList(Path path, ArrayList<Path> isItInHere)
{
  for (Path p : isItInHere)
    if (p.equalTo(path))
      return true;
  return false;
}

boolean canBeSolvedInOneTweak(TweakCandidate candidate)
{
  // Set up edges
  TweakCandidate.applyCosts(candidate.costs);

  for (Edge e : Edge.all)
  {
    e.cost--; // -1
    if (Pathfinding.findPath(startNode, endNode).equalTo(desiredPath))
      return true;
    e.cost += 2; // +1
    if (Pathfinding.findPath(startNode, endNode).equalTo(desiredPath))
      return true;
    e.cost--; // Reset
  }

  return false;
}

// WARNING: VERY FAST EXPONENTIAL GROWTH, KEEP tweaks LOW
/*
boolean canBeSolvedInNTweaks(TweakCandidate candidate, int tweaks)
 {
 // Set up edges
 TweakCandidate.applyCosts(candidate.costs);
 
 for (int i = 0; i < Edge.all.size(); i++)
 {
 }
 }
 
 boolean solvedInThisDepth(int depth)
 {
 for (int i = 0; i < Edge.all.size(); i++)
 {
 int[] costs = TweakCandidate.getCurrentCosts();
 Edge.all.get(i).cost--; // Don't care about limits currently
 if (depth > 0 && solvedInThisDepth(depth--))
 return true;
 }
 }
 */



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


void increaseCost()
{
  // Already edited this edge
  if (tweakHistory.containsKey(currentHoveredEdge))
  {
    int val = tweakHistory.get(currentHoveredEdge);
    // Actually undoing a tweak
    if (val < 0)
      currentTweaks--;
    else
      currentTweaks++;
    val++;
    currentHoveredEdge.cost++;
    tweakHistory.put(currentHoveredEdge, val);
    // Mark as un-tweaked if back at 0
    if (val == 0)
      tweakHistory.remove(currentHoveredEdge);
  } else
  {
    currentTweaks++;
    currentHoveredEdge.cost++;
    tweakHistory.put(currentHoveredEdge, 1);
  }

  recalculatePath();
}

void decreaseCost()
{
  // Already edited this edge
  if (tweakHistory.containsKey(currentHoveredEdge))
  {
    int val = tweakHistory.get(currentHoveredEdge);
    // Actually undoing a tweak
    if (val > 0)
      currentTweaks--;
    else
      currentTweaks++;
    val--;
    currentHoveredEdge.cost--;
    tweakHistory.put(currentHoveredEdge, val);
    // Mark as un-tweaked if back at 0
    if (val == 0)
      tweakHistory.remove(currentHoveredEdge);
  } else
  {
    currentTweaks++;
    currentHoveredEdge.cost--;
    tweakHistory.put(currentHoveredEdge, -1);
  }

  recalculatePath();
}

void recalculatePath()
{
  currentPath = Pathfinding.findPath(startNode, endNode);
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

void drawCurrentTweaks()
{
  Draw.start();

  textSize(28);
  textAlign(RIGHT, CENTER);

  // Divide by 3 for devious "balancing"
  text("Target: " + int(tweaksForThisGeneration / 3f) + " tweaks", width - 20, height - 100);
  text("Currently made " + currentTweaks + " tweaks", width - 20, height - 70);

  Draw.end();
}

void drawVictoryScreen()
{
  if (currentPath.equalTo(desiredPath))
  {
    victory.enabled = true;

    Draw.start();

    textAlign(CENTER, CENTER);
    textSize(18);
    text("Used " + currentTweaks + "/" + int(tweaksForThisGeneration / 3f) + " tweaks", width / 2, height / 2 + 30);

    Draw.end();
  } else
    victory.enabled = false;
}













// ========================= DIFFICULTIES

/*
numNodesSlider       6, 20, true, 11f);
 removeFactorSlider   0f, 1.5f, false, 0.5f);
 edgeMinCostSlider    0, 10, true, 1f);
 edgeMaxCostSlider    1, 20, true, 7f);
 numMovesSlider       1, 12, true, 6f);
 */

void easy()
{
  numNodesSlider.setValue(8);
  removeFactorSlider.setValue(0.4f);
  edgeMinCostSlider.setValue(1f);
  edgeMaxCostSlider.setValue(4f);
  numMovesSlider.setValue(6f);

  generateMapWithCurrentSliders();
}

void medium()
{
  numNodesSlider.setValue(12);
  removeFactorSlider.setValue(0.6f);
  edgeMinCostSlider.setValue(1f);
  edgeMaxCostSlider.setValue(6f);
  numMovesSlider.setValue(12f);

  generateMapWithCurrentSliders();
}

void hard()
{
  numNodesSlider.setValue(18);
  removeFactorSlider.setValue(0.4f);
  edgeMinCostSlider.setValue(1f);
  edgeMaxCostSlider.setValue(10f);
  numMovesSlider.setValue(18f);

  generateMapWithCurrentSliders();
}
