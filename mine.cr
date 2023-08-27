# this loop has about ~60% of the execution time, and it can't really be optimized more
# we can try to prune bad BF programs so this gets called less
# Idea, recursively generate from a parent program and kill all children that will fail?
# Programs that start with ,,, [] ][ +- are all getting tested which wastes tons of time

def evaluate(code : Array(Char), input : Array(Int32))
  max_itrs = 64
  bracemap = buildbracemap(code)
  input.reverse!
  output = [] of Int32
  cells, codeptr, cellptr = [0], 0, 0

  while codeptr < code.size
    max_itrs -= 1
    if (max_itrs == 0)
      return [] of String
    end
    command = code[codeptr]
    case command
      when '>'
        cellptr += 1
        cells << 0 if cellptr == cells.size
      when '<'
        cellptr = Math.max(0, cellptr - 1) 
      when '+'
        cells[cellptr] = (cells[cellptr] + 1) % 255
      when '-'
        cells[cellptr] = (cells[cellptr] - 1) % 255
      when '[' 
        codeptr = bracemap[codeptr] if (cells[cellptr] == 0)   
      when ']'
        codeptr = bracemap[codeptr] if cells[cellptr] != 0
      when '.'
        output << cells[cellptr]
      when ','
        input.size > 0 ? (cells[cellptr] = input.pop) : (return [] of String)
    end
    codeptr += 1
  end
  return output
end

def validBF(code : Array(Char))
  cnt = 0
  # check if parens are matched.
  code.each do |v|
    cnt += 1 if v == '['
    cnt -= 1 if v == ']'
    return false if cnt < 0
  end
  return cnt == 0
end

def buildbracemap(code : Array(Char))
  temp_bracestack, bracemap = [] of Int32, {} of Int32 => Int32
  code.each_with_index do |command, position|
    if command == '['
      temp_bracestack.push(position)
    end
    if command == ']'
      start = temp_bracestack.pop
      bracemap[start] = position
      bracemap[position] = start
    end
  end
  return bracemap
end

def test(prog : Array(Char), constraints : Array(Array(Array(Int32))))
  constraints.each do |v|
    return false if v[1] != evaluate(prog, v[0].clone)
  end
  return true
end

def nex(curr : Array(Char)) : Array(Char)
  i = curr.size - 1
  while i != -1
    # curr was last in base 8 so we need to carry
    if curr[i] == ']'
      curr[i] = '.'
      i -= 1
    else
      curr[i] = nextSymb(curr[i])
      return curr
    end
  end
  curr << '.'
  puts("searching programs of length " +  curr.size.to_s)
  return curr
end

# i tried to use an int8 with bit shift but char comparison is just faster, 
# dunno why 
def nextSymb(inp : Char) : Char
  case inp
    when '.'
      return ','
    when ','
      return '+'
    when '+'
      return '-'
    when '-'
      return '>'
    when '>'
      return '<'
    when '<'
      return '['
    when '['
      return ']'
    when ']'
      return '.'
  end
  return '.'
end

def mine()
  # ur constraints here
  constraints = [
    [ [3], [2] ],
    [ [2], [3] ],
  ]

  curr = ['.']
  while true
    # flush console
    if validBF(curr) && test(curr, constraints)
      return curr.reduce(""){|a,b| a + b}
    else
      curr = nex(curr)
    end
  end
end

print(mine())