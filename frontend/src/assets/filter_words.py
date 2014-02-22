from sys import stdin, argv
from random import random

prob = 1.0 if len(argv) <= 1 else eval(argv[1])
for line in stdin:
	printed = False
	for word in line.strip().split():
		if random() < prob:
			printed = True
			print word,
	if printed:
		print