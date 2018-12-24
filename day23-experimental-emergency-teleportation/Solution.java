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
            if(sb.r == 0){
                sb.r = 1;
            }
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
                if(min[i] > (bot.pos[i] - bot.r) ){
                    min[i] = (bot.pos[i] - bot.r);
                }
            }
        }

        return min;
    }

    public int[] findBest(int[] around, List<Nanobot> bots, int jiggleScale) {
        int [] bestSoFar = around;
        int bestCoverage = getCoverage(around, bots);
        int bestDist = Teleporation.distance(bestSoFar, new int[] {0,0,0});

        for(int i = 0; i < 10000; i++){
            int [] pos = {
                randInt(bestSoFar[0] - jiggleScale, bestSoFar[0] + jiggleScale),
                randInt(bestSoFar[1] - jiggleScale, bestSoFar[1] + jiggleScale),
                randInt(bestSoFar[2] - jiggleScale, bestSoFar[2] + jiggleScale),
            };

            int cov = getCoverage(pos, bots);
            if(cov > bestCoverage){
                bestCoverage = cov;
                bestDist = Teleporation.distance(pos, new int[]{0,0,0});
                bestSoFar = pos;
            }
        }

        return bestSoFar;
    }

    public int[]getMeanPoint(List<Nanobot> bots){
        int[] mean = {0,0,0};

        for(Nanobot bot: bots){
            for(int i = 0; i < 3; i++){
                mean[i] += bot.pos[i];
            }
        }

        for(int i = 0; i < 3; i++){
            mean[i] /= bots.size();
        }

        return mean;
    }

    public int [] bestSimulatedAnnealing(List<Nanobot> bots){
        int temperature = 10000000;
        int [] bestSoFar = getMeanPoint(bots);

        while(temperature > 0){
            //System.out.println("Current temp: " + temperature);
            bestSoFar = findBest(bestSoFar, bots, temperature);
            temperature /= 10;
        }
        return bestSoFar;
    }

    public int getCoverage(int []point, List<Nanobot> bots) {
        int cov = 0;
        for(Nanobot bot: bots){
            if(bot.isInRange(point)){
                cov++;
            }
        }

        return cov;
    }


    public int randInt(int from, int to){
        int diff = to - from;
        return ((int)(Math.random()*diff)) + from;
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

    // 104703112
    public int part22(String inputFile) throws IOException{
        int [] bestOfAll = null;
        int bestDist = Integer.MAX_VALUE;
        while(true){
            int[]point = bestSimulatedAnnealing(loadInput(inputFile));
            int p = point[0] + point[1] + point[2];
            if(bestOfAll == null){
                bestOfAll = point;
                bestDist = p;
                continue;
            }
            if(p < bestDist){
                p = bestDist;
                bestOfAll = point;
            }
            System.out.println(">curr: " + p);
            System.out.println("Part 2: best so far: " + Arrays.toString(bestOfAll) + " with distance " + bestDist);
        }
        
    }
}



public class Solution {

    public static void main(String[] args) throws IOException{
        Teleporation t = new Teleporation();
        
        System.out.println("Part 1: " + t.part1("input"));
        System.out.println("Part 2: " + t.part22("input"));
    }

}