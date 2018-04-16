#
# PA 1
# RJ Martinez
# 2/8/18
#

# Find integers s and t such that gcd(a,b) = s*a + t*b
# pre: a,b >= 0
# post: return gcd(a,b), s, t
def egcd(a, b)
  # let A, B = a, b   
  s, t, u, v = 1, 0, 0, 1
  while 0 < b
    # loop invariant: a = sA + tB and b = uA + vB and gcd(a,b) = gcd(A,B)
    q = a/b
    a, b, s, t, u, v = b, (a%b), u, v, (s-u*q), (t-v*q)   
  end   
return [a, s, t] 
end

def encrypt(a, b, infile, outfile)
  if a.gcd(128) != 1 && a.gcd(b) != 1
    return puts "The key pair (#{a}, #{b}) is invalid, please select another key"
  end
  out = File.open(outfile, 'w')
  File.foreach(infile) do 
    |line| line.chars.each do 
	  |c|
	  tempchar = c.each_byte.to_a[0].to_i
	  temp = (a*tempchar + b) % 128
	  out.write("#{temp.chr}")
	end
  end
  out.close
end

def decrypt(a, b, infile, outfile)
  if a.gcd(128) != 1 && a.gcd(b) != 1
    return puts "The key pair #{a}, #{b} is invalid, please select another key"
  end
  arr = egcd(a, 128)
  out = File.open(outfile, 'w')
  File.foreach(infile) do 
    |line| line.chars.each do 
	  |c|
	  tempchar = c.each_byte.to_a[0].to_i
	  temp = (((arr[1]) % 128) * (tempchar - b)) % 128
	  out.write("#{temp.chr}")
	end
  end
  out.close
end

def decipher(infile, outfile, f)
	arr_ab = (1..127).to_a.permutation(2).to_a.select{|x| x[0].gcd(128) == 1 && x[0].gcd(x[1]) == 1}
	max_words, a, b = 0, 0, 0
	df, inf = File.open(f, "r+"), File.open(infile, "r+")
	dict = File.readlines(df).map { |w| w.chomp.downcase }.uniq
	h = Hash[dict.collect { |m| [m, m] }]
	arr_ab.each do
	  |t| decrypt(t[0], t[1], infile, outfile)
	  count = count_words(outfile, h)
	  if count > max_words then a, b, max_words = t[0], t[1], count end
	end
	decrypt(a, b, infile, outfile)
	f = File.open(outfile, "r+")
	lines = f.readlines
	f.close
	lines = ["#{a} #{b}\nDECRYPTED MESSAGE:\n"] + lines
	output = File.new(outfile, "w")
	lines.each { |line| output.write line }
	output.close
end

def count_words(file, hsh)
  count = 0
  f = File.open(file, "r+")
  lines = f.readlines
  lines.each{|line| count += line.split.select{|i| i.size > 3 && hsh.include?(i.downcase)}.size}
  f.close
  return count
end

if ARGV[0] == "encrypt"
  encrypt(ARGV[3].to_i, ARGV[4].to_i, ARGV[1].to_s, ARGV[2].to_s)
elsif ARGV[0] == "decrypt" 
  decrypt(ARGV[3].to_i, ARGV[4].to_i, ARGV[1].to_s, ARGV[2].to_s)
elsif ARGV[0] == "decipher"
  decipher(ARGV[1].to_s, ARGV[2].to_s, ARGV[3].to_s)
end
