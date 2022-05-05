using System;
using System.Numerics;
using Microsoft.Quantum.Simulation.Simulators;

namespace ModularMult.Testing
{
    class Driver
    {
        static void Main(string[] args)
        {
            // TestOnToffoli();

            // TestOnQuantum();
            
            // ResourcesEstimator estimator = new ResourcesEstimator();
            // int RegisterSize = 10; 
            // Testing_in_Superposition.Run(estimator,RegisterSize).Wait();
            // Console.WriteLine(estimator.ToTSV());

        }
    
        
        // function runs the quantum operation on a Toffoli simulator and checks the
        // numerical results returned
        public static void TestOnToffoli(){
          var sim = new QuantumSimulator();
          Random rand = new Random();
          int count = 0;
          for(int i = 0; i < 100; i++){
            var a = new BigInteger(rand.Next());
            var b = new BigInteger(rand.Next());
            var r = new BigInteger(rand.Next());

            var x = Mult.Run(sim, a, b, r).Result;
            Console.WriteLine("Classical result: {0}", (a * b) % r);
            Console.WriteLine("Quantum result: {0}", x);
            
            if((a * b) % r - x != 0) {
              Console.WriteLine("Bad");
            } else {
              count++;
            }
            Console.WriteLine("Accuracy {0} / {1}\n", count, i + 1);
          }
          Console.WriteLine("Correct {0}/100", count);
        }


        // function runs the quantum operation on a Quantum simulator and checks the
        // numerical results returned
        public static void TestOnQuantum(){
          var sim = new QuantumSimulator();
          Random rand = new Random();
          int count = 0;
          for(int i = 0; i < 100; i++){
            var a = new BigInteger(rand.Next(4));
            var b = new BigInteger(rand.Next(4));
            var r = new BigInteger(rand.Next(3) + 1);

            var x = Mult.Run(sim, a, b, r).Result;
            Console.WriteLine("Classical result: {0}", (a * b) % r);
            Console.WriteLine("Quantum result: {0}", x);
           
            if((a * b) % r - x != 0) {
              Console.WriteLine("Bad");
            } else {
              count++;
            }
            Console.WriteLine("Accuracy {0} / {1}\n", count, i + 1);
          }
          Console.WriteLine("Correct {0}/100", count);
        }

    }
}

