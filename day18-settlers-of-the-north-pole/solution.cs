using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class AreaMap {

    private string [][] cells;

    public void LoadMap(string filename) {
        StreamReader sr = new StreamReader(filename);
        string line;
        List<String[]> matrix = new List<String[]>();

        while ((line = sr.ReadLine()) != null) {
            line = line.Trim();
            string [] row = new string[]{};
            foreach (Char c in line){
                row = row.Concat(new string[]{c.ToString()}).ToArray();
            }
            matrix.Add(row);
        }
        this.cells = matrix.ToArray();
    }

    public void PrintMap(){
        foreach(string [] row in this.cells){
            Console.WriteLine(String.Join("", row));
        }
    }

    private List<String> getAdjacent(int x, int y, string[][] state) {
        var neigboursPoints = new[]{(x-1,y-1),(x,y-1),(x+1,y-1),
                                    (x-1,y),(x+1,y),
                                    (x-1,y+1),(x,y+1),(x+1,y+1)};
        List<String> neighbours = new List<String>();
        foreach ((var i, var j) in neigboursPoints){
            if(i >= 0 && i < state[0].Length && j >= 0 && j < state.Length) {
                neighbours.Add(state[j][i]);
            }
        }
        // Console.WriteLine("Neighbours at: {0:D}, {1:D} are " + String.Join(",", neighbours),x,y);
        return neighbours;
    }

    private List<String> getAdjacent_nope(int x, int y, string[][] state) {
        var neigboursPoints = new[]{(x,y-1),(x-1,y),(x+1,y),(x,y+1)};
        List<String> neighbours = new List<String>();
        foreach ((var i, var j) in neigboursPoints){
            if(i >= 0 && i < state[0].Length && j >= 0 && j < state.Length) {
                neighbours.Add(state[j][i]);
            }
        }
        return neighbours;
    }

    private int count(List<String> list, string tp) {
        int c = 0;
        foreach(string s in list){
            if (s == tp){
                c++;
            }
        }
        return c;
    }

    private int countInCells(string tp){
        int i = 0;
        foreach(String [] row in this.cells){
            foreach(String cell in row){
                if (cell == tp) {
                    i++;
                }
            }
        }
        return i;
    }

    private String[][] copyCells(){
        List<String[]> copy = new List<String[]>();
        foreach (String[] row in this.cells) {
            string[] cpr = new string[row.Length];
            for(var i = 0; i < row.Length; i++){
                cpr[i] = row[i];
            }
            copy.Add(cpr);
        }
        return copy.ToArray();
    }

    public void NextState(){
        var currState = this.copyCells();

        for(var y = 0; y < currState.Length; y++) {
            var row = currState[y];

            for(var x = 0; x < row.Length; x++) {
                var cell = row[x];
                //var neighbours = this.getNeightbours(x,y, currState);
                // Console.WriteLine(" :: " + x + " | " + y);
                var adjacent = this.getAdjacent(x,y, currState);

                if (cell == ".") {
                    // empty lot
                    if (this.count(adjacent, "|") >= 3) {
                        this.cells[y][x] = "|";
                    }
                }else if (cell == "#") {
                    // lumber
                    if (this.count(adjacent, "#") >= 1 && this.count(adjacent, "|") >= 1){
                        // remains lumber
                    }else{
                        this.cells[y][x] = ".";
                    }
                }else {
                    // trees
                    if (this.count(adjacent, "#") >= 3) {
                        this.cells[y][x] = "#";
                    }
                }

            }
        }
    }

    private string foldMap() {
        string res = "";
        foreach(string [] row in this.cells){
            res += String.Join("", row);
        }
        return res;
    }

    public void Part1(){
        for(var i = 0; i < 10; i++){
            this.NextState();
        }
        Console.WriteLine("Part 1: " + (this.countInCells("|") * this.countInCells("#")));
    }

    public void Part2(){
        var seen = new Dictionary<String, int>();
        var minute = 0;
        var firstRep = -1;
        var initState = this.copyCells();
        while(true){
            minute++;
            this.NextState();
            var state = this.foldMap();
            if (seen.ContainsKey(state)){
                firstRep = seen[state];
                break;
            }
            
            seen.Add(state, minute);
        }
        var cycleLength = minute-firstRep;
        var totalInCycle = 1000000000 - (firstRep - 1);

        var totalReps = (totalInCycle % cycleLength)-1;
        
        for (var  i =0; i < totalReps; i++) { 
            this.NextState();
        }
        Console.WriteLine("Part 2: " + (this.countInCells("|") * this.countInCells("#")));
    }

    static public void Main(){
        AreaMap am = new AreaMap();
        am.LoadMap("input");
        am.Part1();
        am.Part2();
    }
}