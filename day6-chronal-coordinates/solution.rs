use std::fs::File;
use std::io::{BufRead, BufReader};

fn get_input(inpfile:&str) -> Vec<Vec<u64>> {
    let mut inp:Vec<Vec<u64>> = Vec::with_capacity(10);
    let f = File::open(inpfile).expect("file not found");
    
    for line in BufReader::new(f).lines() {
        let ll = line.unwrap();
        let parts = ll.split(", ").collect::<Vec<&str>>();
        let x = parts[0].parse::<u64>().unwrap();
        let y = parts[1].parse::<u64>().unwrap();
        inp.push([x,y].to_vec())
    }

    return inp
}

fn get_bounds(inp:&Vec<Vec<u64>>) -> (u64, u64, u64, u64) {
    let size = inp.len();
    let mut xs:Vec<u64> = Vec::with_capacity(inp.len());
    let mut ys:Vec<u64> = Vec::with_capacity(inp.len());

    for i in 0..size {
        let p = &inp[i];
        xs.push(p[0]);
        ys.push(p[1]);
    }

    xs.sort();
    ys.sort();
    return (xs[0], ys[0], xs[size - 1], ys[size - 1])
}

fn abs(n:i64) -> u64 {
    if n >= 0{
        return n as u64
    }
    return (0-n) as u64
}

fn manhattan_dist(x1:u64, y1:u64, x2:u64, y2:u64) -> u64 {
    return abs(x2 as i64 - x1 as i64) + abs(y2 as i64 - y1 as i64)
}

fn get_nearest(x:u64, y:u64, points:&Vec<Vec<u64>>) -> Vec<usize> {
    let mut res:Vec<usize> = Vec::with_capacity(1);
    let len = points.len();
    let mut dists:Vec<u64> = Vec::with_capacity(len);
    let mut min:u64 = manhattan_dist(x, y, points[0][0], points[0][1]);
    dists.push(min);


    for i in 1..len {
        let dist = manhattan_dist(x, y, points[i][0], points[i][1]);
        if dist <= min {
            min = dist;
        }
        dists.push(dist);
    }

    for i in 0..len {
        if dists[i] == min {
            res.push(i)
        }
    }

    return res
}

fn part1(filename:&str) -> usize {
    let points:Vec<Vec<u64>> = get_input(filename);
    let l = points.len();
    let (x0,y0,x1,y1) = get_bounds(&points);

    let mut nearest_counts:Vec<usize> = Vec::with_capacity(l);
    for _ in 0..l {
        nearest_counts.push(0);
    }

    for i in x0..(x1+1) {
        for j in y0..(y1+1) {
            let mins = get_nearest(i, j, &points);
            if mins.len() == 1 {
                let index = mins[0];
                let p = &points[index];
                if (p[0] == x0) || (p[0] == x1) || (p[1] == y0) || (p[1] == y1) {
                    // on the bounds
                    continue
                }
                nearest_counts[index] = nearest_counts[index] + 1;
            }
        }
    }


    nearest_counts.sort();

    return nearest_counts[nearest_counts.len() - 2]; // There is another point that goes off to infinity
}


fn totaldist(x:u64, y:u64, points:&Vec<Vec<u64>>) -> u64 {
    let mut total:u64 = 0;
    let len = points.len();

    for i in 0..len {
        let p = &points[i];
        total = total + manhattan_dist(x, y, p[0], p[1]);
    }

    return total
}

fn part2(filename:&str) -> u64 {
    let mut count:u64 = 0;
    let points:Vec<Vec<u64>> = get_input(filename);

    let (_, _, x1, y1) = get_bounds(&points);

    for i in 0..(x1+100) { // give it a little bigger bounding box
        for j in 0..(y1+100) { // git it a little bigger bounding box
            let dist = totaldist(i,j, &points);
            
            if dist < 10000 {
                count += 1;
            }
        }
    }

    return count
}



fn main(){
    println!("Part 1: {}", part1("input"));
    println!("Part 2: {}", part2("input"));
}