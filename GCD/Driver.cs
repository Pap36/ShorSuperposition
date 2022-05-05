using System;
using System.Numerics;
using Microsoft.Quantum.Simulation.Simulators;

namespace GCD.Testing
{
    class Driver
    {
        static void Main(string[] args)
        {
            // TestOnToffoli();

            // ResourcesEstimator estimator = new ResourcesEstimator();
            // int RegisterSize = 10; 
            // testGCDQubitCount.Run(estimator,RegisterSize).Wait();
            // Console.WriteLine(estimator.ToTSV());
        }


        // function runs the quantum operation on a Toffoli simulator and checks the
        // numerical results returned
        public static void TestOnToffoli(){
          var sim = new ToffoliSimulator();
          Random rand = new Random();
          int count = 0;
          for(int i = 0; i < 100; i++){
            var a = new BigInteger(rand.Next(100000));
            var b = new BigInteger(rand.Next(100000));
            var c = new BigInteger(rand.Next(100000));
            a = a * c;
            b = b * c;
            
            Console.WriteLine("Initial values are {0} and {1}", a, b);
            Console.WriteLine("The classic GCD is {0}", BigInteger.GreatestCommonDivisor(a, b));
            var result = testGCD.Run(sim, a, b).Result;
            Console.WriteLine("The quantum GCD is {0}", result);  
            if(result == BigInteger.GreatestCommonDivisor(a, b)){
              count += 1;
            }
            Console.WriteLine("Accuracy {0}/{1}", count, i + 1);
          }
        }

    }
}

