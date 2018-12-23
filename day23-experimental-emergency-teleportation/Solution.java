import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;



class Nanobot {
    public int[] pos;
    public int r;

    public String toString(){
        return Arrays.toString(pos) + " " + r;
    }

    public int distanceTo(Nanobot other) {
        return Math.abs(pos[0] - other.pos[0]) + 
                Math.abs(pos[1] - other.pos[1]) +
                Math.abs(pos[2] - other.pos[2]);
    }

    public int distanceTo(int[] o) {
        return Math.abs(pos[0] - o[0]) + 
                Math.abs(pos[1] - o[1]) +
                Math.abs(pos[2] - o[2]);
    }

    public boolean isInRange(Nanobot other){
        return distanceTo(other) <= r;
    }

    public boolean isInRange(int[] other){
        return distanceTo(other) <= r;
    }

}

class Pair<F,S> {
    public F first;
    public S second;

    public Pair(F first, S second){
        this.first = first;
        this.second = second;
    }
}


class Teleporation {
    public static int distance(int[]p1, int[]p2){
        int d = 0;
        for(int i = 0; i < p1.length; i++){
            d += Math.abs(p1[i] - p2[i]);
        }
        return d;
    }
    public List<Nanobot> loadInput(String filename) throws IOException{
        List<Nanobot> bots = new ArrayList<Nanobot>();

        BufferedReader brr = new BufferedReader(new FileReader(filename));
        String line = null;
        Pattern pattern = Pattern.compile("pos=<([-\\d]+),([-\\d]+),([-\\d]+)>, r=(\\d+)");
        while((line = brr.readLine()) != null ){
            line = line.trim();
            Matcher m = pattern.matcher(line);
            if (!m.matches()){
                throw new RuntimeException("Failed to parse line: " + line);
            }
            Nanobot bot = new Nanobot();
            bot.pos = new int[]{
                Integer.parseInt(m.group(1)),
                Integer.parseInt(m.group(2)),
                Integer.parseInt(m.group(3)),
            };
            bot.r = Integer.parseInt(m.group(4));

            bots.add(bot);
        }
        brr.close();
        return bots;
    }

    public List<Nanobot> getWithScale(List<Nanobot> bots, int scale){
        List<Nanobot> scaled = new ArrayList<>();
        for(Nanobot bot: bots){
            Nanobot sb = new Nanobot();
            sb.r = bot.r/scale;
            sb.pos = new int []{
                bot.pos[0]/scale,
                bot.pos[1]/scale,
                bot.pos[2]/scale
            };
            scaled.add(sb);
        }
        return scaled;
    }


    public int[] getMax(List<Nanobot> bots){
        int[]max = new int []{Integer.MIN_VALUE, Integer.MIN_VALUE, Integer.MIN_VALUE };
        
        for(Nanobot bot: bots){
            for(int i = 0; i < 3; i++){
                if(max[i] < (bot.pos[i] + bot.r) ){
                    max[i] = (bot.pos[i] + bot.r);
                }
            }
        }

        return max;
    }

    public int[] getMin(List<Nanobot> bots){
        int[]min = new int []{Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE };
        
        for(Nanobot bot: bots){
            for(int i = 0; i < 3; i++){
                if(min[i] > (bot.pos[i] + bot.r) ){
                    min[i] = (bot.pos[i] + bot.r);
                }
            }
        }

        return min;
    }


    public Pair<Integer, List<int[]>> getClosestPoint(int[]from, int[]to, List<Nanobot> bots){
        System.out.println("getClosestPoint: " + Arrays.toString(from) + " => " + Arrays.toString(to));
        int []closest = null;
        int rangecount = 0;
        List<int[]>possibleQuadrants = new ArrayList<>();
        for(int x = from[0]; x <= to[0]; x++){
            for(int y = from[1]; y <= to[1]; y++){
                for(int z = from[2]; z <= to[2]; z++){
                    int inRangeOf = 0;
                    int []p = new int[]{x,y,z};
                    for(Nanobot bot: bots){
                        if(bot.isInRange(p)){
                            inRangeOf++;
                        }
                    }
                    if(closest == null || inRangeOf >= rangecount){
                        closest = p;
                        rangecount = inRangeOf;
                        continue;
                    }
                }
            }
        }

        for(int x = from[0]; x <= to[0]; x++){
            for(int y = from[1]; y <= to[1]; y++){
                for(int z = from[2]; z <= to[2]; z++){
                    int inRangeOf = 0;
                    int []p = new int[]{x,y,z};
                    for(Nanobot bot: bots){
                        if(bot.isInRange(p)){
                            inRangeOf++;
                        }
                    }
                    if(inRangeOf == rangecount && 
                        Teleporation.distance(p, new int[]{0,0,0}) == Teleporation.distance(closest, new int[]{0,0,0,})){
                        possibleQuadrants.add(p);
                    }
                }
            }
        }

        return new Pair(rangecount, possibleQuadrants);
    }

    public int[] getClosestPointVolumeSubdivide(List<Nanobot> nanobots){
        int scale = 10000000;
        int closest[] = null;
        List<Nanobot> bots = getWithScale(nanobots, scale);
        int []from = getMin(bots);
        int []to = getMax(bots);
        List<int[][]> exploreNext = new ArrayList<>();
        
        exploreNext.add(new int[][]{from, to});
        while(scale > 0){
            System.out.println("Scale: " + scale + ", have " + exploreNext.size() + " to explore next.");
            List<Pair<Integer, List<int[]>>> possibilites = new ArrayList<>();
            for(int[][] ex: exploreNext){
                Pair<Integer, List<int[]>> p = getClosestPoint(ex[0], ex[1], bots);
                possibilites.add(p);
            }

            possibilites.sort(new Comparator<Pair<Integer, List<int[]>>>() {
                public int compare(Pair<Integer,List<int[]>>p1 ,Pair<Integer,List<int[]>> p2){
                    if(p1.first == p2.first){
                        return Teleporation.distance(p1.second.get(0), new int []{0,0,0}) - Teleporation.distance(p2.second.get(0), new int []{0,0,0});
                    }
                    return p2.first - p1.first;
                }
            });

            exploreNext = new ArrayList<>();
            for(Pair<Integer, List<int[]>>poss: possibilites){
                System.out.println("Coverage by: " + poss.first);
                if(poss.first < possibilites.get(0).first){
                    continue;
                }
                for(int [] c: poss.second){
                    exploreNext.add(new int[][]{
                        {
                            c[0]*10,
                            c[1]*10,
                            c[2]*10,},
                        {
                            (c[0]+1)*10,
                            (c[1]+1)*10,
                            (c[2]+1)*10,
                        }
                    });
                }
            }
            
            scale /= 10;
            if(scale != 0){
                bots = getWithScale(nanobots, scale);
            }
            if(scale == 0){
                closest = possibilites.get(0).second.get(0);
                int f[] = possibilites.get(possibilites.size() -1 ).second.get(0);
                System.out.println("Closest dist: " + (closest[0] + closest[1] + closest[2]));
                System.out.println("Alternative: " + Arrays.toString(f) + "; " + (f[0] + f[1] + f[2]));
            }
        }

        return closest;
    }


    public int part1(String inputFile) throws IOException{
        List<Nanobot> bots = loadInput(inputFile);
        Nanobot maxRadius = null;
        for (Nanobot bot : bots) {
            if(maxRadius == null || maxRadius.r < bot.r){
                maxRadius = bot;
            }
        }
        int inRange = 0;
        for (Nanobot bot : bots) {
            if(maxRadius.isInRange(bot)){
                inRange++;
            }
        }
        return inRange;
    }

    public int part2(String inputFile) throws IOException{
        int [] closest = getClosestPointVolumeSubdivide(loadInput(inputFile));
        return closest[0] + closest[1] + closest[2];
    }
}



public class Solution {

    public static void main(String[] args) throws IOException{
        Teleporation t = new Teleporation();
        
        System.out.println("Part 1: " + t.part1("input"));
        System.out.println("Part 2: " + t.part2("input"));
    }

}