using System;
using System.Numerics;
using Microsoft.Quantum.Simulation.Simulators;

namespace Shor.Testing
{
    class Driver
    {
        static void Main(string[] args)
        {
            
            ResourcesEstimator estimator = new ResourcesEstimator();
            int RegisterSize = 10; 
            testShorQubitCount.Run(estimator,RegisterSize).Wait();
            Console.WriteLine(estimator.ToTSV());
            
        }

    }
}

