# -*- coding: utf-8 -*-

def is_number txt
  return !!(/^[0-9]+$/ =~ txt)
end

def calc_control_number number 
  weight_arr = [2,3,4,5,6,7,2,3,4,5,6,7,2,3,4,5,6,7]
  sum = 0
  (0...number.length).each {|idx|
    digit = number[idx].ord - '0'[0].ord
    weight = weight_arr[number.length - idx -1] 
    sum = sum + digit*weight
#    puts "Idx #{idx}, digit #{digit}, weight #{weight}"
  }
#  puts "Sum is #{sum}"
  rest = 11 - (sum % 11)
#  puts rest

  if rest == 11
    return 0
  end

  if rest == 10
    return '-'
  end

  return rest  
end

def check_norwegian_account account
  if account.length < 5
    return false
  end
  if !is_number account
    return false
  end
  number = account[0..(account.length-2)]
  return account[-1].ord-'0'[0].ord == calc_control_number(number)
end

def calc_norwegian_id1 number
  base = '0'[0].ord
  d1 = number[0].ord - base
  d2 = number[1].ord - base
  m1 = number[2].ord - base
  m2 = number[3].ord - base
  y1 = number[4].ord - base
  y2 = number[5].ord - base
  i1 = number[6].ord - base
  i2 = number[7].ord - base
  i3 = number[8].ord - base
  k1 = 11 - ((3 * d1 + 7 * d2 + 6 * m1 + 1 * m2 + 8 * y1 + 9 * y2 + 4 * i1 + 5 * i2 + 2 * i3) % 11)
  if k1 == 11
    return 0
  end
  return k1
end

def calc_norwegian_id2 number
  base = '0'[0].ord
  d1 = number[0].ord - base
  d2 = number[1].ord - base
  m1 = number[2].ord - base
  m2 = number[3].ord - base
  y1 = number[4].ord - base
  y2 = number[5].ord - base
  i1 = number[6].ord - base
  i2 = number[7].ord - base
  i3 = number[8].ord - base
  k1 = number[9].ord - base
  k2 = 11 - ((5 * d1 + 4 * d2 + 3 * m1 + 2 * m2 + 7 * y1 + 6 * y2 + 5 * i1 + 4 * i2 + 3 * i3 + 2 * k1) % 11)
  if k2 == 11
    return 0
  end
  return k2
end

def check_norwegian_id_number number
  if !is_number number
    return false
  end

  if number.length != 11
    return false
  end
  
  k1 = calc_norwegian_id1(number[0..(number.length-3)])
  k2 = calc_norwegian_id2(number[0..(number.length-2)])
  if (k1 == 10) || (k2 == 10)
    return false
  end
  return k1 == (number[-2].ord-'0'[0].ord) && k2 == (number[-1].ord-'0'[0].ord)
end

