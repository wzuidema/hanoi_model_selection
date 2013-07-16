// Trellis (for hidden markov models)
// a datastructure used to calculate most probable (Viterbi) path 
// or sum of probabilities of all paths (inside probability). 
// The trellis consists of a sequence of observed states O_t, along with
// for each O_t a list of possible hidden states H_t,i. It further 
// represents for each H_t,i the probability of 'generating' O_t. For 
// each H_t,i it further builds a list possible previous states H_t-1,i
// along with an aggregate probability (Viterbi or inside).


class trellis {
  String[] path;
  String startend = "start/end";
  ArrayList<String> goals;
  ArrayList<trellisO> observables;
  ArrayList<htset> setsofhiddens; 
  htset startstate;
  
  trellis(String thepath[], ArrayList<String> thegoals) {
    path = thepath;
    goals = thegoals;
    observables = new ArrayList<trellisO>();
    setsofhiddens = new ArrayList<htset>();
    for (int t=0; t<path.length; t++) {
       trellisO Ot = new trellisO(path[t]);
       observables.add(Ot);
       htset Ht = new htset(goals,Ot);
       setsofhiddens.add(Ht);
    }
  }

  float likelihood() {
    return log(startstate.hiddens.get(0).Inside);   
  }

  void recalculatePOHs(int hiddenindex) {
    for (htset ht : setsofhiddens)
      ht.recalculatePOH(hiddenindex);
  }

  void backwardpass() {
  startstate.hiddens.get(0).bestprevious.backwardpass();
  }   

  void forwardpass() {  
    ArrayList<String> lst = new ArrayList<String>();
    lst.add(startend);
    startstate = new htset(lst,null);
    htset previousht = startstate;
    for (htset ht : setsofhiddens) {
      ht.calculateAggregates(previousht);
      previousht = ht;    
    }
    startstate.calculateAggregates(previousht);
  }
  
  void display(int x, int y, int dx, int dy) {
    for (int t=0; t<observables.size(); t++) {
     observables.get(t).display(x+t*dx,y);
     setsofhiddens.get(t).display(x+t*dx,y+dy,dy);
    }
    startstate.display(x-dx,y+dy,dy);
  }
}

class htset {
  ArrayList<trellisH> hiddens;
  
  htset(ArrayList<String> thegoals,trellisO observable) {
    hiddens = new ArrayList<trellisH>();
    for (int i=0; i<thegoals.size(); i++) {
      trellisH Hti = new trellisH(thegoals.get(i),observable);
      hiddens.add(Hti);
    }
  } 

  void recalculatePOH(int hiddenIndex) {
    hiddens.get(hiddenIndex).setPOH();
  }

  void calculateAggregates(htset previous) {
  for (trellisH H : hiddens) {
      H.calculateAggregates(previous);
  }
  }
  
  void display(int x, int y, int dy) {
   for (int i=0; i<hiddens.size(); i++) {
    hiddens.get(i).display(x,y+i*dy);
   }
  }
}

class trellisH {
  String name;
  float POH, Viterbi, Inside, PHH, PHHofBest;
  boolean onViterbiPathp = false;
  
  // ArrayList<float> PHHs;
  
  trellisH bestprevious = null;
  trellisO observable = null;
  
  
  trellisH(String thename, trellisO theobservable) {
    name = new String(thename);
    observable = theobservable;
    if (observable==null) {Viterbi=0.0; Inside=1.0;POH=0.0;}
    else setPOH();
  }  
  
  void setPOH() {
    POH = calculatePOH(observable.name,name); 
  }
  
//  void setPHHs(htset previous) {
//  }
  
  void calculateAggregates(htset previous) {
    Viterbi = -10000000.0; // log scale
    Inside = 0.0; // nonlog scale 
    for (trellisH previousi : previous.hiddens) {
      if (observable==null) PHH=0.0;
      else PHH = calculatePHH(previousi.name,name,observable.name);
      float dViterbi = previousi.Viterbi + PHH + POH;
      if (dViterbi>Viterbi) {bestprevious = previousi; Viterbi=dViterbi; PHHofBest=PHH;}
      Inside = Inside + previousi.Inside * exp(PHH + POH); // wasteful - we could also multiply with POH only at the end 
    }
    
  }    
  
  void backwardpass() {
    if (name.equals("start/end")) return;
    onViterbiPathp=true;
    bestprevious.backwardpass();
  }
  
  void display(int x, int y) {
    if (onViterbiPathp) fill(256,0,0);
    text(name+"\n"+POH+"\n"+PHHofBest+"\n"+Viterbi+"\n"+log(Inside),x,y);
    fill(256,256,256);
  }
}

class trellisO {
  String name;
  
  trellisO(String thename) {
    name = new String(thename);
  }
  
  void display(int x, int y) {
    text(name,x,y);
  }

}
  

    
