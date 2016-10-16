import socket
import json
import struct
import ssl
import logging
# deviceToken = '42cb415a07bb595da9e29b6a18b8cde37e73acac655d571975d277ce13efb21e'
# thePayLoad = {
# 	'aps': {
# 		'alert':'Oh no! Server\'s up!',
# 		'sound':'default',
# 	},
# }



class Push(object):
	def __init__(self):
		super(Push, self).__init__()
		self.cert = r'Cert.pem'
		self.key  = r'newKey.pem'
		self.host = ('gateway.sandbox.push.apple.com', 2195)
		self.reconnect()

	def send_message(self, device_token, msg):
		data = msg.encode()
		byteToken = bytes.fromhex(device_token)
		theFormat = '!BH32sH%ds' % len(data)
		theNotification = struct.pack( theFormat, 0, 32, byteToken, len(data), data)
		try:
			self.ssl_sock.write( theNotification )
			print('push to %s' % device_token)
		except Exception as e:
			logging.info('push to %s failed!' % device_token)
			self.reconnect()

	def reconnect(self):
		if hasattr(self, 'ssl_sock'):
			self.ssl_sock.close()
		try:
			self.ssl_sock = ssl.wrap_socket(socket.socket(socket.AF_INET, socket.SOCK_STREAM ), \
												certfile = self.cert , 						\
												keyfile  = self.key)
		except Exception as e:
			self.ssl_sock.close()
			raise RuntimeError("Can't push message!")
		self.ssl_sock.connect(self.host)

	def close(self):
		self.ssl_sock.close()

