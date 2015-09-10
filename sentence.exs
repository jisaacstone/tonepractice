[file_name] = System.argv

processinput = fn
  ("\n", _, _, result) -> result
  ("q" <> _, _, _, _) -> exit(:normal)
  (input, [{tones,pinyin}|tail], lp, {correct,total}) ->
    size = byte_size(tones)
    case String.split_at(input, size) do
      {^tones, rest} ->
        IO.write(" \e[32m#{pinyin}\e[m")
        lp.(rest, tail, lp, {correct + size, total + size})
      {_, rest} ->
        IO.write(" \e[31m#{pinyin}\e[m")
        lp.(rest, tail, lp, {correct, total + size})
    end
  (_, _, _, _) -> exit(:oops)
  end

getuserinput = fn
  (tonedata) ->
    processinput.(IO.gets("\e[33m>\e[37m"), tonedata, processinput, {0,0})
  end

loop = fn
  ([], score, _) -> score
  ([{hanzi, tonedata, english}|t], score, lp) ->
    IO.write("\e[37m#{hanzi}\e[m\n")
    result = getuserinput.(tonedata)
    IO.write("\n#{english}\n")
    lp.(t, [result|score], lp)
  end

:random.seed(:erlang.now)
data = File.read!(file_name) |>
  String.split("\n\n") |>
  Stream.map(fn(str) ->
    [hanzi, tones, pinyin, english|_] = String.split(str, "\n")
    { Regex.replace(~r/\s+/, hanzi, " "),
      Enum.zip(String.split(tones), String.split(pinyin)),
      english } end) |>
  Enum.shuffle()

score = loop.(data, [], loop)
IO.inspect(score)
