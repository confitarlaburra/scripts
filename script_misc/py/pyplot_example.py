import numpy as np
import matplotlib.pyplot as plt

# Define function
def dihed(t):
	return 1.3*(1+np.cos(3*t-0.0))

# array of numbers from 0 to pi
t2 = np.arange(0.0, np.pi, 0.02)

#plot function
plt.plot(t2,dihed(t2))

#show function
plt.show()
