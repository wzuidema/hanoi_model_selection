
// -1/1 in the following function is there to skip goal state in the coloring
void set_path() {
  newitemp=true;
  
  start = calc_index(paths[j].substring(4,8));
  end = calc_index(paths[j].substring(0,4));

  for (int k=0; k<81; k++) {
    s[k].clear(); }

  path = new String[-1+paths[j].length()/4];
  for (int i=1; i<paths[j].length()/4; i++) {
    path[i-1] = new String(paths[j].substring(i*4,4+i*4));
    s[calc_index(path[i-1])].activep=true;
  }
  
  analysis.performsubgoalanalysis();
  analysis2.performsubgoalanalysis();
  // (assumes path variable is set)
}

void read_datalines() {
  names = new String[datalines.length];  
  paths = new String[datalines.length];  

   num_paths=0;
   names[num_paths] = new String("");
   for (int l=0; l<datalines.length; l++) { 
     int num_commas=0, begin_entry=0;
//     println(datalines[l]+";"+l+";"+num_paths);
     if (datalines[l].length()>6 
       && datalines[l].charAt(0)!=','
       && datalines[l].charAt(0)!='#' 
       && !datalines[l].substring(0,7).equals("Subject"))
       for (int c=0; c<datalines[l].length(); c++) {    
          if (datalines[l].charAt(c)==',') {
            num_commas++;
            if (num_commas==2) {
              if (num_paths==0 || !datalines[l].substring(begin_entry,c).equals(names[num_paths-1])) {
                num_paths++;
                names[num_paths-1] = new String(datalines[l].substring(begin_entry,c)); 
                if (huizingap) paths[num_paths-1] = new String(huizinga[(num_paths-1)%huizinga.length]);  
                else paths[num_paths-1] = new String("");  
            }}  
            if (num_commas==7) {
              //println(datalines[l]+"#"+c);
                if (datalines[l].length()<c+8) println("invalid: "+datalines[l]);
                paths[num_paths-1] = new String(paths[num_paths-1] 
                  + (datalines[l].charAt(c+1)-first_peg)
                  + (datalines[l].charAt(c+3)-first_peg) 
                  + (datalines[l].charAt(c+5)-first_peg) 
                  + (datalines[l].charAt(c+7)-first_peg)); }
        }
     } 
   }
}         


