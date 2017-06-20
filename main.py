import urllib, json
import numpy as np
import matplotlib.pyplot as plt

lonlat = "-90.979927/39.525261"
lonlat = "-109.979927/40.525261"

'''
url = "https://earthquake.usgs.gov/hazws/staticcurve/1/E2014R1/COUS0P05/"+lonlat+"/any/760"
response = urllib.urlopen(url)
data = json.loads(response.read())
x = np.asarray(data['response'][0]['metadata']['xvals'])
y1 = np.asarray(data['response'][0]['data'][0]['yvals'])
y2 = np.asarray(data['response'][0]['data'][1]['yvals'])
y3 = np.asarray(data['response'][0]['data'][2]['yvals'])
y4 = np.asarray(data['response'][0]['data'][3]['yvals'])
y = (y1+y2+y3+y4)/4.0
print np.interp(1.0/2475.0, y[::-1],x[::-1])
'''

def getPGA(url):
    response = urllib.urlopen(url)
    data = json.loads(response.read())
    x2 = np.asarray(data['response'][0]['metadata']['xvalues'])
    y2 = np.asarray(data['response'][0]['data'][0]['yvalues'])
    #print np.interp(1.0/2475.0, y2[::-1],x2[::-1])
    PGA1 = np.interp(1.0/2475.0, y2[::-1],x2[::-1])
    PGA2 = np.interp(1.0/975.0, y2[::-1],x2[::-1])
    PGA3 = np.interp(1.0/475.0, y2[::-1],x2[::-1])
    return [PGA1,PGA2,PGA3]

'''
# test
lonlat = "-122.2072/37.76694"
url="https://earthquake.usgs.gov/nshmp-haz-ws/hazard/E2014/COUS/"+lonlat+"/PGA/760"
print getPGA(url)
'''



parsFile = open('lonlat.txt', 'r')
for index, lonlat in enumerate(parsFile):
    url="https://earthquake.usgs.gov/nshmp-haz-ws/hazard/E2014/COUS/"+lonlat+"/PGA/760"
    PGA = getPGA(url)
    print PGA


#url="https://earthquake.usgs.gov/nshmp-haz-ws/hazard/E2014/COUS/-80.979927/39.525261/PGA/760"

'''
#plt.plot(np.log(x),np.log(y))
plt.plot(np.log(x2),np.log(y2))
plt.xlabel('Ground notion, PGA (g), logarithm')
plt.ylabel('Annual Frequency of Exceedence, logarithm')
plt.show()
'''
    
# --------------------------------------
'''
for key in data.response.keys():
    print key
'''
'''
https://earthquake.usgs.gov/nshmp-haz-ws/hazard/1/E2014R1/COUS0P05/-110.979927/39.525261/any/760
https://earthquake.usgs.gov/nshmp-haz-ws/hazard/v1.1.1/COUS0P05/-110.979927/39.525261/any/760
'''
