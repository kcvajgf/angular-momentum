from sys import *
s = set()
def good(ch):
	o = ord(ch)
	return 9 <= o <= 10 or 32 <= o <= 126
	
for line in stdin:
	print ''.join(ch for ch in line if good(ch))
