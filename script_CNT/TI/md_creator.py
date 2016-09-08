#!/usr/bin/env python

import numpy as np
import sys



title = sys.argv[1]
nmSim=int(sys.argv[2])


for idx in range(nmSim):
    idx = idx + 1
    print "%s_%d.run" % (title,idx)

