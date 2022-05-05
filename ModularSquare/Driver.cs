using System;
using System.Linq;
using System.Numerics;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace ModularSquare.Testing
{
    class Driver
    {
        static void Main(string[] args)
        {
            
            
            // TestwithToffoli();
            
            // TestwithQuantum();
            
            // ResourcesEstimator estimator = new ResourcesEstimator();
            // int RegisterSize = 10; 
            // Testing_in_Superposition.Run(estimator,RegisterSize).Wait();
            // Console.WriteLine(estimator.ToTSV());
            
        }

        // given a big integer, the function returns its bit-length
        public static int Size(BigInteger bits) {
          int size = 0;

          for (; bits != 0; bits >>= 1)
            size++;

          return size;
        }


        // function runs the quantum operation on a Toffoli simulator and checks the
        // numerical results returned
        public static void TestwithToffoli(){
            var sim = new ToffoliSimulator();

            Random rand = new Random();
            int count = 0;
            var a = new BigInteger();
            var m = new BigInteger();

            for(int i = 0; i < 100; i++){
              a = new BigInteger(rand.Next());
              m = new BigInteger(rand.Next());
              int [] requiredBits = {Size(a),Size(m)};
              int numBits = requiredBits.Max();
              Console.WriteLine(numBits);
              var res = modularSquare.Run(sim,a,m).Result;
              
              Console.WriteLine("Quantum Result: {0}^2 mod({1})= {2}",a,m,res);
              Console.WriteLine("Classical Result: {0}^2 mod({1})= {2}",a,m,((a*a) % m));
              if(res == (a * a) % m){
                count += 1;
              }
              Console.WriteLine("Accuracy {0} / {1}\n", count, i + 1);
              // Console.WriteLine("Quantum Result: {0} + {1} = {2}",a,m,res);
              // Console.WriteLine("Classical Result: {0} + {1} = {2}\n",a,m, (a*a) % m);
            }
            
        }


        // function runs the quantum operation on a Quantum simulator and checks the
        // numerical results returned
        public static void TestwithQuantum(){
            var sim = new QuantumSimulator();

            Random rand = new Random();
            int count = 0;
            var a = new BigInteger();
            var m = new BigInteger();

            for(int i = 0; i < 100; i++){
              a = new BigInteger(rand.Next(4));
              m = new BigInteger(rand.Next(3) + 1);
              int [] requiredBits = {Size(a),Size(m)};
              int numBits = requiredBits.Max();
              Console.WriteLine(numBits);
              var res = modularSquare.Run(sim,a,m).Result;
              
              Console.WriteLine("Quantum Result: {0}^2 mod({1})= {2}",a,m,res);
              Console.WriteLine("Classical Result: {0}^2 mod({1})= {2}",a,m,((a*a) % m));
              if(res == (a * a) % m){
                count += 1;
              }
              Console.WriteLine("Accuracy {0} / {1}\n", count, i + 1);
              // Console.WriteLine("Quantum Result: {0} + {1} = {2}",a,m,res);
              // Console.WriteLine("Classical Result: {0} + {1} = {2}\n",a,m, (a*a) % m);
            }
            
        }
    }
}