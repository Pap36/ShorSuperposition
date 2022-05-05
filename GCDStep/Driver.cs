using System;
using System.Numerics;
using Microsoft.Quantum.Simulation.Simulators;

namespace GCDStep.Testing
{
    class Driver
    {
        static void Main(string[] args)
        {
            // TestOnToffoli();

            // TestOnQuantum();

            // ResourcesEstimator estimator = new ResourcesEstimator();
            // int RegisterSize = 10; 
            // testQubitCount.Run(estimator,RegisterSize).Wait();
            // Console.WriteLine(estimator.ToTSV());
        }


        // function runs the quantum operation on a Toffoli simulator and checks the
        // numerical results returned
        public static void TestOnToffoli(){
          var sim = new ToffoliSimulator();
          Random rand = new Random();
          var a = new BigInteger(rand.Next());
          var b = new BigInteger(rand.Next());
          var c = new BigInteger(rand.Next());
          // gcd should be at least c
          a = a * c;
          b = b * c;
          
          Console.WriteLine("Initial values are {0} and {1}", a, b);
          Console.WriteLine("Clasic GCD is {0}", BigInteger.GreatestCommonDivisor(a, b));
          var newA = new BigInteger(0);
          var newB = new BigInteger(0);

          while(true) {
            var results = testGCDStep.Run(sim, a, b).Result;
            newA = results[0];
            newB = results[1];
            Console.WriteLine("After step newA and newB are {0} and {1}", newA, newB);
            if(newB == 0){
              Console.WriteLine("Quantum GCD is {0}", b);
              break;
            }
            a = newA;
            b = newB;
          }
        }


        // function runs the quantum operation on a Quantum simulator and checks the
        // numerical results returned
        public static void TestOnQuantum(){
          var sim = new QuantumSimulator();
          Random rand = new Random();
          var a = new BigInteger(rand.Next(256));
          var b = new BigInteger(rand.Next(256));
          
          // Worst case scenario for Fibbonaci Numbers
          // a = 154;
          // b = 243;

          Console.WriteLine("Initial values are {0} and {1}", a, b);
          Console.WriteLine("Clasic GCD is {0}", BigInteger.GreatestCommonDivisor(a, b));
          
          var newA = new BigInteger(0);
          var newB = new BigInteger(0);

          while(true) {
            var results = testGCDStep.Run(sim, a, b).Result;
            newA = results[0];
            newB = results[1];
            Console.WriteLine("After step newA and newB are {0} and {1}", newA, newB);
            if(newB == 0){
              Console.WriteLine("Quantum GCD is {0}", b);
              break;
            }
            a = newA;
            b = newB;
          }
        }

    }
}

