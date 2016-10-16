import os
import sys
import random
import json
import urllib.request
import time
from urllib.parse import urlencode

def get_okcoin():
	url = 'http://www.okcoin.com/ticker.do?random={random}'
	url = url.format(random=random.randint(0, 100))
	try:
		handle = urllib.request.urlopen(url, timeout = 3)
	except Exception:
		return None
	data = handle.read()
	handle.close()
	try:
		data = data.decode('utf-8')
	except Exception:
		return None
	jsonparse = json.loads(data)
	try:
		result = jsonparse.get('btcLast')
		if type(result) is str:
			return float(result)
	except KeyError:
		return None
	except Exception:
		return None

def get_chbtc():
	url = 'https://www.chbtc.com/data/userticker?r=1384261485474'
	try:
		handle = urllib.request.urlopen(url, timeout=3)
		data = handle.read().decode('utf-8')
	except Exception :
		return None
	jsondata = json.loads(data)
	result =  jsondata['ticker']['buy']
	try:
		return float(result)
	except Exception:
		return None

def get_btctrade():
	url = 'http://www.btctrade.com/btc_sum?t=12211320'
	try:
		handle = urllib.request.urlopen(url, timeout=3)
		data = handle.read().decode('utf-8')
	except Exception:
		return None
	jsondata = json.loads(data)
	try:
		result =  jsondata['buy'][0]['p']
		return float(result)
	except Exception:
		return None

# need post data
#post data is done
def get_fxbtc():
	url = 'https://www.fxbtc.com/jport?op=query&c={random}'
	randomnum = random.randint(100000, 999999)
	url = url.format(random=randomnum)
	postdata = {'symbol':'btc_cny', 'type':'ticker'}
	try:
		handle = urllib.request.urlopen(url,			\
			data = urlencode(postdata).encode('utf-8'),	\
			timeout=3)
		data = handle.read().decode('utf-8')
	except Exception:
		return None
	jsondata = json.loads(data)
	try:
		result =  jsondata['ticker']['last_rate']
		return float(result)
	except Exception:
		return None

def get_mtgox():
	url = 'http://data.mtgox.com/api/1/BTCUSD/ticker'
	try:
		handle = urllib.request.urlopen(url, timeout=3)
		data = handle.read().decode('utf-8')
	except Exception:
		return None
	jsondata = json.loads(data)
	try:
		result =  jsondata['return']['last_all']['display']
		return float(result.replace('$', ''))
	except Exception:
		return None

def get_btc100():
	url = 'https://btc100.org/getData.php?_={time}'
	t = time.time()
	url = url.format(time=str(int(t * 1000)))
	try:
		handle = urllib.request.urlopen(url, timeout=3)
		data = handle.read().decode('utf-8')
	except Exception:
		return None
	jsondata = json.loads(data)
	try:
		result =  jsondata[0]['bit']
		return float(result)
	except Exception:
		return None

def get_btcchina():
	url = 'https://data.btcchina.com/data/chart/interval/86400/duration/2592000'
	try:
		handle = urllib.request.urlopen(url, timeout=3)
		data = handle.read().decode('utf-8')
	except Exception:
		return None
	jsondata = json.loads(data)
	try:
		return float(jsondata[30][1])
	except Exception:
		return None


def get_bitstamp():
	url = 'https://www.bitstamp.net/api/ticker/'
	try:
		handle = urllib.request.urlopen(url, timeout=3)
		data = handle.read().decode('utf-8')
	except Exception:
		return None
	try:
		jsondata = json.loads(data)
		return float(jsondata['last'])
	except Exception:
		return None

def get_huobi():
	url = 'https://www.huobi.com/market/huobi.php?a=detail&jsoncallback={callback}&_={ntime}'
	callback = 'jQuery17105231708617248075_1384566798465'
	try:
		handle = urllib.request.urlopen(url.format(callback = callback, ntime = str(int(time.time() * 1000))))
		data = handle.read().decode('utf-8')
		data = data.replace(callback, '')
		data = data[1:len(data)-1]
	except Exception as e:
		print('function get_huobi ' + str(e))
		return None
	try:
		jsondata = json.loads(data)
		return float(jsondata['p_last'])
	except Exception as e:
		print('function get_huobi ' + str(e))
		return None

if __name__ == '__main__':
	sys.exit(0)