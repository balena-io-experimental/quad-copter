Promise = require 'bluebird'
{ exec } = require 'child_process'
execAsync = Promise.promisify(exec)

config = require './config'

exports.scanAsync = ->
	execAsync("iw #{config.iface} scan ap-force")
	.then (output) ->
		bsss = {}
		bss = null

		for line in output.split('\n')
			match = line.match(/^(\t?[A-Za-z]+):? (.*)$/)

			if match isnt null
				token = match[1]
				value = match[2]

				switch token
					when 'BSS'
						# BSS a4:2b:8c:82:2c:ba(on wlp8s0)
						bss = value[0...17]
						bsss[bss] = {}
					when '\tSSID'
						#     SSID: kinaidos-sea-5g
						bsss[bss].ssid = value or null
					when '\tsignal'
						#     signal: -80.00 dBm
						bsss[bss].signal = Number(value.split(' ')[0])

		networks = []
		for own bss, details of bsss
			networks.push(details)

		# sort by signal strength
		return networks.sort((a, b) -> b.signal - a.signal)
