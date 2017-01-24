## -----------------------------------------##
##                lights3.py                ##
##       Written by: Cameron Anderson       ##
## -----------------------------------------##

runOnPi = False

## import necessary libraries
import time
import math
from array import array
import array
from random import randint
import sys
import os.path
if runOnPi:
  from ola.ClientWrapper import ClientWrapper  ## Works on pi, but not computer


## -----------------------------------------
## idk what this does. It was in the example, so I kept it. 
## -----------------------------------------
def DmxSent(state):
  wrapper.Stop()

## -----------------------------------------
## define global variables and set initial values
## -----------------------------------------
#def defineVars():
global universe, wrapper, client, MAX_MODE, NUM_LIGHTS, lights, mode, fade, BRIGHTNESS_MAX

universe = 0
if runOnPi:
  wrapper = ClientWrapper()  ## Works on pi, but not computer
  client = wrapper.Client()  ## Works on pi, but not computer
NUM_LIGHTS = 3   ## up to 170
MAX_MODE = int(math.pow(2,NUM_LIGHTS)-1) ## maximum mode value 
mode = MAX_MODE
lights = []
BRIGHTNESS_MAX = 18.0


## -----------------------------------------
## get variables from save file
## -----------------------------------------
def getValuesFromFile():
  global NUM_LIGHTS, lights, mode, fade
  ## get light values from files. 

  ## does file exist
  if os.path.exists("SavedValues.txt"):
    file = open('SavedValues.txt', 'r')
    ## if NUM_LIGHTS is not equal to save
    if int(file.readline()) != int(NUM_LIGHTS):
      print("NUM_LIGHTS values not equal")
      file.close()
      populateLights()
      return
    mode = float(file.readline()) ## mode
    fade = int(file.readline()) ## fade
    for i in range(0,NUM_LIGHTS):  ## each light -- r, g, b, brightness, prevBrightness
      lights.append(Light(int(file.readline()),int(file.readline()),int(file.readline()),float(file.readline()),float(file.readline())))
  
  ## if files don't exist, populate with defaults
  else:
    print("file does not exist")
    populateLights()

## -----------------------------------------
## save variables to file
## -----------------------------------------
def sendValuesToFile():
  global NUM_LIGHTS, lights, mode, fade

  linesOfText = [str(NUM_LIGHTS), "\n", str(mode), "\n", str(fade), "\n"]
  for i in range(0,NUM_LIGHTS):
    linesOfText.extend((str(lights[i].getRed()), "\n"))
    linesOfText.extend((str(lights[i].getGreen()), "\n"))
    linesOfText.extend((str(lights[i].getBlue()), "\n"))
    linesOfText.extend((str(lights[i].getBrightness()), "\n"))
    linesOfText.extend((str(lights[i].getPrevBrightness()), "\n"))
  file = open('SavedValues.txt', 'w')
  file.writelines(linesOfText)
  file.close()

## -----------------------------------------
## populate variables with default values
## -----------------------------------------
def populateLights():
  global NUM_LIGHTS, lights, mode, fade

  print("in populateLights()")

  for i in range(0,NUM_LIGHTS):
    lights.append(Light(0,0,0,BRIGHTNESS_MAX,BRIGHTNESS_MAX))
  mode = MAX_MODE
  fade = 1 




## -----------------------------------------
## create light object
## -----------------------------------------
class Light(object):
  global BRIGHTNESS_MAX
  r = 0
  g = 0
  b = 0
  prevR = 0
  prevG = 0
  prevB = 0
  brightness = BRIGHTNESS_MAX
  prevBrightness = BRIGHTNESS_MAX

  # The class "constructor" - It's actually an initializer 
  def __init__(self, r, g, b, brightness, prevBrightness):
    self.r = r
    self.g = g
    self.b = b
    self.brightness = brightness
    self.prevBrightness = prevBrightness
    self.prevR = r
    self.prevG = g
    self.prevB = b

  def increaseBrightness(self,step):
    self.brightness = self.brightness+step
    if self.brightness > BRIGHTNESS_MAX:
      self.brightness = BRIGHTNESS_MAX
    return self.getBrightness()

  def decreaseBrightness(self,step):
    self.brightness = self.brightness-step
    if self.brightness < 0:
      self.brightness = 0
    return self.getBrightness()

  def setBrightness(self,b):
    self.brightness = b

  def getBrightness(self):
    return self.brightness

  def saveBrightness(self):
    if self.getBrightness() > 0.01:
      self.setPrevBrightness(self.getBrightness())
    #print("in saveBrightness .... current: "+str(self.getBrightness())+"   prev: "+str(self.getPrevBrightness()))

  def getPrevBrightness(self):
    return self.prevBrightness

  def setPrevBrightness(self, b):
    self.prevBrightness = b

  def saveValues(self):
    self.prevR = self.r
    self.prevG = self.g
    self.prevB = self.b

  def setValue(self,r,g,b):
    self.r = r
    self.g = g
    self.b = b

  def getRed(self):
    return self.r

  def getGreen(self):
    return self.g

  def getBlue(self):
    return self.b

  def getPrevRed(self):
    return self.prevR

  def getPrevGreen(self):
    return self.prevG

  def getPrevBlue(self):
    return self.prevB

## Save previous light values
def savePrevValues():
  global lights, NUM_LIGHTS
  for i in range(0,NUM_LIGHTS):
    lights[i].saveValues()


## -----------------------------------------
## gets input
## -----------------------------------------
def getInput():
  ##make sure there are enough args
  if len(sys.argv) < 2:
    ## print("TOO FEW ARGS")
    print("Refreshing")
    sendDMX(brightnessValues())
    sys.exit()

  ##get code from command line args
  code = sys.argv[1]
  #print("the code is " + str(code))


  if str(code) == "Off":
    off()

  if str(code) == "AllOff":
    allOff()

  if str(code) == "On":
    on()

  if str(code) == "AllOn":
    allOn()

  if str(code) == "AllOnFull":
    allOnFull()

  if str(code) == "White":
    white()

  if str(code) == "SoftWhite":
    softWhite()

  if str(code) == "Red":
    red()

  if str(code) == "Green":
    green()

  if str(code) == "Blue":
    blue()

  if str(code) == "Orange":
    orange()

  if str(code) == "Yellow":
    yellow()

  if str(code) == "Cyan":
    cyan()

  if str(code) == "Purple":
    purple()

  if str(code) == "BrightnessUp":
    brightnessUp()

  if str(code) == "BrightnessDown":
    brightnessDown()

  if str(code) == "Movie":
    movie()

  if str(code) == "Random":
    randomColors()

  if str(code) == "Swap":
    ##make sure there are enough args
    if len(sys.argv) < 3:
      print("TOO FEW ARGS")
      sys.exit()

    l1 = sys.argv[2]
    l2 = sys.argv[3]
    swap(l1, l2)

  if str(code) == "Repeat":
    repeat()

  if str(code) == "Fade":
    fadeToggle()

  if str(code) == "Mode":
    ##make sure there are enough args
    if len(sys.argv) < 3:
      print("TOO FEW ARGS")
      sys.exit()
    # get new mode from second arg
    newMode = int(sys.argv[2])
    
    setMode(newMode)

  if str(code) == "Set":
    ##make sure there are enough args
    if len(sys.argv) < 5:
      print("TOO FEW ARGS")
      sys.exit()

    # get values from args 
    R = int(sys.argv[2])
    G = int(sys.argv[3])
    B = int(sys.argv[4])
    setValues(R,G,B)
    sendDMX()


## -----------------------------------------
## Below are the colors that can be called
## sets colors(R,G,B), sends DMX
## -----------------------------------------
def white():
 setValues(255,255,255)
 sendDMX()

def softWhite():
  setValues(255,130,60)
  sendDMX()

def red():
  setValues(255,0,0)
  sendDMX()

def green():
  setValues(0,255,0)
  sendDMX()

def blue():
  setValues(0,0,255)
  sendDMX()

def orange():
  setValues(255,25,0)
  sendDMX()

def yellow():
  setValues(255,127,0)
  sendDMX()

def cyan():
  setValues(0,255,255)
  sendDMX()

def purple():
  setValues(150,0,255)
  sendDMX()



## -----------------------------------------
## Below are functions are more complex 
## modes than single colors
## -----------------------------------------
## - - - - - - - - - - - - - - - - - - - - -
## -----------------------------------------
## Movie mode
## fades top lights off and back to purple
## -----------------------------------------
def movie():
  global mode

  resultBrightness = []

  for i in range(0,NUM_LIGHTS):
    lights[i].saveBrightness()
    if i == 1:
      resultBrightness.append(1)
    else:
      resultBrightness.append(0)

  ## set purple accent and dim the lights
  mode = 2
  purple()
  brightnessFade(resultBrightness, .05, .01) 

  ## change top light to white
  mode = 1
  softWhite()


## -----------------------------------------
## sends random colors to the lights
## -----------------------------------------
def randomColors():
  print("TODO")


## -----------------------------------------
## sends random colors to the lights
## -----------------------------------------
def swap():
  print("TODO")



## -----------------------------------------
## repeats pattern entered on remote
## -----------------------------------------
def repeat():
  print("TODO")



## -----------------------------------------
## mode and fade toggle
## -----------------------------------------
def setMode(newMode):
  global mode
  ## if mode is from 1-MAX_MODE
  if newMode <= MAX_MODE and newMode > 0:
    mode = newMode
  ## if 0 control all lights
  elif newMode == 0:
    mode = MAX_MODE
  ## if mode is less than 1 (below range)
  elif newMode < 0:
    mode = 1
  ## if mode is above range
  elif newMode > MAX_MODE:
    mode = MAX_MODE

  print(mode)
  sendValuesToFile()



def fadeToggle():
  global fade
  fade = (fade + 1) % 2
  print(fade)
  sendValuesToFile()



## -----------------------------------------
## turns lights off based on mode
## -----------------------------------------
def off():
  global lights, NUM_LIGHTS, mode
  ## create resultBrightness list
  resultBrightness = []
  ## Save current brightness to light.prevBrightness
  for i in range(0,NUM_LIGHTS):
    ## if in mode
    lightOn = math.pow(2,i)
    if int(lightOn) & int(mode) == lightOn:
      resultBrightness.append(0)
      ## if the current brightness isn't 0
      if lights[i].getBrightness != 0:
        lights[i].saveBrightness()
    else:
      resultBrightness.append(lights[i].getBrightness())

  ## send 0 brightness
  brightnessFade(resultBrightness, .1, 0) 
  sendValuesToFile()


## -----------------------------------------
## turns all lights off 
## -----------------------------------------
def allOff():
  global lights, NUM_LIGHTS, mode

  resultBrightness = []

  ## Save current brightnesses to light.prevBrightness
  ## UNLESS already 0, then leave alone
  for i in range(0,NUM_LIGHTS):
    if lights[i].getBrightness > 0.01:
      lights[i].saveBrightness()
    resultBrightness.append(0)

  ## Turn all lights to 0
  modeSave = mode
  mode = MAX_MODE
  brightnessFade(resultBrightness, .1, 0) 
  mode = modeSave
  sendValuesToFile()


## -----------------------------------------
## turns lights on based on mode
## -----------------------------------------
def on():
  global lights, NUM_LIGHTS, mode
  ## create resultBrightness list
  resultBrightness = []

  ## go thru all lights
  for i in range(0,NUM_LIGHTS):
    ## if in mode
    lightOn = math.pow(2,i)
    if int(lightOn) & int(mode) == lightOn:
      ## if the current brightness is essentially 0
      if lights[i].getBrightness() < 0.01:
        resultBrightness.append(lights[i].getPrevBrightness())
      else:  ## in mode but not 0
        resultBrightness.append(lights[i].getBrightness())
    else: ## not in mode
      resultBrightness.append(lights[i].getBrightness())

  ## send brightness
  brightnessFade(resultBrightness, .1, 0) 
  sendValuesToFile()


## -----------------------------------------
## turns all lights on to previous brightness
## -----------------------------------------
def allOn():
  global lights, NUM_LIGHTS, mode

  resultBrightness = []

  ## Resume prev brightness
  ## IF light is currently off
  for i in range(0,NUM_LIGHTS):
    if lights[i].getBrightness() < 0.01 :
      resultBrightness.append(lights[i].getPrevBrightness())
    else:
      resultBrightness.append(lights[i].getBrightness())

  ## Turn off lights to prev brightness
  modeSave = mode
  mode = MAX_MODE
  brightnessFade(resultBrightness, .1, 0) 
  mode = modeSave
  sendValuesToFile()


## -----------------------------------------
## turns all lights on to full brightness
## -----------------------------------------
def allOnFull():
  global lights, NUM_LIGHTS, mode

  resultBrightness = []

  ## Turn all lights on to max
  for i in range(0,NUM_LIGHTS):
    resultBrightness.append(BRIGHTNESS_MAX)

  ## Turn all lights on
  modeSave = mode
  mode = MAX_MODE
  brightnessFade(resultBrightness, .1, 0) 
  mode = modeSave
  sendValuesToFile()



## -----------------------------------------
## Brightness controlls
## -----------------------------------------
## - - - - - - - - - - - - - - - - - - - - -
## -----------------------------------------
## turn brightness up and down
## -----------------------------------------
def brightnessUp():
  global lights, mode, NUM_LIGHTS

  brightnessToSend = array.array('f')

  for i in range(0,NUM_LIGHTS):
    lightOn = math.pow(2,i)
    if int(lightOn) & int(mode) == lightOn:
      brightnessToSend.append(lights[i].getBrightness()+1)
    else:
      brightnessToSend.append(lights[i].getBrightness())

  for i in range(0,NUM_LIGHTS):
    if brightnessToSend[i] > BRIGHTNESS_MAX:
      brightnessToSend[i] = BRIGHTNESS_MAX

  brightnessFade(brightnessToSend)
  sendValuesToFile()


def brightnessDown():
  global lights, mode, NUM_LIGHTS

  brightnessToSend = array.array('f')

  for i in range(0,NUM_LIGHTS):
    lightOn = math.pow(2,i)
    if int(lightOn) & int(mode) == lightOn:
      brightnessToSend.append(lights[i].getBrightness()-1)
    else:
      brightnessToSend.append(lights[i].getBrightness())

  for i in range(0,NUM_LIGHTS):
    if brightnessToSend[i] < 0:
      brightnessToSend[i] = 0

  brightnessFade(brightnessToSend)
  sendValuesToFile()



## -----------------------------------------
## return brightness values 
## -----------------------------------------
def brightnessValueCalculation(curValue, curBrightness):
  global lights, BRIGHTNESS_MAX, NUM_LIGHTS
  #y = (brightness1 / BRIGHTNESS_MAX * x)   ## linear brightness levels
  y = curValue*(1-math.log10(1+(0.5*abs(curBrightness-BRIGHTNESS_MAX))))   ## logarithmic brightness levels
  return int(y)

def brightnessValues():
  global lights

  ## make sure brightness is non negative  ## IS THIS NEEDED?
  for i in range(0,NUM_LIGHTS):
    if lights[i].getBrightness() < 0.01:
      lights[i].setBrightness(0)

  dmxToSend = array.array('B')
  for i in range(0,NUM_LIGHTS):
    dmxToSend.append(brightnessValueCalculation(lights[i].getRed(),lights[i].getBrightness()))
    dmxToSend.append(brightnessValueCalculation(lights[i].getGreen(),lights[i].getBrightness()))
    dmxToSend.append(brightnessValueCalculation(lights[i].getBlue(),lights[i].getBrightness()))

  return dmxToSend



## -----------------------------------------
## fade between brightness values
## -----------------------------------------
def brightnessFade(resultBrightness, step=None, delay=None):
  global lights, BRIGHTNESS_MAX, NUM_LIGHTS, fade

  print(resultBrightness)
  print(resultBrightness[0])

  if step == None:
    step = .05     ## Small enough step to not be jarring to see
    delay = .0061  ## Trial and error, I like this delay

  ## set step to >= .01 (else rounding later on won't work right)
  if step < .01:
    step = .01

  ## make sure values do not become negative or too positive
  for i in range(0,NUM_LIGHTS):
    if resultBrightness[i] < 0.01:
      resultBrightness[i] = 0
      print("Result brightness too low, setting result brightness to 0")
    if resultBrightness[i] > BRIGHTNESS_MAX:
      resultBrightness[i] = BRIGHTNESS_MAX


  done = "no"
  while done != "yes":

    ## Adjust brightness
    for i in range(0,NUM_LIGHTS):
      if lights[i].getBrightness() < resultBrightness[i]:
        lights[i].increaseBrightness(step)
      elif lights[i].getBrightness() > resultBrightness[i]:
        lights[i].decreaseBrightness(step)


    ## exit loop -- using string to compare correctly, rounding and abs to fix math errors
    done = "yes"
    for i in range(0,NUM_LIGHTS):
      if abs(round(lights[i].getBrightness(),3)) != abs(round(resultBrightness[i],3)):
        done = "no"

    ## Send values out
    data = brightnessValues()
    sendDMX(data)

    time.sleep(delay)



## -----------------------------------------
## get fade array and send fade to dmx
## -----------------------------------------
def fadeRun(numSteps, delay):
  global universe, client, NUM_LIGHTS, lights

  ## create lists for next step
  currentLights = [] 
  resultLights = []
  difference = []
  curBrightness = []

  ## get all values needed in one big list (format that is needed)
  for i in range(0,NUM_LIGHTS):
    currentLights.append(lights[i].getPrevRed())
    currentLights.append(lights[i].getPrevGreen())
    currentLights.append(lights[i].getPrevBlue())
    resultLights.append(lights[i].getRed())
    resultLights.append(lights[i].getGreen())
    resultLights.append(lights[i].getBlue())
    difference.append(lights[i].getPrevRed()-lights[i].getRed())
    difference.append(lights[i].getPrevGreen()-lights[i].getGreen())
    difference.append(lights[i].getPrevBlue()-lights[i].getBlue())
    curBrightness.append(lights[i].getBrightness())
    curBrightness.append(lights[i].getBrightness())
    curBrightness.append(lights[i].getBrightness())



  ## Send fade sequences
  for j in range(0,numSteps-1):
    dmxToSend = array.array('B')

    ## calculate what to send at each spot
    for k in range(len(currentLights)):
      step = float(j)/float(numSteps)*float(difference[k])
      dmxToSend.append(brightnessValueCalculation(currentLights[k]-step,curBrightness[k]))

    ## Make sure within bounds
    for l in range(len(dmxToSend)):
      if dmxToSend[l] > 255:
        dmxToSend[l] = 255
      elif dmxToSend[l] < 0:
        dmxToSend[l] = 0

    print("This is the data sent:  ")
    print(dmxToSend)
    sendDMX(dmxToSend)
    time.sleep(delay)


  ## send what value should be (in case fade sequence is off by a few)
  data = array.array('B')
  for i in range(len(currentLights)):
    data.append(brightnessValueCalculation(resultLights[i], curBrightness[i]))

  print("This is the data sent:  ")
  print(data) 
  sendDMX(data)


## -----------------------------------------
## returns array of values used to fade
## -----------------------------------------
def fadeArray(current, result, numSteps):
  difference = result - current
  step = float(difference) / numSteps
  sequence = array.array('B')

  for x in range(1,numSteps):
    sequence.append(int(current + step * x))
  return sequence



## ----------------------------------------
## Store the values received into current values on lights
## Store previous values into prevValues on lights
## ----------------------------------------
def setValues(R,G,B,light=None):
  global mode, lights, NUM_LIGHTS

  ## set colors based on current mode
  if light is None:
    ## save the previous values
    savePrevValues()
    for i in range(0,NUM_LIGHTS):
      lightOn = math.pow(2,i)
      if int(lightOn) & int(mode) == lightOn:
        lights[i].setValue(R,G,B)

  ## light specified.
  else:
    lights[light].setValue(R,G,B)

  sendValuesToFile()



## -----------------------------------------
## Send the current values -- Call fade if necessary
## -----------------------------------------
def sendDMX(data=None):
  global universe, client, fade

  if fade == 1 and data==None:
    sendDMXFade()

  if data is None:
    data = brightnessValues()
  print("This is the data sent:  ")
  print(data)
  if runOnPi:
    client.SendDmx(universe, data, DmxSent) ## Works on pi, but not computer

def sendDMXFade():
  fadeRun(40, 0.007)



## -----------------------------------------
## define variables and get input to run program
## -----------------------------------------
#defineVars()
getValuesFromFile()
getInput()
#wrapper.Run()  ## Is this needed?