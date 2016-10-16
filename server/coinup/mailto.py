#!/usr/bin/env python3
#-*- coding: utf-8 -*-

import smtplib
from email.mime.text import MIMEText


def mail_send_message(to, subject,  message, attechment = None):
	try:
		sender = 'coinupmessage@126.com'
		receiver = to
		smtpserver = 'smtp.126.com'
		username = 'coinupmessage@126.com'
		password = 'fuck123456'
		msg = MIMEText(message, 'plain', 'utf-8')
		msg['subject'] 	= subject
		msg['to'] 		= to
		msg['from'] 	= 'coinupmessage@126.com'

		smtp = smtplib.SMTP()
		smtp.connect(smtpserver)
		smtp.login(username, password)
		smtp.sendmail(sender, receiver, msg.as_string())
		smtp.quit()
	except Exception as e:
		raise RuntimeError(str(e))
