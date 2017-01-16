## -----------------------------------------##
##              LircServer.py               ##
##       Written by: Cameron Anderson       ##
## -----------------------------------------##


## import necessary libraries
import lirc
import subprocess


stockid = lirc.init("myprogram", blocking=False)
lcode = "0"


## -----------------------------------------
## gets input
## -----------------------------------------
def getInput():
  while True:
    codeIR = lirc.nextcode()
    #print("the code is " + str(codeIR))

    functionCaller(codeIR)


## -----------------------------------------
## calls appropriate function
## -----------------------------------------
def functionCaller(codeIR):
  if str(codeIR) == "[u'Off']":
    off()

  if str(codeIR) == "[u'On']":
    on()

  if str(codeIR) == "[u'White']":
    white()

  if str(codeIR) == "[u'Red']":
    send("Red")

  if str(codeIR) == "[u'Green']":
    send("Green")

  if str(codeIR) == "[u'Blue']":
    send("Blue")

  if str(codeIR) == "[u'Orange']":
    send("Orange")

  if str(codeIR) == "[u'Yellow']":
    send("Yellow")

  if str(codeIR) == "[u'Cyan']":
    send("Cyan")

  if str(codeIR) == "[u'Purple']":
    send("Purple")

  if str(codeIR) == "[u'BrightnessUp']":
    send("BrightnessUp")

  if str(codeIR) == "[u'BrightnessDown']":
    send("BrightnessDown")

  if str(codeIR) == "[u'F1']":
    send("Movie")

  if str(codeIR) == "[u'F2']":
    send("Random")

  if str(codeIR) == "[u'F3']":
    send("Swap 1 2")

  if str(codeIR) == "[u'F4']":
    send("Repeat")

  if str(codeIR) == "[u'F5']":
    send("Fade")

  if str(codeIR) == "[u'F6']":
    send("Mode 1")

  if str(codeIR) == "[u'F7']":
    send("Mode 2")

  if str(codeIR) == "[u'F8']":
    send("Mode 4")


## -----------------------------------------
## Below are the colors that can be called
## sets colors(G,R,B), lcode, sends DMX
## -----------------------------------------
def white():
  global lcode
  if lcode == "SWhite":
    lcode = "White"
    send("White")
  else:
    lcode = "SWhite"
    send("SoftWhite")



## -----------------------------------------
## turns lights off based on mode
## -----------------------------------------
def off():
  global lcode

  ## if previusly off, all off
  if lcode != "Off":
    send("Off")
  else: 
    send("AllOff")

  lcode = "Off"

## -----------------------------------------
## turns lights on based on mode
## -----------------------------------------
def on():
  global lcode

  if lcode != "On" and lcode != "AllOn":
    send("On")
    lcode = "On"
  elif lcode == "On":
    send("AllOn")
    lcode = "AllOn"
  elif lcode == "AllOn":
    send("AllOnFull")
    lcode == "AllOn"

def send(arg):
    print(arg)
    subprocess.call("python lights3.py "+arg, shell=True)


getInput()
