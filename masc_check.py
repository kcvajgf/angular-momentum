from sys import *
s = set()
for line in stdin:
	for ch in line:
		s.add(ch)

print sorted(map(ord, s))
print ''.join(sorted(s, key=ord))
print ''.join(sorted((t for t in s if ord(t) == 9 or ord(t) == 10 or 32 <= ord(t) < 127), key=ord))
print sorted(map(ord, sorted((t for t in s if ord(t) == 9 or ord(t) == 10 or 32 <= ord(t) < 127), key=ord)))

