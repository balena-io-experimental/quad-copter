Promise = require 'bluebird'
{ spawn, exec } = require 'child_process'
execAsync = Promise.promisify(exec)

config = require './config'

hostapd = require './hostapd'
dnsmasq = require './dnsmasq'
systemd = require './systemd'

started = false

exports.start = ->
	if started
		return Promise.resolve()

	started = true

	console.log('Stopping connman..')

	systemd.stop('connman.service')
	.delay(2000)
	.then ->
		console.log('1')
		execAsync('rfkill unblock wifi')
	.then ->
		console.log('2')
		# XXX: detect if the IP is already set instead of doing `|| true`
		execAsync("ip addr add #{config.gateway}/24 dev #{config.iface} || true")
	.then ->
		console.log('3')
		hostapd.start()
	.then ->
		console.log('4')
		dnsmasq.start()

exports.stop = ->
	if not started
		return Promise.resolve()

	started = false

	Promise.all [
		hostapd.stop()
		dnsmasq.stop()
	]
	.then ->
		systemd.start('connman.service')