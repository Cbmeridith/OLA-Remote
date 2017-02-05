from twisted.internet.protocol import Protocol, Factory
from twisted.internet import reactor

from ola.ClientWrapper import ClientWrapper

import os
import time
import array

class RaspberryLight(Protocol):
    
    #---Globals---#
    lastCode = ''

    def connectionMade(self):
        self.transport.write("""connected""")
        self.factory.clients.append(self)
        #print "clients are ", self.factory.clients

    def connectionLost(self, reason):
        print "connection lost ", self.factory.clients
        self.factory.clients.remove(self)


    def dataReceived(self, data):
            args = ""
            print "Data In: " +  data
            
            #Check for RGB code
            if(len(data) == 9):
                r = data[0] + data[1] + data[2]
                g = data[3] + data[4] + data[5]
                b = data[6] + data[7] + data[8]
                args = "Set " + r + " " + g + " " + b
            else:
                #---Functions---#
                if (data == 'OFF'):
                    args = "Off"
                elif (data == 'ON'):
                    args = "On"
                elif (data == 'BRIGHTUP'):
                    args = "BrightnessUp"
                elif (data == 'BRIGHTDOWN'):
                    args = "BrightnessDown"
                elif (data == 'MOVIE'):
                    args = "Movie"
                elif (data == 'RANDOM'):
                    args = "Random"
                elif (data == 'SWAP'):
                    #Temp: Only works with 2 lights
                    args = "Swap 1 2"
                elif (data == 'TOGFADE'):
                    args = "ToggleFade"
                #TODO: This is temporary
                elif (data == 'MODE0'):
                    args = "Mode 0"
                elif (data == 'MODE1'):
                    args = "Mode 1"
                elif (data == 'MODE2'):
                    args = "Mode 2"
                elif (data == 'MODE3'):
                    args = "Mode 3"
                elif (data == 'MODE4'):
                    args = "Mode 4"
                elif (data == 'MODE5'):
                    args = "Mode 5"
                elif (data == 'MODE6'):
                    args = "Mode 6"
                elif (data == 'MODE7'):
                    args = "Mode 7"
                elif (data == 'NIGHT'):
                    args = "NightMode"

            lastCode = data
            command = "python lights3.py " + args
            #print "Command Sent: " + command
            os.system(command)

factory = Factory()
factory.protocol = RaspberryLight
factory.clients = []

reactor.listenTCP(7777, factory)
#print "Looking For IOS Devices"
reactor.run()
