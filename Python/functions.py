import sys, time

def slowprint(s):
	for c in s + '\n':
		sys.stdout.write(c)
		sys.stdout.flush()
		time.sleep(1./25) #change the denominators value to change type speed

def inputBracket(text:str):
	inp = input(f"{text}\n>>> ")
	return inp