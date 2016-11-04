hotspot = require './hotspot'
gpio = require 'rpi-gpio'

readInput = ->
  gpio.read 40, (err, value) ->
    console.log 'The value is ' + value
    if value == true
        console.log 'Starting hotspot'
        hotspot.start().then ->
    else
        console.log 'Stopping hotspot'
        hotspot.stop().then ->

gpio.setup 40, gpio.DIR_IN, gpio.EDGE_BOTH, readInput

gpio.on 'change', (channel, value) ->
  console.log 'Channel ' + channel + ' value is now ' + value
  if value == true
    console.log 'Starting hotspot'
    hotspot.start().then ->
  else
    console.log 'Stopping hotspot'
    hotspot.stop().then ->