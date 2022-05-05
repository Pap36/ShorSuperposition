using System;
using System.Numerics;
using Microsoft.Quantum.Simulation.Simulators;

namespace ExponentiationStep.Testing
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

        // function runs the quantum operation on a Quantum simulator and checks the
        // numerical results returned
        public static void TestOnQuantum(){
          var sim = new QuantumSimulator();
          Random rand = new Random();
          var a = new BigInteger(rand.Next(3)) + 1;
          var b = new BigInteger(rand.Next(3)) + 1;
          var c = new BigInteger(rand.Next(3)) + 1;
          // a = 2;
          // b = 3;
          // c = 3;
          var curr = a;
          var bits = getBits(b);
          Console.WriteLine("Initial Values for a b c: {0} {1} {2}", a, b, c);
          
          foreach (bool bit in bits){
            var res = testSingleStep.Run(sim, a, bit, c, curr).Result;
            var expectedRes = (curr * curr) % c;
            if(bit == true){
              expectedRes = (expectedRes * a) % c;
            }
            Console.WriteLine("Expecting {0} and got {1}", expectedRes, res);
            if(res != expectedRes){
              Console.WriteLine("Bad");
              break;
            }
            curr = res;
          }
        }

        // function runs the quantum operation on a Toffoli simulator and checks the
        // numerical results returned
        public static void TestOnToffoli(){
          var sim = new QuantumSimulator();
          Random rand = new Random();
          var a = new BigInteger(rand.Next());
          var b = new BigInteger(rand.Next());
          var c = new BigInteger(rand.Next());
      
          var curr = a;
          var bits = getBits(b);
          Console.WriteLine("Initial Values for a b c: {0} {1} {2}", a, b, c);
          
          foreach (bool bit in bits){
            var res = testSingleStep.Run(sim, a, bit, c, curr).Result;
            var expectedRes = (curr * curr) % c;
            if(bit == true){
              expectedRes = (expectedRes * a) % c;
            }
            Console.WriteLine("Expecting {0} and got {1}", expectedRes, res);
            if(res != expectedRes){
              Console.WriteLine("Bad");
              break;
            }
            curr = res;
          }
        }

        // function returns the binary representation of a number and leaves out
        // the most significant bit
        public static bool[] getBits(BigInteger b){
          bool[] bits = new bool[Size(b)];
          int count = 0;
          while(b > 0){
            BigInteger rem = 0;
            BigInteger.DivRem(b, 2, out rem);
            if((int)rem == 1){
              bits[count] = true;
            } else {
              bits[count] = false;
            }
            b = (b - rem) / 2;
          }
          Array.Reverse(bits, 1, Size(b));
          return bits;
        }

        // function returns the bit-length of a number
        public static int Size(BigInteger bits) {
          int size = 0;

          for (; bits != 0; bits >>= 1)
            size++;

          return size;
        }

    }
}

