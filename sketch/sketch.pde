import java.util.Map;

int w = 700; int h = 175; // set the same ones in size() too
int inGrid = 8;
int outGrid = 8;
int thresholdDistInLogo = inGrid;
int thresholdDistOutLogo = outGrid;
int thresholdDistOutToLogoEdge = round(inGrid * 1.5);

Map<Integer, Node> nodes = new HashMap<>();
Map<String, Integer> pairIds = new HashMap<>();

// The char divider logic is only to include the letter in the node-naming 
// if you want to apply letter-specific coloring or something in JavaScript
int[] charDividers = { 160, 330, 500 };
String getCharForXpos(int x) {
    if (x < charDividers[0]) return "L";
    if (x < charDividers[1]) return "O";
    if (x < charDividers[2]) return "G";
    return "O";
}

void setup() {
  noLoop();
  size(700, 175);
  background(255);
  PImage img = loadImage("logo.png");
  image(img, 0, 0);

  // ---------- CREATE NODES INSIDE AND OUTSIDE OF LOGO

  noStroke();
  int count = 0;

  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      if (get(x, y) != -1) { // non-white pixels
        if (x % inGrid == 0 && y % inGrid == 0) {
          fill(#FFFF00);
          circle(x, y, 3);
          nodes.put(count, new Node(count, x, y, true));
          count ++;
        }
      } else { // white pixels
        if (x % outGrid == 0 && y % outGrid == 0) { // if (random(1) > 0.99)
          fill(#0000FF);
          nodes.put(count, new Node(count, x, y, false));
          count ++;
        }
      }
    }
  }

  println("total # of nodes: " + count);

  // ---------- ADD NEIGHBOURS WITHIN LOGO

  checkForNeighbours(0, thresholdDistInLogo);

  // ---------- MARK NODES ON THE EDGE OF THE LOGO

  int min = 100;
  int max = 0;
  int sum = 0;
  int inLogoCount = 0;
  for (int i = 0; i < nodes.size(); i++) {
    Node node = nodes.get(i);
    if (!node.inLogo) continue;
    int neighbours = node.neighbours.size();
    if (neighbours < min) min = neighbours;
    if (neighbours > max) max = neighbours;
    sum += neighbours;
    inLogoCount ++;
    if (neighbours < 4) { // 4 is "graphically empirically" determined
      node.onLogoEdge = true;
      stroke(#FFFF00);
      fill(#FFFF00);
      circle(node.x, node.y, 6);
    }
  }
  println("min: " + min + ", max: " + max + ", avg: " + (sum / inLogoCount));

  // ---------- ADD NEIGHBOURS OUTSIDE LOGO AND TO LOGO-EDGES

  checkForNeighbours(1, thresholdDistOutLogo);
  checkForNeighbours(2, thresholdDistOutToLogoEdge);

  // ---------- DRAW ALL EDGES

  stroke(#FF00FF);
  for (int i = 0; i < nodes.size(); i++) {
    Node node = nodes.get(i);
    // println(node);
    for (int j = 0; j < node.neighbours.size(); j++) {
      Node neighbour = nodes.get(node.neighbours.get(j));
      line(node.x, node.y, neighbour.x, neighbour.y);
    }
  }

  // ---------- CHAR DIVIDER LINES

  stroke(#000000);
  for (int i = 0; i < charDividers.length; i++) {
    line(charDividers[i], 0, charDividers[i], h);
  }

  // ---------- BUILD OUTPUT

  JSONObject root = new JSONObject();
  JSONArray nodesArr = new JSONArray();
  JSONArray edgesArr = new JSONArray();

  for (int i = 0; i < nodes.size(); i++) {
    Node node = nodes.get(i);
    nodesArr.append(node.toJson());
    for (int j = 0; j < node.neighbours.size(); j++) {
      Node neighbour = nodes.get(node.neighbours.get(j));
      int edgeId = edgesArr.size();
      String pairId = node.id < neighbour.id ? node.id + "-" + neighbour.id : neighbour.id + "-" + node.id;

      if (pairIds.containsKey(pairId)) continue; // avoid the same edge in the other direction
      pairIds.put(pairId, edgeId);

      JSONObject edgeJson = new JSONObject();
      edgeJson.setInt("id", edgeId);
      edgeJson.setString("pairId", pairId);
      edgeJson.setInt("source", node.id);
      edgeJson.setInt("target", neighbour.id);
      edgeJson.setBoolean("bothNodesInLogo", node.inLogo && neighbour.inLogo);
      edgesArr.append(edgeJson);
    }
  }

  root.setJSONArray("nodes", nodesArr);
  root.setJSONArray("edges", edgesArr);
  // saveJSONObject(root, "data.json");

  PrintWriter output = createWriter("../js/generated-data.js");
  output.print("let data = ");
  output.print(root.toString());
  output.print(";");
  output.flush();
  output.close();
}

// ---------- NODE CLASS

class Node {
  int id;
  int x, y;
  boolean inLogo;
  boolean onLogoEdge = false;

  ArrayList<Integer> neighbours = new ArrayList<>();

  Node(int _id, int _x, int _y, boolean _inLogo) {
    id = _id;
    x = _x;
    y= _y;
    inLogo = _inLogo;
  }

  String toString() {
    String neighboursStr = "";
    for (int i = 0; i < neighbours.size(); i++) {
      neighboursStr += neighbours.get(i) + ", ";
    }
    return id +": " + x + "/" + y + ", neighbours: " + neighboursStr;
  }

  double distTo(Node other) {
    return Math.sqrt(Math.pow(x - other.x, 2) + Math.pow(y - other.y, 2));
  }

  JSONObject toJson() {
    JSONObject nodeJson = new JSONObject();
    nodeJson.setInt("id", id);
    // nodeJson.setInt("x", x);
    // nodeJson.setInt("y", y);
    nodeJson.setBoolean("inLogo", inLogo);
    nodeJson.setString("name", (inLogo ? getCharForXpos(x) + "_" : "") + id + "_" + x + "-" + y);
    return nodeJson;
  }
}

// ---------- METHODS

void checkForNeighbours(int checkingMode, int _thresholdDist) {
  for (int i = 0; i < nodes.size(); i++) {
    Node candidate = nodes.get(i);
    // TODO switch here already would be more computation-saving

    for (int j = 0; j < nodes.size(); j++) {
      if (i == j) continue;
      Node check = nodes.get(j);

      switch(checkingMode) {
      case 0: // 0: only within logo
        if (!candidate.inLogo || !check.inLogo) continue;
        break;
      case 1: // only outside logo
        if (candidate.inLogo || check.inLogo) continue;
        break;
      case 2: // outside of logo and onLogoEdge-nodes within logo
        if ((candidate.onLogoEdge && !check.inLogo) || (check.onLogoEdge && !candidate.inLogo)) {
        } else continue;
        break;
      }

      if (candidate.distTo(check) <= _thresholdDist) candidate.neighbours.add(check.id);
    }
  }
}
