import socket, ssl, json, struct

deviceToken = '42cb415a07bb595da9e29b6a18b8cde37e73acac655d571975d277ce13efb21e'


thePayLoad = {
	'aps': {
		'alert':'Oh no! Server\'s Down!',
		'sound':'k1DiveAlarm.caf',
	},
}

cert = r'C:\users\zhangpeipei\desktop\CoinUpCert.pem'
key = r'C:\users\zhangpeipei\desktop\CoinUpKey.pem'

theHost = ( 'gateway.sandbox.push.apple.com', 2195 )

data = json.dumps( thePayLoad )

data = data.encode()

deviceToken = deviceToken.replace(' ','')
#byteToken = bytes.fromhex( deviceToken ) # Python 3
byteToken = deviceToken.decode('hex') # Python 2

theFormat = '!BH32sH%ds' % len(data)

theNotification = struct.pack( theFormat, 0, 32, byteToken, len(data), data )
# Create our connection using the certfile saved locally
ssl_sock = ssl.wrap_socket( socket.socket( socket.AF_INET, socket.SOCK_STREAM ), certfile = cert , keyfile=key)
ssl_sock.connect( theHost )

# Write out our data
ssl_sock.write( theNotification )

# Close the connection -- apple would prefer that we keep
# a connection open and push data as needed.
ssl_sock.close()
