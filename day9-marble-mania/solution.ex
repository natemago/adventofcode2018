defmodule Day9Solution do

  def get_players(n) do
    result = for p <- 1..n, do: 0;
    result
  end

  def put_marble(m, i, marbles) do
    if length(marbles) < 2 do
      marbles = marbles ++ [m];
      {length(marbles) - 1, marbles}
    else
        i = rem((i+2),length(marbles));
        {i, List.insert_at(marbles, i, m)}
    end
  end


  def take_marble(m, i, marbles) do
    ii = if (i - 7) < 0, do: (i + length(marbles)) - 7, else: i - 7;
    {pp, marbles} = List.pop_at(marbles, ii);
    {rem(ii, length(marbles)), pp + m, marbles}
  end

  def print_marbles(marbles, i) do
    idxs = for x <- 1..length(marbles), do: x-1;
    Enum.join(Enum.map(Enum.zip(idxs, marbles), fn {idx, c} -> if i == idx, do: Enum.join(["(", c, ")"], ""), else: c end), " ")
  end

  def play_marbles(marbles, players, cp, cm, i, turn, total_turns) do
    #IO.puts [ Kernel.inspect(turn), ". ", Kernel.inspect(cp), ": ", print_marbles(marbles, i)];
    if rem(turn, 1000) == 0 do
      IO.puts [ Kernel.inspect(turn), ". ", Kernel.inspect(cp), ": ..."];
    end
    if turn == total_turns do
      {marbles, players}
    else
      if rem(cm, 23) == 0 do
        {ni, score, marbles} = take_marble(cm, i, marbles);
        players = List.update_at(players, cp, fn p -> p + score end);
        cp = rem(cp + 1, length(players));
        play_marbles(marbles, players, cp, cm + 1, ni, turn + 1, total_turns)
      else
        {ni, marbles} = put_marble(cm, i, marbles);
        play_marbles(marbles, players, rem(cp+1, length(players)), cm + 1, ni, turn + 1, total_turns)
      end
    end
  end
  
  def main do
    {marbles, players} = play_marbles([0], get_players(412), 0, 1, 0, 1, 71646);
    #{marbles, players} = play_marbles([0], get_players(9), 0, 1, 0, 1, 25);
    IO.puts (["Part 1: ", Enum.join(players, ", ")]);
    IO.puts(["Part 1: ", Kernel.inspect( List.foldl(players, 0, fn (x, acc) -> if x > acc, do: x, else: acc end) )]);
  end
end
