using System;
using System.Linq;
using System.Numerics;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace GenerateX.Testing
{
    class Driver
    {
        static void Main(string[] args)
        {
            // TestOnToffoli();

            // TestOnQuantum();
            
            // ResourcesEstimator estimator = new ResourcesEstimator();
            // int number = 5;
            // int randomN = 13;
            // Testing_in_Superposition.Run(estimator, randomN, number, number).Wait();
            // Console.WriteLine(estimator.ToTSV());

        }

        // function runs the quantum operation on a quantum simulator and checks the
        // numerical results returned
        // for best results, make sure you uncomment lines withn IncrementByInteger in Program.qs
        // and comment the lines using AddI and one
        public static void TestOnQuantum(){
          var sim = new QuantumSimulator();
          Random rand = new Random();
          int count = 0;

          for(int i = 0; i < 100; i++){
            // upper bounds chosen to account for number of qubits
            var n = new BigInteger(rand.Next(60)) + 4;
            var r = rand.Next(60) + 4;

            var x = GenerateXVal.Run(sim, n, r, SizeR(r)).Result;

            Console.WriteLine("N R X {0} {1} {2}", n, r, x);

            if((r % (n - 1)) - (x - 1) != 0) {
              Console.WriteLine("Bad");
            } else {
              count++;
            }

            Console.WriteLine("Accuracy {0} / {1}\n", count, i + 1);
          }
          Console.WriteLine("Correct {0}/100", count);
        }

        // function runs the quantum operation on a Toffoli simulator and checks the
        // numerical results returned
        // make sure you uncomment out the lines using Addi and one in Program.qs
        // and comment the lines using IncrementByInteger
        public static void TestOnToffoli(){
          var sim = new ToffoliSimulator();
          Random rand = new Random();
          int count = 0;

          for(int i = 0; i < 100; i++){
            var n = new BigInteger(rand.Next());
            var r = rand.Next();

            var x = GenerateXVal.Run(sim, n, r, SizeR(r)).Result;
            Console.WriteLine("N R X {0} {1} {2}", n, r, x);
            
            if((r % (n - 1)) - (x - 1) != 0) {
              Console.WriteLine("Bad");
            } else {
              count++;
            }
            Console.WriteLine("Accuracy {0} / {1}\n", count, i + 1);
          
          }
          Console.WriteLine("Correct {0}/100", count);
        }

        // given a big integer, the function returns its bit-length
        public static int SizeR(int bits) {
          int size = 0;

          for (; bits != 0; bits >>= 1)
            size++;

          return size;
        }

    }
}

