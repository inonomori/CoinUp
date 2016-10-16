import socket
import ssl

s = socket.socket()
sock = ssl.SSLSocket(s, certfile = r'Cert.pem', keyfile = r'Key.pem')
