class Hanoi_state {
  int rings[];
  int Nn;
  int neighbours[];
  int distance[]; 
  boolean activep = false;
  String name;
  int myindex;
  int knowngoal, knownmax=81, knownbest;
  boolean subgoal_onshortestpathp = false;
  int sampledneighbour=-1;

  float x,y;
  float radius=10.0;
  float ux[] = { -24.0,0.0,24.0 };
  float uy[] = { 12.0,-24.0,12.0};
  
  Hanoi_state(int a, int b, int c, int d, int theindex) {
    myindex=theindex;
    rings = new int[Nr];
    rings[0] =a; rings[1]=b; rings[2]=c; rings[3]=d;
    name = new String(""+a+b+c+d);
    neighbours = new int[3];
    distance = new int[Np];
    
 //    for (int i=0; i<Nr; i++) rings[i]=r[i]; 
    for (int j=0; j<Np; j++) distance[j]=100;
    x = 380 + 8*ux[rings[3]] + 4*ux[flip_triangle(rings[2],rings[3])] + 2*ux[flip_triangle(flip_triangle(rings[1],rings[2]),rings[3])] 
    + ux[flip_triangle(flip_triangle(flip_triangle(rings[0],rings[1]),rings[2]),rings[3])];
    y = 400 + 8*uy[rings[3]] + 4*uy[flip_triangle(rings[2],rings[3])] + 2*uy[flip_triangle(flip_triangle(rings[1],rings[2]),rings[3])] 
    + uy[flip_triangle(flip_triangle(flip_triangle(rings[0],rings[1]),rings[2]),rings[3])];

    Nn=0;
    for (int r=0; r<4; r++)
      for (int p=0; p<3; p++)
        if (valid_move(r,p)) {
          int neighb[] = copy_state(rings);
          neighb[r]=p;
          neighbours[Nn] = calc_index(neighb);
          Nn++;
       }
  }
  
  void clear() {
    subgoal_onshortestpathp = false;
    sampledneighbour=-1;
    activep=false;
  }
  
  int flip_triangle(int curr, int head_direction) {
  // flip triangle such that head_direction remains  
    if (curr==0 && head_direction==0) return 0;
    if (curr==1 && head_direction==0) return 2;
    if (curr==2 && head_direction==0) return 1;
    if (curr==0 && head_direction==1) return 2;
    if (curr==1 && head_direction==1) return 1;
    if (curr==2 && head_direction==1) return 0;
    if (curr==0 && head_direction==2) return 1;
    if (curr==1 && head_direction==2) return 0;
    if (curr==2 && head_direction==2) return 2;
 return 0; }


  boolean valid_move(int ring, int peg) {
    if (rings[ring]==peg) return false; // not a move
    // valid if smallest on current peg and target peg
    for (int i=0; i<ring; i++) {
      if (rings[i]==peg) return false; // there's smaller ring on the target peg
      if (rings[i]==rings[ring]) return false; // there's smaller ring on the current peg 
    }
    return true;
  }
  
  void display() {
//    if (keyPressed) activep=false;
    
    if (subgoal_onshortestpathp)
      fill(128,256,256);
    else if (activep) {
      if (activatedp()) fill(256,128,0); else fill(256,0,0); }
    else {     
      if (activatedp()) fill(256,128,256); else fill(256,256,256); }

    if (activatedp()) {
      if (clickp) {
         activep=true;
         clickp=false; }
      for (int k=0; k<paths[j].length(); k+=4) {
           text(""+(paths[j].charAt(k)-'0' + 1)+
                (paths[j].charAt(k+1)-'0'  + 1)+
                (paths[j].charAt(k+2)-'0'  + 1)+
                (paths[j].charAt(k+3)-'0'  + 1),
                10,20+7*k); }
      stroke(0,256,0);
      strokeWeight(4);
      draw_shortest_path_to(knowngoal);
      draw_pegs(); }
      
    stroke(256,256,256);      
    ellipse(x,y,8,8);
    text(""+
    (1+rings[0])+(1+rings[1])+(1+rings[2])+(1+rings[3])
//    myindex+"/"+knownmax+"/\n"+join(nf(neighbours,2),",")
    ,x+3,y-3);
    draw_lines_to_neighbours();
  }
 
   boolean activatedp() {
   if (mouseX>x-radius && mouseX<x+radius && mouseY>y-radius && mouseY<y+radius) return true; else return false; }

 
 void draw_pegs() {
   stroke(256,256,256);
   strokeWeight(4);
   line(650,150,750,150);
   line(670,150,670,100);
   line(700,150,700,100);
   line(730,150,730,100);
   
   line(664+30*rings[0],110,676+30*rings[0],110);
   line(661+30*rings[1],120,679+30*rings[1],120);
   line(658+30*rings[2],130,682+30*rings[2],130);
   line(655+30*rings[3],140,685+30*rings[3],140);
   
   strokeWeight(1);
 }
 
 
 void draw_lines_to_neighbours() {
   for (int i=0; i<Nn; i++) {
     if (i==sampledneighbour) {
       strokeWeight(4);
       stroke(128,256,256);
     }
     else {
       strokeWeight(1);
       stroke(256,256,256);
     }
     line(x,y,s[neighbours[i]].x,s[neighbours[i]].y);
   }
 } 
 
 void draw_shortest_path_to(int goal) {
   if (myindex==goal) return;
   if (knowngoal!=goal) percolate_shortest_path(goal);
   line(x,y,s[knownbest].x,s[knownbest].y);
   s[knownbest].draw_shortest_path_to(goal);
 }
 
 void sample_random_path(int len) {
   if (len<1) return;
   float uniform = random(0.0,1.0);
   float cumulative=0.0;
   int selected=0;
   for (int i=0; i<Nn; i++) {
    cumulative+=exp(llrandom(neighbours[i]));
    if (uniform<cumulative) { selected=i; break; }
   }
   fill(128,256,256);
   sampledneighbour=selected;
   s[neighbours[selected]].sample_random_path(len-1);
 }
 
  int shortest_distance_to(int goal) {
   if (myindex==goal) return 0;
   if (knowngoal==goal) return knownmax;
   else {
     percolate_shortest_path(goal);
     return knownmax; }
  }
 
  ArrayList<Integer> shortest_path_to(int goal) {
   if (knowngoal != goal)
     s[goal].percolate_shortest_path(goal);
   ArrayList<Integer> lst = new ArrayList<Integer>(); 
   lst.add(myindex);
   if (myindex==goal) {return lst; }
   else {
     lst.addAll(s[knownbest].shortest_path_to(goal));
     return lst; }
  }
   
 boolean on_shortest_path(int focal) {
   if (myindex==focal) return true;
   if (myindex==knowngoal) return false;
   return s[knownbest].on_shortest_path(focal);
  }

 void percolate_shortest_path(int goal) {
   // start from goal
   knowngoal = goal;
   if (goal==myindex) knownmax=0;
   for (int i=0; i<Nn; i++) {
     if (s[neighbours[i]].knowngoal!=goal || s[neighbours[i]].knownmax>knownmax+1) {
       s[neighbours[i]].knownmax=knownmax+1;
       s[neighbours[i]].knownbest=myindex;
       s[neighbours[i]].percolate_shortest_path(goal);
     }
   }
 }

  boolean neighbourp(int nb) {
    for (int i=0; i<Nn; i++) if (neighbours[i]==nb) return true;
    return false;
  }

  float Premain=0.009;
  float Pillegal=0.001;
  float Plegal=0.99;
  float Poptimal=0.9;
  float Pmistake=0.09;

  float llrandom(int nextstate) {
    // calculate likelihood of transitioning to nextstate under the random model
    if (neighbourp(nextstate)) return log(Plegal/Nn);
    if (myindex==nextstate) return log(Premain);
    else return log(Pillegal);
  }

  float lloptimal(int nextstate) {
    // calculate likelihood of transitioning to nextstate under the random model
    if (knownbest==nextstate) return log(Poptimal);
    if (neighbourp(nextstate)) return log(Pmistake/(Nn-1));
    if (myindex==nextstate) return log(Premain);
    else return log(Pillegal);
  }
 
 }
