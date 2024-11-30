static class TweakCandidate
{
  Path path;
  int[] costs;

  public TweakCandidate(Path path)
  {
    this.path = path;
    costs = getCurrentCosts();
  }

  static void applyCosts(int[] costs)
  {
    for (int i = 0; i < Edge.all.size(); i++)
    {
      Edge.all.get(i).cost = costs[i];
    }
  }

  static int[] getCurrentCosts()
  {
    int[] costs = new int[Edge.all.size()];
    for (int i = 0; i < Edge.all.size(); i++)
      costs[i] = Edge.all.get(i).cost;
    return costs;
  }

  int numMatchingNodes(Path other)
  {
    int matches = 0;

    for (Node ours : path.nodes)
      for (Node theirs : other.nodes)
        if (ours == theirs)
          matches++;
    return matches;
  }
}
