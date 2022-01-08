# Fermentation

This is a nerves app for running a fermentation station. Features include:
* Temperature and humidity reading from an SHT30
* Logging of temp/humidity data to sqlite db
* Relay enable/disable (for heating element)
* Temperature range for automatic management of relay

## To do
* Implement tests because maybe this is gonna burn my house down
* Some more config options around slotting in/out temp/humidity data polling
* Move to remote sql logging because the current setup is gonna run down an SD card real fast
* Update database to be event-oriented (eg, temp_reading 30, heater enabled, blah blah)
* Implement a front end service for monitoring and maybe if I don't feel paranoid, control


## Deploy
Run your `deps.get` and such
I recommend setting up a shell script with the following:
```(bash)
# other targets may require modifying mix.exs
export MIX_TARGET=rpi0 
export NERVES_NETWORK_SSID=ssid
export NERVES_NETWORK_PSK=psk
mix firmware && mix upload
```

