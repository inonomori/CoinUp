import sys
import sqlite3
import logging

from conf import dbname, dblogfile

logging.basicConfig(filename=dblogfile,level=logging.DEBUG,format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")


class DB(object):
	def __init__(self):
		super(DB, self).__init__()
		try:
			self.reconnect()
		except Exception as e:
			logging.critical(str(e))
			sys.exit(0)
	
	def insert(self, token, platform, low, high, language):
		if type(token) is not str or len(token) != 64:
			logging.critical('the token is not str')
			raise TypeError("the token is not str")
		if type(platform) is not str:
			logging.critical('the platform is not str')
			raise TypeError("The platform is not str")
		if type(low) is str:
			try:
				low = float(low)
			except Exception:
				low = low.replace('$', '')
				try:
					low = float(low)
				except Exception as e:
					logging.critical(str(e))
					raise TypeError("low")	
		if type(high) is str:
			try:
				high = float(high)
			except Exception:
				high = high.replace('$', '')
				try:
					high = float(high)
				except Exception as e:
					logging.critical(str(e))
					raise TypeError("high")	
		if type(language) is not str:
			logging.critical('the language is not str')
			raise TypeError("The language is not str")
		command = "insert into push values ('{token}', '{platform}', {low}, {high}, '{language}');"
		command = command.format(token = token, platform = platform, low=low, high = high, language=language)
		try:
			logging.info(command)
			result = self.handle.execute(command)
			if result.rowcount == 1:
				result.close()
				self.handle.commit()
				return None
		except Exception as e:
			logging.critical(str(e))
			raise RuntimeError(str(e))

	def delete(self, token, platform, low_or_high):
		command = "update push set {low_or_high} = -1 where token='{token}' and platform='{platform}';"
		command = command.format(token = token, platform=platform, low_or_high = low_or_high)
		try:
			logging.info(command)
			result = self.handle.execute(command)
			result.close()
		except Exception as e:
			logging.critical(str(e))
			raise RuntimeError(str(e))
		try:
			result = self.handle.execute("delete from push where low < 0 and high < 0;")
			self.handle.commit()
			result.close()
		except Exception as e:
			logging.info(str(e))

	def close(self):
		self.handle.close()

	def reconnect(self):
		self.handle = sqlite3.Connection(dbname)
		try:
			self.handle.execute('''create table if not exists push (token char(64), platform varchar(32), low float, high float,  language varchar(32));''')
		except Exception as e:
			logging.critical(str(e))
			raise RuntimeError("Can't connect to the db")

	def exists(self, token, platform):
		command = '''select 1 from push where token='{token}' and platform='{platform}';'''
		try:
			logging.info(command)
			result = self.handle.execute(command)
		except Exception as e:
			logging.critical(str(e))
			return RuntimeError(str(e))
		t = result.fetchone()
		if t is None:
			return False
		return True


	def update(self, token, platform, dictionary):
		for key in dictionary:
			command = '''update push set {key}={value} where token='{token}' and platform='{platform}';'''
			if type(dictionary[key]) is str:
				dictionary[key] = "'" + dictionary[key] + "'"
			command = command.format(key = key, value = dictionary[key], token = token, platform = platform)
			try:
				logging.info(command)
				result = self.handle.execute(command)
				self.handle.commit()
				result.close()	
			except Exception as e:
				logging.critical(str(e))
				raise RuntimeError(str(e))

	def find(self, platform, price, compare):
		if price < 0:
			return []
		if type(price) is not float:
			raise TypeError("the type of price is error")
		if compare == 'b':
			command = '''select * from push where platform='{platform}' and high > 0 and high < {price};'''
			command = command.format(platform=platform, price = price)
		elif compare == 's':
			command = '''select * from push where platform='{platform}' and low > 0 and low > {price};'''
			command = command.format(platform=platform, price = price)
		try:
			result = self.handle.execute(command)
		except Exception as e:
			logging.info(str(e))
			raise RuntimeError(str(e))
		return result.fetchall()

	def get_price(self, token, platform):
		command = '''select low, high from push where token = '{token}'' and platform = '{platform}';'''
		command = command.format(token=token, platform=platform)
		try:
			result = self.handle.execute(command)
			price = result.fetchone()
			dict_price = dict()
			dict_price['low'] = price[0]
			dict_price['high'] = price[1]
			return dict_price
		except Exception as e:
			logging.critical(str(e))
			raise RuntimeError(str(e))