hotspot = require './hotspot'

hotspot.start()
if process.argv[2] == 'start'
    console.log('Starting hotspot')
	hotspot.start()
else if process.argv[2] == 'stop'
    console.log('Stopping hotspot')
	hotspot.stop()
else
	console.log('Exiting')
	process.exit()