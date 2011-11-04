def RandSmartPass(size = 6)
  a = %w(b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr lt)
  b = %w(0 1 2 3 4 5 6 7 8 9 a e i o u y)
  f, r = true, ''

  (size * 2).times do
    r << (f ? a[rand * a.size] : b[rand * b.size])
    f = !f
  end
  r
end
