#!/usr/bin/env python

import numpy as np

numSim=12
lambdas=[]
lambdas = np.arange(0.0, 0.21, 0.025)
#lambdas = np.arange(0.6, 0.8, 0.025)
lambdas = np.append(lambdas,[0.700.0.750,0.800,0.850,0.900,0.950])
#lambdas = np.append(lambdas, [0.700])
lambdas = np.append(lambdas, [0.000])


lambdas = np.sort(lambdas)
lambdas = np.unique(lambdas) # solo por seguridad
eq =  50000
md = 500000

print """TITLE
  free energy profile for dissapearing an ch4 molecule
END
JOBSCRIPTS
job_id NSTLIM  RLAM    subdir   run_after"""

last_job_id = 1234
for l in lambdas:
    idx = 1
    job_id = l*10000 + idx
    print "### lambda %s ###" % l
    # equilibrio
    print "%04.0f\t%s\t%s\tL_%.3f\t%04.0f" % (job_id, eq, l, l, last_job_id)
    last_job_id = job_id
    # dinamica
    for i in range(numSim-1):
        idx = idx + 1
        job_id = l*10000 + idx
        print "%04.0f\t%s\t%s\tL_%.3f\t%04.0f" % (job_id, md, l, l, last_job_id)
        last_job_id = job_id
print "END"

