from db import DB

database = DB()
try:
	if None == database.insert('hello', 'world', 12, 23, 's'):
		print("OK")
	if None == database.insert('fuck',  'uuuuu', 2, 333, 'b'):
		print("OK")
	result =  database.delete('fuck',  'uuuuu', 'b')
	print(result)
	result = database.delete('j', 'b', 'c')
	print(result)
	database.close()
except Exception as e:
	print(str(e))