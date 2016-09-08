#!/usr/bin/env python

import numpy as np
import os

title = "TI_load_0"
cwd = os.getcwd()
nmSim=100
lambdas = []
#lambdas = np.arange(0.025, 0.21, 0.025)
#lambdas = np.append(lambdas, [0.675,0.687,0.700,0.712])
#lambdas = np.append(lambdas, [ 0.850,0.900,0.950])
#lambdas = np.append(lambdas, [0.700,0.750,0.800,0.850,0.900])
#lambdas = np.append(lambdas, [0.700])
lambdas = np.append(lambdas, [0.000])



lambdas = np.sort(lambdas)
lambdas = np.unique(lambdas) # solo por seguridad
eq = 50000
md = 500000

last_job_id = 1234
for l in lambdas:
    idx = 1
    job_id = l*10000 + idx
    # equilibrio
    #print "%d\t%s\t%s\tL_%.3f\t%04.0f" % (job_id, eq, l, l, last_job_id)
    print "%s/L_%.3f/%s_%d.run" % (cwd,l,title,job_id)
    last_job_id = job_id
    # dinamica
    for i in range(nmSim-1):
        idx = idx + 1
        job_id = l*10000 + idx
        #print "%d\t%s\t%s\tL_%.3f\t%04.0f" % (job_id, md, l, l, last_job_id)
        print "%s/L_%.3f/%s_%d.run" % (cwd,l,title,job_id)
        last_job_id = job_id

