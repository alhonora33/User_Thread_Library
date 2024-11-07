#!/bin/env python3

import matplotlib.pyplot as plt
import subprocess
import time

def run_benchmark(program, args):
    start_time = time.time()
    subprocess.run([program] + args)
    end_time = time.time()
    return end_time - start_time

def plot_results(results):
    fig, ax = plt.subplots()
    for impl in set(result[0] for result in results):
        impl_results = [r for r in results if r[0] == impl]
        impl_results.sort(key=lambda x: x[1]) 
        threads = [r[1] for r in impl_results]
        times = [r[2] for r in impl_results]
        ax.plot(threads, times, label=impl)

    ax.set_xlabel('Nombre de Threads')
    ax.set_ylabel('Temps exécution (s)')
    ax.set_title('Comparaison des performances des threads')
    ax.legend()

    plt.show()

def print(a):
    results = []
    for i in range(1, 11):
        if (a == 1) : 
            time_taken = run_benchmark("./install/bin/01-main", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/01-main-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 2) : 
            time_taken = run_benchmark("./install/bin/02-switch", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/02-switch-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 3) : 
            time_taken = run_benchmark("./install/bin/03-equity", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/03-equity-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 11) : 
            time_taken = run_benchmark("./install/bin/11-join", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/11-join-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 12) : 
            time_taken = run_benchmark("./install/bin/12-join-main", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/12-join-main", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 21) : 
            time_taken = run_benchmark("./install/bin/21-create-many", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/21-create-many-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 22) : 
            time_taken = run_benchmark("./install/bin/22-create-many-recursive", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/22-create-many-recursive", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 23) : 
            time_taken = run_benchmark("./install/bin/23-create-many-once", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/23-create-many-once-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 31) : 
            time_taken = run_benchmark("./install/bin/31-switch-many", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/31-switch-many-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 32) : 
            time_taken = run_benchmark("./install/bin/32-switch-many-join", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/32-switch-many-join-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 33) : 
            time_taken = run_benchmark("./install/bin/33-switch-many-cascade", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/33-switch-many-cascade-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 51) : 
            time_taken = run_benchmark("./install/bin/51-fibonacci", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/51-fibonacci-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 61) : 
            time_taken = run_benchmark("./install/bin/61-mutex", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/61-mutex-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 62) : 
            time_taken = run_benchmark("./install/bin/62-mutex", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/62-mutex-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 63) : 
            time_taken = run_benchmark("./install/bin/63-mutex-equity", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/63-mutex-equity-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 64) : 
            time_taken = run_benchmark("./install/bin/64-mutex-join", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/64-mutex-join-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 71) : 
            time_taken = run_benchmark("./install/bin/71-preemption", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/71-preemption-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        elif (a == 81) : 
            time_taken = run_benchmark("./install/bin/81-deadlock", [str(i)])
            results.append(("thread", i, time_taken))
            time_taken = run_benchmark("./install/bin/81-deadlock-pthread", [str(i)])
            results.append(("pthread", i, time_taken))
        else :
            print("Test doesn't exist !")

    
    
    
    plot_results(results)


print(1)