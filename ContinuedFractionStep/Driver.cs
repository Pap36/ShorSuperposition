using System;
using System.Numerics;
using Microsoft.Quantum.Simulation.Simulators;

namespace ContinuedFractionStep.Testing
{
    class Driver
    {
        static void Main(string[] args)
        {

            // TestOnToffoli();

            // TestOnQuantum();

            // ResourcesEstimator estimator = new ResourcesEstimator();
            // int RegisterSize = 10; 
            // testCFSQubitCount.Run(estimator,RegisterSize).Wait();
            // Console.WriteLine(estimator.ToTSV());
        }

        // function runs the quantum operation on a Quantum simulator and checks the
        // numerical results returned
        public static void TestOnToffoli(){
          var sim = new ToffoliSimulator();
          Random rand = new Random();
          int count = 0;
          for(int index = 0; index < 1; index++){  
            var bound = new BigInteger(rand.Next(10000));
            var r = new BigInteger(rand.Next((int)(ulong)bound));
            var denom = new BigInteger(Math.Pow(2.0, 2 * Math.Ceiling(Math.Log2((double) bound))));
            var t = new BigInteger(rand.Next((int)(ulong)r));
            var num = new BigInteger(Math.Floor((double)t * (double)denom / (double)r));
            var app1 = new BigInteger(0);
            var app2 = new BigInteger(0);
            var convIndex = 0;
            var size = (int)(Math.Ceiling(Math.Log2((double) bound)) * 2 + 1);
            Console.WriteLine("Initial values are {0}/{1} in bound {2}", num, denom, bound);
            Console.WriteLine("Expected value of r is {0}", r);
            while(denom != 0 && app1 < bound) {
              var results = testCFStep.Run(sim, num, denom, app1, app2, convIndex, size).Result;
              num = results[0];
              denom = results[1];
              app1 = results[2];
              app2 = results[3];
              Console.WriteLine("At index {0}, the convergent fraction denominator is {1}", convIndex, app1);
              convIndex += 1;
            }
            if(denom == 0 && app1 <= bound){
              app2 = app1;
            }
            Console.WriteLine("Expecting {0} and got {1}", r, app2);
            if(r == app2 || r % app2 == 0){
              count += 1;
            }
            Console.WriteLine("Accuracy {0}/{1}\n", count, index + 1);
          }
        }


        // function runs the quantum operation on a Quantum simulator and checks the
        // numerical results returned
        public static void TestOnQuantum(){
          // optimised values for a quantum simulation
          // Fibonnacci numbers chosen for a worst case scenario
          var sim = new QuantumSimulator();
          Random rand = new Random();
          int count = 0;
          for(int index = 0; index < 1; index++){  
            var app1 = new BigInteger(0);
            var app2 = new BigInteger(0);
            var num = new BigInteger(13);
            var denom = new BigInteger(21);
            var bound = 4;
            var r = 3;
            var convIndex = 0;
            var size = (int)(Math.Ceiling(Math.Log2((double) bound)) * 2 + 1);
            Console.WriteLine("Initial values are {0}/{1} in bound {2}", num, denom, bound);
            Console.WriteLine("Expected value of r is {0}", r);
            while(denom != 0 && app1 < bound) {
              var results = testCFStep.Run(sim, num, denom, app1, app2, convIndex, size).Result;
              num = results[0];
              denom = results[1];
              app1 = results[2];
              app2 = results[3];
              Console.WriteLine("At index {0}, the convergent fraction denominator is {1}", convIndex, app1);
              convIndex += 1;
            }
            if(denom == 0 && app1 <= bound){
              app2 = app1;
            }
            Console.WriteLine("Expecting {0} and got {1}", r, app2);
            if(r == app2 || r % app2 == 0){
              count += 1;
            }
            Console.WriteLine("Accuracy {0}/{1}\n", count, index + 1);
          }
        }

    }

}

