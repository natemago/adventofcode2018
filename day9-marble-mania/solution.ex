defmodule Day9Solution do

    def get_players(n) do
        result = for p <- 1..n, do: 0;
        result
    end

    def ltraverse(marbles, mkey, n, fnext) do
        {lptr, key, val, rptr} = Map.fetch!(marbles, mkey);
        if n == 0 do
            {lptr, mkey, val, rptr}
        else
            ltraverse(marbles, fnext.(lptr, rptr), n - 1, fnext)
        end
    end

    def ltraverse_left(marbles, mkey, n) do
        ltraverse(marbles, mkey, n, fn (l,r) -> l end)
    end

    def linsert_at(marbles, mkey, key, value) do
        {ll, lk, lv, lr} = Map.fetch!(marbles, mkey);
        {rl, rk, rv, rr} = Map.fetch!(marbles, lr);
        n = {lk, key, value, rk};
        marbles = Map.put(marbles, key, n);
        if map_size(marbles) == 2 do
            marbles = Map.put(marbles, mkey, {key, lk, lv, key});
            {marbles, key}
        else
            marbles = Map.put(marbles, mkey, {ll, lk, lv, key});
            marbles = Map.put(marbles, lr, {key, rk, rv, rr});
            {marbles, key}
        end
    end


    def lpop_at(marbles, mkey) do
        {{lptr, mkey, val, rptr}, marbles} = Map.pop(marbles, mkey);
        {ll, lk, lv, lr} = Map.fetch!(marbles, lptr);
        {rl, rk, rv, rr} = Map.fetch!(marbles, rptr);
        marbles = Map.put(marbles, lk, {ll, lk, lv, rk});
        marbles = Map.put(marbles, rk, {lk, rk, rv, rr});
        {marbles, rk}
    end

    def ltraverse_right(marbles, mkey, n) do
        ltraverse(marbles, mkey, n, fn (l,r) -> r end)
    end

    def put_marble(marbles, mkey, mvalue) do
        # works with tuple {leftptr, value, rightptr} - doubly linked list
        if map_size(marbles) == 0 do
            # trivial
            marbles = Map.put(marbles, mkey, {mkey, mkey, mvalue, mkey});
            {marbles, mkey}
        else
            {lptr, key, vak, rptr} = ltraverse_right(marbles, mkey, 1);
            linsert_at(marbles, key, mvalue, mvalue)
        end
    end

    def take_marble(marbles, mkey) do
        #IO.puts(["take_marble: ", Kernel.inspect(mkey)]);
        {lptr, mkey, val, rptr} = Map.fetch!(marbles, mkey);
        # move 7 to the left
        {l, k, v, r} = ltraverse_left(marbles, mkey, 7);
        {marbles, nk} = lpop_at(marbles, k);
        {marbles, nk, v}
    end

    def play_marbles(marbles, players, mhead, curr_m, curr_p, turn, total_turns) do
        if turn > total_turns do
            {marbles, players}
        else
            if (curr_m > 0) and (rem(curr_m, 23) == 0) do
                {marbles, mhead, score} = take_marble(marbles, mhead);

                players = List.update_at(players, curr_p, fn p -> p + score + curr_m end);
                play_marbles(marbles, players, mhead, curr_m + 1, rem(curr_p + 1, length(players)), turn+1, total_turns)
            else
                {marbles, mhead} = put_marble(marbles, mhead, curr_m);
                play_marbles(marbles, players, mhead, curr_m + 1, rem(curr_p + 1, length(players)), turn+1, total_turns )
            end
        end
    end

    def marbles_str(marbles, s, m, i, done, base) do
        {l, k, v, r} = Map.fetch!(marbles, m);
        if s == m and done do
            base
        else
            if i == m do
                
                marbles_str(marbles,s, r, i, true, base <> "(" <> Kernel.inspect(m) <> ") ")
            else
                marbles_str(marbles,s, r, i, true, base <> Kernel.inspect(m) <> " ")
            end
        end
    end

    def main do
        {marbles, players} = play_marbles(Map.new(), get_players(412), 0, 0, 0, 0, 71646);
        IO.puts(["Part 1: ", Kernel.inspect( List.foldl(players, 0, fn (x, acc) -> if x > acc, do: x, else: acc end) )]);
        
        {marbles, players} = play_marbles(Map.new(), get_players(412), 0, 0, 0, 0, 7164600);
        IO.puts(["Part 2: ", Kernel.inspect( List.foldl(players, 0, fn (x, acc) -> if x > acc, do: x, else: acc end) )]);
    end
end