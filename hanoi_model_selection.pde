PFont font8, font12;
Hanoi_state s[];
int all1[] = {1, 1, 1, 1};
int Nr=4, Np=3; // number of rings, number of pegs
char first_peg = '1'; // the first peg is annotated '1' (rather than '0') in the data

int start, end, j=0;
int num_paths=0;

boolean clickp=false, newitemp=true, subgoalanalysisp=false;

String url = "hanoi-data.csv"; // http://www.illc.uva.nl/LaCo/webexperiment.nl/, hanoi-katja-corrected-cleaned.csv
String names[]; 
String path[], datalines[], paths[];
/* = {
   "11110000",
"1111000120012101110111212121202100210011201121111111",
"1200201221121112111001100210221022001200",
"1111111211100110021022102200120010000000",
"221010220022001210122012211211121110011001101110",
"11111102210220020002000120011001120122012211021101111111",
"0211012211221102210220020002000110011201220122110211",
"1111112221222022002200121012121222122202120210020002000110011201220122112111",
"2100201100110021102112212221222002200120112011002100",
"00000022202221221122110221022002000200011001120122012211021101111111",
"21002111201100110021102112212221222002200120112011002100"}; */

String huizinga[] = {//"01222222","22000000", // trial runs
                     "00011111","20121200","11121111",
                     "10222210","11021111","01220211",
                     "11221111","20112100","00220000",
                     "21112100","00110000","22221200",
                     "01221111","21112210","10220000",
                     "02002201","20110000","21221120",
                     "22220000","22002201","11110000","11221120"};
boolean huizingap = false;
// if set to true, the target and initial configuration are read from the array above.


boolean elementp(String[] thesuperset, String thesubset) {
  for (int i=0; i<thesuperset.length; i++)
    if (thesubset.equals(thesuperset[i])) return true;
  return false; }

subgoalanalysis analysis, analysis2;

void setup() 
{
  size(800, 700); 
//  noStroke();
  rectMode(CENTER);
  font12 = createFont("Arial-Black",12);
  font8 = createFont("Arial-Black",8); 
  textFont(font12); 

  s = new Hanoi_state[81];
  for (int i=0; i<81; i++)
    s[i] = new Hanoi_state(i/27,(i%27)/9,(i%9)/3,i%3,i);   
  
 // paths = loadStrings("http://www.illc.uva.nl/LaCo/webexperiment.nl/hanoi-data.php"); 
  
  datalines = loadStrings(url); 
  
  read_datalines();

  analysis = new subgoalanalysis("size2pyramids");
  analysis2 = new subgoalanalysis("size3pyramids");
  
  set_path(); 
  
  println(calc_index("0011"));
  //noLoop();
}

void print_likelihoods()
{
  noLoop();
  int currentj = j;
  
  PrintWriter output = createWriter("likelihoods.csv"); 
  for (j=0; j<num_paths; j++) {
   set_path(); 
   output.println(names[j%num_paths]+
     ", Path length, "+(paths[j].length()/4-2)+", Minimum, "+s[start].shortest_distance_to(end)+ 
     ", LogLik-random, "+llrandom()+", LogLik-optimal, "+lloptimal()
         +"; LogLik-"+analysis.name+"="+analysis.likelihood()
         +"; LogLik-"+analysis2.name+"="+analysis2.likelihood());
  }
  output.flush();  // Writes the remaining data to the file
  output.close();  // Finishes the file
  loop();
  j = currentj;
}

void draw()
{
    background(51); 

  if (subgoalanalysisp) {
    textFont(font8);
    analysis2.thetrellis.display(105,40,75,75);
    textFont(font12);
  }
  else {

  if (millis()<2000) {
    text("Use space and - (or n,p,t,h) to browse through data.",40,100);
    text("Data downloaded from " +url+"; looks like: ",40,300);
    for (int i=0; i<num_paths; i++)
      text(paths[i]+" "+i,40,350+i*10); }
  else {

  for (int i=0; i<81; i++)
   s[i].display(); 

  for (int k=1; k<path.length; k++) 
    s[calc_index(path[k])].draw_path_to_neighbour(s[calc_index(path[k-1])]);
  stroke(0);   
  
  fill(256,256,256);
//  text(1+(j%22),740,670);
  text(names[j%num_paths],700,670);

  if (newitemp) {
    newitemp=false;  
    s[start].draw_shortest_path_to(end);
  }
  
    stroke(256,0,0);
    strokeWeight(4);
    ellipse(s[start].x,s[start].y,10,10);
//    line(s[start].x,s[start].y,s[end].x,s[end].y);    

    text("Path length="+(paths[j].length()/4-2)+",Minimum="+s[start].shortest_distance_to(end),50,670); 
    text("LogLik-random="+llrandom()+"; LogLik-optimal="+lloptimal()
    +"; LogLik-"+analysis.name+"="+analysis.likelihood()
    +"; LogLik-"+analysis2.name+"="+analysis2.likelihood()
    ,50,630);
    strokeWeight(1);
  }
}
}

float llrandom() {
  float loglikelihood=0.0;
  for (int k=4; k<paths[j].length()-4; k+=4)
    loglikelihood+=s[calc_index(paths[j].substring(k,k+4))].llrandom(calc_index(paths[j].substring(k+4,k+8)));
  return loglikelihood;
}

float lloptimal() {
  float loglikelihood=0.0;
  for (int k=4; k<paths[j].length()-4; k+=4)
    loglikelihood+=s[calc_index(paths[j].substring(k,k+4))].lloptimal(calc_index(paths[j].substring(k+4,k+8)));
  return loglikelihood;
}

int calc_index(String state) {
  return (state.charAt(0)-'0')*27+(state.charAt(1)-'0')*9+(state.charAt(2)-'0')*3+(state.charAt(3)-'0'); }

int calc_index(int state[]) {
  return state[0]*27+state[1]*9+state[2]*3+state[3]; }

int[] copy_state(int state[]) {
  int newstate[] = new int[Nr];
  for (int i=0; i<Nr; i++) newstate[i]=state[i]; 
  return newstate;
}

void keyPressed() {
//  println("key is "+key);
  if (key=='s' || key=='S') saveFrame("toh-######.png");
  else if (key=='g' || key=='G') subgoalanalysisp=true;
  else if (key=='x' || key=='X') subgoalanalysisp=false;
  else if (key=='1') { 
    for (int k=0; k<81; k++) s[k].sampledneighbour=-1; 
    s[start].sample_random_path(path.length,1); }
  else if (key=='2') { 
    for (int k=0; k<81; k++) s[k].sampledneighbour=-1; 
    s[start].sample_random_path(path.length,2); }
  else if (key=='3') { 
    for (int k=0; k<81; k++) s[k].sampledneighbour=-1; 
    sample_subgoal_path(path.length); }
  else if (key=='$') { 
    for (int k=0; k<81; k++) s[k].sampledneighbour=-1; 
    print_likelihoods(); }
  else {
    // all keys that will change j
  if (key=='-' || key=='b' || key=='B') j-=1;
  else if (key=='p' || key=='P') j-=huizinga.length;
  else if (key=='n' || key=='N') j+=huizinga.length;
  else if (key=='t' || key=='T') j+=10;
  else if (key=='h' || key=='H') j+=100;
  else if (key==' ') j++;
  if (j<0) j=num_paths+j;
  j=j%num_paths;
  set_path();
  }
}

void mouseClicked() {
  clickp=true; }
