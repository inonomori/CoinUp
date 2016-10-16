import os
import sys
import time
import threading

import tornado.ioloop
import tornado.web

from grap import *
from db import DB

global _cache
_cache = dict()


class All(tornado.web.RequestHandler):
	def get(self):
		global _cache
		self.set_header('Content-Type', 'application/json')
		self.write(json.dumps(_cache))

# class Okcoin(tornado.web.RequestHandler):
# 	def get(self):
# 		global _cache
# 		self.write(_cache.get('okcoin', -1))

# class Chbtc(tornado.web.RequestHandler):
# 	def get(self):
# 		global _cache
# 		self.write(_cache.get('chbtc', -1))

# class Btctrade(tornado.web.RequestHandler):
# 	def get(self):
# 		global _cache
# 		self.write(_cache.get('btctrade', -1))

# class Fxbtc(tornado.web.RequestHandler):
# 	def get(self):
# 		global _cache
# 		self.write(_cache.get('fxbtc', -1))

# class Mtgox(tornado.web.RequestHandler):
# 	def get(self):
# 		global _cache
# 		self.write(_cache.get('mtgox', -1))

# class Btc100(tornado.web.RequestHandler):
# 	def get(self):
# 		global _cache
# 		self.write(_cache.get('btc100', -1))

# class Btcchina(tornado.web.RequestHandler):
# 	def get(self):
# 		global _cache
# 		self.write(_cache.get('btcchina', -1))

class GetPrice(tornado.web.RequestHandler):
	def get(self):
		global _cache
		platform = self.get_argument('platform')
		self.write(str(_cache.get(platform, -1)))


class Query(tornado.web.RequestHandler):
	def initialize(self):
		self.webdatabase = DB()

	def get(self):
		token = self.get_argument('token', None)
		platform = self.get_argument('platform', None)
		self.set_header('Content-Type', 'application/json')
		if token and platform:
			price = dict()
			price['low'] = 0
			price['high'] = 0
			self.write(json.dumps(price))
		else:
			try:
				price = self.webdatabase.get_price(token, platform)
				if price['low'] < 0:
					price['low'] = 0
				if price['high'] < 0:
					price['high'] = 0
				self.write(json.dumps(price))
			except Exception:
				price = dict()
				price['low'] = 0
				price['high'] = 0
				self.write(json.dumps(price))


class AddEvent(tornado.web.RequestHandler):
	def initialize(self):
		self.webdatabase = DB()
	def get(self):
		token    = self.get_argument('token', None)
		platform = self.get_argument('platform', None)
		low      = self.get_argument('low', None)
		high     = self.get_argument('high', None)
		language = self.get_argument('language', '')
		if self.webdatabase.exists(token, platform):
			d = dict()
			if low:
				d['low'] = float(low)
			if high:
				d['high'] = float(high)
			if language:
				d['language'] = language
			try:
				self.webdatabase.update(token, platform, d)
				self.write('success')
			except Exception as e:
				self.write(str(e))
		else:
			if not low:
				low = -1.0
			if not high:
				high = -1.0
			try:
				self.webdatabase.insert(token, platform, low, high, language)
				self.write('success')
			except Exception as e:
				self.write(str(e))

class DeleteEvent(tornado.web.RequestHandler):
	def initialize(self):
		self.webdatabase = DB()

	def get(self):
		token = self.get_argument('token', None)
		platform = self.get_argument('platform', None)
		ttype = self.get_argument('type', None)
		if token and platform and ttype:
			try:
				self.webdatabase.delete(token, platform, ttype)
				self.write('success')
			except Exception as e:
				self.write(str(e))


application = tornado.web.Application([	
	# (r'/okcoin', Okcoin),				
	# (r'/chbtc', Chbtc),					
	# (r'/btctrade', Btctrade),			
	# (r'/fxbtc', Fxbtc),					
	# (r'/mtgox', Mtgox),					
	# (r'/btc100', Btc100),				
	# (r'/btcchina', Btcchina),
	(r'/getprice', GetPrice),
	(r'/all', All),
	(r'/add', AddEvent),
	(r'/delete', DeleteEvent),
])

def get_all_data():
	global _cache
	while 1:
		okcoin   = get_okcoin()
		chbtc    = get_chbtc()
		btctrade = get_btctrade()
		fxbtc    = get_fxbtc()
		mtgox    = get_mtgox()
		btc100   = get_btc100()
		btcchina = get_btcchina()
		bitstamp = get_bitstamp()
		huobi    = get_huobi()
		if okcoin:
			_cache['okcoin']   = okcoin
		else:
			_cache['okcoin']   = -1
		if chbtc:
			_cache['chbtc']    = chbtc
		else:
			_cache['chbtc']    = -1
		if btctrade:
			_cache['btctrade'] = btctrade
		else:
			_cache['btctrade'] = -1
		if fxbtc:
			_cache['fxbtc']    = fxbtc
		else:
			_cache['fxbtc']    = -1
		if mtgox:
			_cache['mtgox']    = mtgox
		else:
			_cache['mtgox']    = -1
		if btc100:
			_cache['btc100']   = btc100
		else:
			_cache['btc100']   = -1
		if btcchina:
			_cache['btcchina'] = btcchina
		else:
			_cache['btcchina'] = -1
		if bitstamp:
			_cache['bitstamp'] = bitstamp
		else:
			_cache['bitstamp'] = -1
		if huobi:
			_cache['huobi'] = huobi
		else:
			_cache['huobi'] = -1
		time.sleep(10)

def push_thread_function():
	from push import Push
	global _cache
	push_handle = Push()
	database = DB()
	PayLoad = {
		'aps':{
			'alert':'%s当前价格为：%s, 已经%s您设定的%s.',
			'sound':'default',
		}
	}
	data = json.dumps(PayLoad)
	while 1:
		time.sleep(10)
		platforms = ['okcoin','chbtc','btctrade','fxbtc','mtgox','btc100','btcchina']
		for platform in platforms:
			need_push_big = database.find(platform, _cache[platform], 'b')
			for one_push in need_push_big:
				msg = ((data) % (platform, ("%0.2f" % _cache[platform]), "大于", str(one_push[3])))
				push_handle.send_message(one_push[0], msg)
				database.delete(one_push[0], platform, 'high')
		for platform in platforms:
			need_push_big = database.find(platform, _cache[platform], 's')
			for one_push in need_push_big:
				msg = ((data) % (platform, ("%0.2f" % _cache[platform]), "小于", str(one_push[2])))
				push_handle.send_message(one_push[0], msg)
				database.delete(one_push[0], platform, 'low')



if __name__ == "__main__":
	with open('pid.txt', 'w') as fp:
		fp.write(str(os.getpid()))
	get_data_thread = threading.Thread(target=get_all_data)
	get_data_thread.start()
	push_thread     = threading.Thread(target=push_thread_function)
	push_thread.start()
	application.listen(4321)
	tornado.ioloop.IOLoop.instance().start()