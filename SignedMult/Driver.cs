using System;
using System.Linq;
using System.Numerics;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace SignedMult.Testing
{
    class Driver
    {
        static void Main(string[] args)
        {
            var sim = new ToffoliSimulator();
            Random rand = new Random();
            int count = 0;
            for(int i = 0; i < 10; i++){
              var a = new BigInteger(rand.Next(10000)) - 5000;
              var b = new BigInteger(rand.Next(10000)) - 5000;
              // var r = rand.Next();
              Boolean aSign = false, bSign = false;
              if(a < 0) {
                aSign = true;
                a *= -1;
              }
              if(b < 0) {
                bSign = true;
                b *= -1;
              }
              var x = Mult.Run(sim, a, b, aSign, bSign).Result;
              
              
              if(aSign) {
                a *= -1;
              }
              if(bSign) {
                b *= -1;
              }
              
              if((a * b) - x != 0) {
                Console.WriteLine("Bad");
                Console.WriteLine("Quantum: {0} * {1} = {2}", a, b, x);
                Console.WriteLine("Classic: {0} * {1} = {2}", a, b, a * b);
                Console.WriteLine();
              } else {
                count++;
              }


              
            }
            Console.WriteLine("Correct {0}/100", count);
            
            ResourcesEstimator estimator = new ResourcesEstimator();
            
            int RegisterSize = 5; 
            Testing_in_Superposition.Run(estimator,RegisterSize).Wait();
            Console.WriteLine(estimator.ToTSV());

        }

        public static int Size(BigInteger bits) {
          int size = 0;

          for (; bits != 0; bits >>= 1)
            size++;

          return size;
        }
    }
}

