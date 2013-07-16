ArrayList<String> candidate_subgoals; 

class subgoalanalysis {
  String[] thepath;
  String goals[]      = {"1110","1112","1111","0000","0002","0001","2220","2222","2221"};
  String confusions[] = {"2220","0002",null,null,"1112","2221","1110",null,"0001"};
  boolean[] onshortestpath;
  
  subgoalanalysis() {
    
  //  println("Nice one!\n");
  }
  
  void performsubgoalanalysis() {
    ArrayList<Integer> shortest_path;
    ArrayList<String> subgoal_sequence;
    ArrayList<Integer> subgoal_sequence_indices;
    ArrayList<String> confusion_sequence;

    shortest_path = s[start].shortest_path_to(end);
    subgoal_sequence = new ArrayList<String>();
    subgoal_sequence_indices = new ArrayList<Integer>();
    confusion_sequence = new ArrayList<String>();
    
    // create sequence of subgoals and confusions
    for (int i=1; i<shortest_path.size()-1; i++) { 
      // iterate over shortest path without start & goal state
      for (int k=0; k<goals.length; k++) {
        if (goals[k].equals(s[shortest_path.get(i)].name)) {
          s[shortest_path.get(i)].subgoal_onshortestpathp=true; // for diplay purposes
          if (confusions[k]!=null) s[calc_index(confusions[k])].subgoal_onshortestpathp=true; // for diplay purposes
          subgoal_sequence.add(goals[k]);        // add state to list of subgoals
          subgoal_sequence_indices.add(shortest_path.get(i));
          if (confusions[k]!=null) confusion_sequence.add(confusions[k]); // add confusion to list of confusions
          subgoal_sequence_indices.add(calc_index(confusions[k]));
           }
      }
    }
    
    subgoal_sequence.add(paths[j].substring(0,4)); // add ultimate goal to list of subgoals
    
    // create the sequence of observable states for the trellis: moves = pairs of Hanoi-states     
    thepath = new String[path.length-1];
    for (int i=1; i<path.length; i++) thepath[i-1]=path[i-1]+path[i];

    // create the trellis, and recalculate POH for every subgoal
    candidate_subgoals = new ArrayList<String>();
    candidate_subgoals.addAll(subgoal_sequence);
    candidate_subgoals.addAll(confusion_sequence);
    
    thetrellis = new trellis(thepath,candidate_subgoals);
    for (int g=0; g<candidate_subgoals.size(); g++) {
      int subgoal = calc_index(candidate_subgoals.get(g));
      s[subgoal].percolate_shortest_path(subgoal);
      thetrellis.recalculatePOHs(g);
    }

    // reset state-space and determine features of subgoals for calculating PHH 
    s[end].percolate_shortest_path(end);
    
    thetrellis.forwardpass();
    thetrellis.backwardpass();
  }

  float likelihood() {
    return thetrellis.likelihood();
  }
}
  
float calculatePOH(String observable, String hidden) {
  float POH = s[calc_index(observable.substring(0,4))].lloptimal(calc_index(observable.substring(4,8)));
  return POH;
}

float calculatePHH(String previous, String current, String observable) {
  String observable1 = observable.substring(0,4);
  // *** if observable1==previous - subgoal reached
  // 0.0 if current==previous - will move to next subgoal
  // pcorrect if current==nextsubgoal()
  // (1-pcorrect)/N if current is one of N possible confusions
  
  // *** if observable1!=previous && previous !in confusions - correct subgoal not yet reached
  // premain if current==previous
  // (1-premain)/M if current is one of M alternatives (next subgoal + its confusions)
  // *** if observable1!=previous && previous in confusions - incorrect subgoal not yet reached
  // Let: p*=pregret^#steps-from-observable-to-previous
  // 1-p* if current==previous
  // p*/L if current is one of L alternatives (correct subgoal, next subgoal + its confusions)
  
  if (previous.equals("start/end")) return log(1.0/ candidate_subgoals.size());
  if (current.equals("start/end")) return 0.0; 
  if (candidate_subgoals.size()==1) return 0.0;
  if (previous.equals(observable1) && previous.equals(current)) return log(0.000001); // subgoal reached
  if (!previous.equals(observable1) && previous.equals(current)) return log(0.8); // remain
  if (previous.equals(observable1) && !previous.equals(current)) return log(0.999999 / (candidate_subgoals.size()-1)); // subgoal reached
  else return log(0.2 / (candidate_subgoals.size()-1)); 
  
  // subject 1004, item 19
  
}


